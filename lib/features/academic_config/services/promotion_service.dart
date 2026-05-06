// lib/features/academic_config/services/promotion_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/promotion_models.dart';
import '../../../core/utils/error_handler.dart';

class PromotionService {
  final _supabase = Supabase.instance.client;

  Future<List<PromotionCriteria>> fetchCriteria() async {
    try {
      final response = await _supabase
          .from('promotion_criteria')
          .select()
          .eq('is_active', true)
          .order('category');
      
      return (response as List).map((e) => PromotionCriteria.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      // Analisis Error: Jika muncul error "relation does not exist", artinya SQL belum dijalankan
      if (err.toString().contains('does not exist')) {
        print('⚠️ ANALISIS: Tabel promotion_criteria BELUM ditemukan di database.');
      }
      logError(err, context: 'fetchCriteria');
      return []; 
    }
  }

  Future<List<Alumni>> fetchAlumni(String query) async {
    try {
      var request = _supabase.from('alumni').select('*, students(name, nis)');
      
      if (query.isNotEmpty) {
        request = request.or('last_class_name.ilike.%$query%,students.name.ilike.%$query%');
      }

      final response = await request.order('graduation_year', ascending: false);
      return (response as List).map((e) => Alumni.fromJson(e)).toList();
    } catch (e) {
      logError(handleSupabaseError(e), context: 'fetchAlumni');
      return [];
    }
  }

  // Mengambil data siswa beserta kalkulasi evaluasi otomatis
  Future<List<Map<String, dynamic>>> fetchPromotionEvaluations(String classId) async {
    try {
      // 1. Ambil Kriteria yang aktif
      final criteria = await fetchCriteria();
      final minAttendance = criteria.firstWhere((c) => c.category == 'attendance', orElse: () => PromotionCriteria(title: '', value: '85', category: 'attendance', minThreshold: 85)).minThreshold ?? 85;
      final maxFailing = criteria.firstWhere((c) => c.category == 'grades', orElse: () => PromotionCriteria(title: '', value: '3', category: 'grades', minThreshold: 3)).minThreshold ?? 3;

      // 2. Ambil Siswa di kelas tersebut
      final studentsResponse = await _supabase.from('siswa').select('id, name, nis').eq('kelas_id', classId);
      final students = studentsResponse as List;

      List<Map<String, dynamic>> evaluations = [];

      for (var student in students) {
        final studentId = student['id'];

        // 3. Hitung Absensi (Sederhana: Hadir / Total)
        final attendanceResponse = await _supabase.from('absensi').select('status').eq('siswa_id', studentId);
        final attendanceList = attendanceResponse as List;
        double attendancePct = 100;
        if (attendanceList.isNotEmpty) {
          final present = attendanceList.where((a) => a['status'] == 'hadir').length;
          attendancePct = (present / attendanceList.length) * 100;
        }

        // 4. Hitung Nilai Tidak Tuntas
        // Mengambil rata-rata nilai per mapel dan bandingkan dengan KKM mapel tersebut
        final scoresResponse = await _supabase.from('nilai').select('skor, mapel(kkm)').eq('siswa_id', studentId);
        final scoresList = scoresResponse as List;
        int failingSubjects = 0;
        
        // Logika sederhana: jika ada nilai di bawah KKM
        if (scoresList.isNotEmpty) {
          failingSubjects = scoresList.where((s) => (s['skor'] as num) < (s['mapel']['kkm'] as num)).length;
        }

        // 5. Tentukan Status Rekomendasi
        bool isRecommended = attendancePct >= minAttendance && failingSubjects <= maxFailing;

        evaluations.add({
          'student_id': studentId,
          'name': student['name'],
          'nis': student['nis'],
          'attendance_pct': attendancePct.toStringAsFixed(1),
          'failing_subjects': failingSubjects,
          'is_recommended': isRecommended,
          'manual_status': isRecommended, // Default mengikuti rekomendasi
        });
      }

      return evaluations;
    } catch (e) {
      logError(handleSupabaseError(e), context: 'fetchPromotionEvaluations');
      return [];
    }
  }

  Future<void> executeMassPromotion({
    required List<Map<String, dynamic>> evaluations,
    required String? targetClassId,
    required String academicYearId,
    required String userId,
  }) async {
    try {
      for (var eval in evaluations) {
        if (eval['manual_status'] == true) {
          // JIKA NAIK/LULUS
          if (targetClassId != null) {
            // Naik Kelas
            await _supabase.from('siswa').update({'kelas_id': targetClassId}).eq('id', eval['student_id']);
          } else {
            // Lulus (Alumni)
            await _supabase.from('siswa').update({'status': 'graduated'}).eq('id', eval['student_id']);
            await _supabase.from('alumni').insert({
              'student_id': eval['student_id'],
              'graduation_year': DateTime.now().year,
              'last_class_name': 'Kelas Akhir',
            });
          }
        }

        // Catat Riwayat
        await _supabase.from('promotion_history').insert({
          'student_id': eval['student_id'],
          'status': eval['manual_status'] ? (targetClassId == null ? 'lulus' : 'naik') : 'tinggal',
          'new_class_id': eval['manual_status'] ? targetClassId : null,
          'academic_year_id': academicYearId,
          'processed_by': userId,
        });
      }
    } catch (e) {
      logError(handleSupabaseError(e), context: 'executeMassPromotion');
      throw e;
    }
  }

  Future<void> updateCriteria(PromotionCriteria criteria) async {
    try {
      if (criteria.id == null) return;
      await _supabase
          .from('promotion_criteria')
          .update(criteria.toJson())
          .eq('id', criteria.id!);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateCriteria');
      throw err;
    }
  }

  Future<void> addCriteria(PromotionCriteria criteria) async {
    try {
      await _supabase.from('promotion_criteria').insert(criteria.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addCriteria');
      throw err;
    }
  }

  Future<void> deleteCriteria(String id) async {
    try {
      await _supabase.from('promotion_criteria').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteCriteria');
      throw err;
    }
  }
}
