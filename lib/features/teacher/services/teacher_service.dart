import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_models.dart';
import '../../../core/utils/error_handler.dart';

class TeacherService {
  final _supabase = Supabase.instance.client;

  /// Mengambil jadwal mengajar guru dari tabel jadwal_pelajaran (Input dari Wakakur)
  Future<List<TeachingSchedule>> fetchScheduleByTeacher(String teacherId) async {
    try {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('*, kelas(nama), mapel(nama), jam_pelajaran(*)')
          .eq('guru_id', teacherId);
      
      final List data = response as List;
      return data.map((e) => TeachingSchedule.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchScheduleByTeacher');
      return [];
    }
  }

  /// Mengambil profil guru berdasarkan user_id
  Future<Map<String, dynamic>?> getTeacherProfileByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('guru')
          .select('id, nip, nama, is_wali_kelas')
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getTeacherProfileByUserId');
      throw err;
    }
  }

  /// Mengambil daftar siswa dalam satu kelas (Data Master Operator)
  Future<List<Map<String, dynamic>>> fetchStudentsByClass(String classId) async {
    try {
      final response = await _supabase
          .from('siswa')
          .select('id, nis, nama')
          .eq('kelas_id', classId)
          .order('nama');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchStudentsByClass');
      throw err;
    }
  }

  /// Real-time: Pengumuman baru langsung muncul (Kepala Sekolah -> Guru)
  Stream<List<Map<String, dynamic>>> streamAnnouncements() {
    return _supabase
        .from('pengumuman')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.where((e) => e['target_role'] == 'all' || e['target_role'] == 'guru').toList());
  }
}
