import '../../../core/network/d1_service.dart';
import '../models/teacher_models.dart';

class BimbelService {
  final _d1Service = D1Service();

  // ── MANAJEMEN SESI BIMBEL ──────────────────────────────────
  
  Future<List<BimbelSession>> fetchTutorSessions(String teacherId) async {
    try {
      final sql = """
        SELECT bs.*, bp.name as program_name
        FROM bimbel_sessions bs
        JOIN bimbel_programs bp ON bs.program_id = bp.id
        WHERE bs.teacher_id = ?
        ORDER BY bs.session_date DESC
      """;
      final results = await _d1Service.query(sql, params: [teacherId]);
      return results.map((e) => BimbelSession.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchTutorSessions: $e");
      return [];
    }
  }

  // ── MANAJEMEN PESERTA & PROGRESS ───────────────────────────

  Future<List<Map<String, dynamic>>> fetchParticipantsByProgram(String programId) async {
    try {
      final sql = """
        SELECT bp.id, s.id as student_id, s.nis, s.name as student_name
        FROM bimbel_participants bp
        JOIN students s ON bp.student_id = s.id
        WHERE bp.program_id = ? AND bp.status = 'active'
      """;
      final results = await _d1Service.query(sql, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchParticipantsByProgram: $e");
      return [];
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
      final sql = """
        INSERT INTO bimbel_progress (session_id, student_id, is_present, score, notes)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(session_id, student_id) DO UPDATE SET
        is_present = excluded.is_present,
        score = excluded.score,
        notes = excluded.notes
      """;
      await _d1Service.query(sql, params: [
        sessionId,
        studentId,
        isPresent ? 1 : 0,
        score,
        notes
      ]);
    } catch (e) {
      print("Error saveBimbelProgress: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSessionProgress(String sessionId) async {
    try {
      final sql = """
        SELECT bp.*, s.name as student_name, s.nis as student_nis
        FROM bimbel_progress bp
        JOIN students s ON bp.student_id = s.id
        WHERE bp.session_id = ?
      """;
      final results = await _d1Service.query(sql, params: [sessionId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchSessionProgress: $e");
      return [];
    }
  }
}
