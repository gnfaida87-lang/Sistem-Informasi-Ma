import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_models.dart';
import '../../../core/utils/error_handler.dart';

class AcademicService {
  final _supabase = Supabase.instance.client;

  Future<List<Semester>> getActiveSemesters() async {
    try {
      final response = await _supabase
          .from('semester')
          .select('*, tahun_ajaran(tahun)')
          .order('created_at', ascending: false)
          .limit(20);
      
      if (response == null) return [];
      final list = response as List;
      return list.map((json) => Semester.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      final appError = handleSupabaseError(e);
      logError(appError, context: 'getActiveSemesters');
      return []; // Return empty list instead of throwing to prevent dashboard crash
    }
  }

  Future<bool> validateSemester(String semesterId, String userId) async {
    try {
      await _supabase.from('semester').update({
        'is_validated': true,
        'validated_by': userId,
      }).eq('id', semesterId);
      return true;
    } catch (e) {
      final appError = handleSupabaseError(e);
      logError(appError, context: 'validateSemester');
      throw appError;
    }
  }

  Future<bool> validateAllActiveSemesters(String userId) async {
    try {
      await _supabase.from('semester').update({
        'is_validated': true,
        'validated_by': userId,
      }).eq('is_active', true).eq('is_validated', false);
      return true;
    } catch (e) {
      final appError = handleSupabaseError(e);
      logError(appError, context: 'validateAllActiveSemesters');
      throw appError;
    }
  }

  Future<List<Department>> getDepartments() async {
    try {
      final response = await _supabase.from('jurusan')
          .select()
          .limit(10);
      
      if (response == null) return [];
      final list = response as List;
      return list.map((map) => Department.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      final appError = handleSupabaseError(e);
      logError(appError, context: 'getDepartments');
      return [];
    }
  }

  // ── INTEGRASI DATA MASTER ────────────────────────────────
  
  Future<List<Map<String, dynamic>>> fetchStudentsForDropdown() async {
    try {
      final response = await _supabase
          .from('siswa')
          .select('id, nis, nama, kelas_id')
          .eq('status', 'aktif')
          .order('nama');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchStudentsForDropdown');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTeachersForDropdown() async {
    try {
      final response = await _supabase
          .from('guru')
          .select('id, nip, nama')
          .order('nama');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchTeachersForDropdown');
      return [];
    }
  }
}
