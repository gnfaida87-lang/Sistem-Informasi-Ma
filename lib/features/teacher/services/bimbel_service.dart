import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_models.dart';
import '../../../core/utils/error_handler.dart';

class BimbelService {
  final _supabase = Supabase.instance.client;

  // ── MANAJEMEN SESI BIMBEL ──────────────────────────────────
  
  Future<List<BimbelSession>> fetchTutorSessions(String teacherId) async {
    try {
      final response = await _supabase
          .from('bimbel_sessions')
          .select('*, program_bimbel(nama)')
          .eq('teacher_id', teacherId)
          .order('session_date', ascending: false);
      
      return response.map((e) => BimbelSession.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchTutorSessions');
      throw err;
    }
  }

  // ── MANAJEMEN PESERTA & PROGRESS ───────────────────────────

  Future<List<Map<String, dynamic>>> fetchParticipantsByProgram(String programId) async {
    try {
      final response = await _supabase
          .from('peserta_bimbel')
          .select('id, siswa(id, nis, nama)')
          .eq('program_id', programId)
          .eq('status', 'active');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchParticipantsByProgram');
      throw err;
    }
  }

  Future<void> saveBimbelProgress({
    required String sessionId,
    required String studentId,
    required bool isPresent,
    required double score,
    String? notes,
  }) async {
    try {
      await _supabase.from('bimbel_progress').upsert({
        'session_id': sessionId,
        'student_id': studentId,
        'is_present': isPresent,
        'score': score,
        'notes': notes,
      }, onConflict: 'session_id, student_id');
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'saveBimbelProgress');
      throw err;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSessionProgress(String sessionId) async {
    try {
      final response = await _supabase
          .from('bimbel_progress')
          .select('*, siswa(nama, nis)')
          .eq('session_id', sessionId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
