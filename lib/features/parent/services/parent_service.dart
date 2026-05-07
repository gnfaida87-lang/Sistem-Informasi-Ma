import '../../../core/network/d1_service.dart';
import '../models/parent_models.dart';

class ParentService {
  final _d1Service = D1Service();

  /// Mengambil profil orang tua beserta data anak
  Future<ParentChildProfile?> getParentDashboardProfile(String userId) async {
    try {
      final sql = """
        SELECT p.*, s.id as student_id, s.name as student_name, c.name as class_name, t.name as teacher_name
        FROM parents p
        JOIN student_parents sp ON p.id = sp.parent_id
        JOIN students s ON sp.student_id = s.id
        JOIN classes c ON s.class_id = c.id
        LEFT JOIN teachers t ON c.teacher_id = t.id
        WHERE p.user_id = ?
        LIMIT 1
      """;
      final results = await _d1Service.query(sql, params: [userId]);

      if (results.isNotEmpty) {
        return ParentChildProfile.fromMap(results.first);
      }
      return null;
    } catch (e) {
      print("Error getParentDashboardProfile: $e");
      return null;
    }
  }

  /// Mengambil status kehadiran anak hari ini
  Future<ChildAttendanceSummary?> getChildAttendanceToday(String studentId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final sql = "SELECT * FROM attendance WHERE student_id = ? AND date = ? LIMIT 1";
      final results = await _d1Service.query(sql, params: [studentId, today]);

      if (results.isNotEmpty) {
        final data = results.first;
        return ChildAttendanceSummary(
          status: data['status']?.toString().toUpperCase() ?? 'HADIR',
          time: data['check_in_time'] ?? '--:--',
          date: DateTime.parse(data['date']),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mengambil riwayat nilai akademik anak
  Future<List<Map<String, dynamic>>> getStudentGrades(String studentId) async {
    try {
      final sql = """
        SELECT sg.*, sub.name as mapel_nama
        FROM student_grades sg
        JOIN subjects sub ON sg.subject_id = sub.id
        WHERE sg.student_id = ?
        ORDER BY sg.created_at DESC
      """;
      final results = await _d1Service.query(sql, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      return [];
    }
  }

  /// Mengambil program bimbel yang diikuti anak
  Future<List<Map<String, dynamic>>> getStudentBimbelPrograms(String studentId) async {
    try {
      final sql = """
        SELECT bp.*, bprog.name as program_name, t.name as teacher_name
        FROM bimbel_participants bp
        JOIN bimbel_programs bprog ON bp.program_id = bprog.id
        JOIN teachers t ON bprog.teacher_id = t.id
        WHERE bp.student_id = ? AND bp.status = 'active'
      """;
      final results = await _d1Service.query(sql, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      return [];
    }
  }

  /// Mengambil data keuangan anak (Tagihan SPP)
  Future<List<Map<String, dynamic>>> getStudentFinances(String studentId) async {
    try {
      final sql = """
        SELECT * FROM spp_records 
        WHERE student_id = ? AND status = 'belum_lunas'
        ORDER BY year ASC, month ASC
      """;
      final results = await _d1Service.query(sql, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      return [];
    }
  }

  /// Mengambil saldo tabungan anak
  Future<double> getStudentSavings(String studentId) async {
    try {
      final sql = "SELECT SUM(CASE WHEN type = 'setor' THEN amount ELSE -amount END) as balance FROM savings WHERE student_id = ?";
      final results = await _d1Service.query(sql, params: [studentId]);
      return (results.first['balance'] ?? 0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  /// Mengambil jadwal pelajaran anak
  Future<List<Map<String, dynamic>>> fetchChildSchedule(String studentId) async {
    try {
      final sql = """
        SELECT ts.*, s.name as subject_name, t.name as teacher_name, slot.start_time, slot.end_time
        FROM teaching_schedules ts
        JOIN students stu ON ts.class_id = stu.class_id
        JOIN subjects s ON ts.subject_id = s.id
        JOIN teachers t ON ts.teacher_id = t.id
        JOIN time_slots slot ON ts.time_slot_id = slot.id
        WHERE stu.id = ?
      """;
      final results = await _d1Service.query(sql, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchChildSchedule: $e");
      return [];
    }
  }

  /// Pengumuman (Kepala Sekolah -> Ortu)
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final sql = "SELECT * FROM announcements WHERE target_role IN ('all', 'orang_tua') ORDER BY created_at DESC";
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      return [];
    }
  }
}
