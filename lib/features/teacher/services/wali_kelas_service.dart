import '../../../core/network/d1_service.dart';

class WaliKelasService {
  final _d1Service = D1Service();

  // ── MANAJEMEN KELAS PERWALIAN ─────────────────────────────
  
  Future<String?> getTeacherIdByUserId(String userId) async {
    try {
      final sql = "SELECT id FROM teachers WHERE user_id = ? LIMIT 1";
      final results = await _d1Service.query(sql, params: [userId]);
      return results.isNotEmpty ? results.first['id'] as String? : null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchWaliKelasClass(String teacherId) async {
    try {
      final sql = "SELECT id, name as nama FROM classes WHERE teacher_id = ? LIMIT 1";
      final results = await _d1Service.query(sql, params: [teacherId]);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchStudentsWithParents(String classId) async {
    try {
      final sql = """
        SELECT s.*, p.name as parent_name, p.phone as parent_phone
        FROM students s
        LEFT JOIN student_parents sp ON s.id = sp.student_id
        LEFT JOIN parents p ON sp.parent_id = p.id
        WHERE s.class_id = ?
        ORDER BY s.name
      """;
      final results = await _d1Service.query(sql, params: [classId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchStudentsWithParents: $e");
      return [];
    }
  }

  // ── AGREGASI & REKAP ─────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchClassGradesRecap(String classId) async {
    try {
      final sql = """
        SELECT sg.score as skor, sub.name as mapel_nama
        FROM student_grades sg
        JOIN subjects sub ON sg.subject_id = sub.id
        JOIN students s ON sg.student_id = s.id
        WHERE s.class_id = ?
      """;
      final results = await _d1Service.query(sql, params: [classId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchClassAttendanceRecap(String classId) async {
    try {
      final sql = """
        SELECT a.status, s.name as student_name
        FROM attendance a
        JOIN students s ON a.student_id = s.id
        WHERE s.class_id = ?
      """;
      final results = await _d1Service.query(sql, params: [classId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchClassNotes(String classId) async {
    try {
      final sql = """
        SELECT dn.*, t.name as teacher_name
        FROM development_notes dn
        JOIN teachers t ON dn.teacher_id = t.id
        WHERE dn.class_id = ?
        ORDER BY dn.created_at DESC
      """;
      final results = await _d1Service.query(sql, params: [classId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      return [];
    }
  }

  Future<void> addClassNote(String classId, String teacherId, String category, String note) async {
    try {
      final sql = "INSERT INTO development_notes (class_id, teacher_id, category, note) VALUES (?, ?, ?, ?)";
      await _d1Service.query(sql, params: [classId, teacherId, category, note]);
    } catch (e) {
      print("Error addClassNote: $e");
      rethrow;
    }
  }
}
