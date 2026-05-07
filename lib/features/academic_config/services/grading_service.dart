// lib/features/academic_config/services/grading_service.dart
import '../../../core/network/d1_service.dart';

/// Step 9: Service untuk manajemen Jadwal Ujian & Nilai Siswa via Cloudflare D1
class GradingService {
  final _d1Service = D1Service();

  // ══════════════════════════════════════════════════════
  // NILAI SISWA (STUDENT GRADES)
  // ══════════════════════════════════════════════════════

  /// Ambil semua nilai untuk satu siswa di satu semester
  Future<List<Map<String, dynamic>>> fetchStudentGrades({
    required String studentId,
    String? semesterId,
  }) async {
    try {
      String sql = """
        SELECT sg.id, sg.score, sg.type,
               s.name as subject_name, s.code as subject_code, s.min_score as kkm
        FROM student_grades sg
        JOIN subjects s ON sg.subject_id = s.id
        WHERE sg.student_id = ?
      """;
      final params = <dynamic>[studentId];

      if (semesterId != null) {
        sql += " AND sg.semester_id = ?";
        params.add(semesterId);
      }
      sql += " ORDER BY s.name ASC";

      final results = await _d1Service.query(sql, params: params);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchStudentGrades: $e");
      return [];
    }
  }

  /// Ambil rekap nilai seluruh siswa dalam satu kelas
  Future<List<Map<String, dynamic>>> fetchClassGradesRecap({
    required String classId,
    required String semesterId,
  }) async {
    try {
      const sql = """
        SELECT sg.student_id, sg.score, sg.type,
               s.name as student_name, s.nis,
               sub.name as subject_name, sub.min_score as kkm
        FROM student_grades sg
        JOIN students s ON sg.student_id = s.id
        JOIN subjects sub ON sg.subject_id = sub.id
        WHERE s.class_id = ? AND sg.semester_id = ?
        ORDER BY s.name, sub.name
      """;
      final results = await _d1Service.query(sql, params: [classId, semesterId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchClassGradesRecap: $e");
      return [];
    }
  }

  /// Simpan atau update nilai satu siswa untuk satu mata pelajaran
  Future<void> upsertGrade({
    required String studentId,
    required String subjectId,
    required String semesterId,
    required double score,
    String type = 'FINAL',  // 'UTS', 'UAS', 'FINAL'
  }) async {
    try {
      const sql = """
        INSERT INTO student_grades (id, student_id, subject_id, semester_id, score, type)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(student_id, subject_id, semester_id, type) DO UPDATE SET
          score = excluded.score
      """;
      final id = '${studentId}_${subjectId}_${semesterId}_$type';
      await _d1Service.query(sql, params: [id, studentId, subjectId, semesterId, score, type]);
    } catch (e) {
      print("Error upsertGrade: $e");
      rethrow;
    }
  }

  /// Simpan nilai massal untuk satu kelas (batch insert)
  Future<int> batchUpsertGrades(List<Map<String, dynamic>> grades) async {
    int successCount = 0;
    for (final grade in grades) {
      try {
        await upsertGrade(
          studentId: grade['student_id'],
          subjectId: grade['subject_id'],
          semesterId: grade['semester_id'],
          score: (grade['score'] as num).toDouble(),
          type: grade['type'] ?? 'FINAL',
        );
        successCount++;
      } catch (e) {
        print("Skip grade entry due to error: $e");
      }
    }
    return successCount;
  }

  // ══════════════════════════════════════════════════════
  // JADWAL UJIAN (EXAM SCHEDULES)
  // ══════════════════════════════════════════════════════

  /// Ambil semua jadwal ujian untuk satu semester
  Future<List<Map<String, dynamic>>> fetchExamSchedules(String semesterId) async {
    try {
      const sql = """
        SELECT es.id, es.exam_date, es.start_time, es.end_time, es.room, es.type,
               sub.name as subject_name, sub.code as subject_code,
               c.name as class_name
        FROM exam_schedules es
        JOIN subjects sub ON es.subject_id = sub.id
        LEFT JOIN classes c ON es.class_id = c.id
        WHERE es.semester_id = ?
        ORDER BY es.exam_date ASC, es.start_time ASC
      """;
      final results = await _d1Service.query(sql, params: [semesterId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchExamSchedules: $e");
      return [];
    }
  }

  /// Tambah jadwal ujian baru
  Future<void> addExamSchedule({
    required String subjectId,
    required String classId,
    required String semesterId,
    required String examDate,
    required String startTime,
    required String endTime,
    String? room,
    String type = 'UAS',
  }) async {
    try {
      final id = 'exam_${DateTime.now().millisecondsSinceEpoch}';
      const sql = """
        INSERT INTO exam_schedules (id, subject_id, class_id, semester_id, exam_date, start_time, end_time, room, type)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      """;
      await _d1Service.query(sql, params: [
        id, subjectId, classId, semesterId, examDate, startTime, endTime, room, type
      ]);
    } catch (e) {
      print("Error addExamSchedule: $e");
      rethrow;
    }
  }

  /// Hapus jadwal ujian
  Future<void> deleteExamSchedule(String id) async {
    try {
      await _d1Service.query("DELETE FROM exam_schedules WHERE id = ?", params: [id]);
    } catch (e) {
      print("Error deleteExamSchedule: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // ABSENSI (ATTENDANCE)
  // ══════════════════════════════════════════════════════

  /// Simpan absensi harian siswa (batch)
  Future<void> saveAttendanceBatch({
    required String classId,
    required String teacherId,
    required String date,
    required List<Map<String, dynamic>> attendanceList,
  }) async {
    for (final att in attendanceList) {
      try {
        final id = 'att_${att['student_id']}_$date';
        const sql = """
          INSERT INTO attendance (id, student_id, class_id, teacher_id, date, status, notes)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(student_id, date) DO UPDATE SET
            status = excluded.status,
            notes = excluded.notes
        """;
        await _d1Service.query(sql, params: [
          id,
          att['student_id'],
          classId,
          teacherId,
          date,
          att['status'] ?? 'hadir',
          att['notes'],
        ]);
      } catch (e) {
        print("Skip attendance entry: $e");
      }
    }
  }

  /// Rekap absensi siswa dalam satu periode
  Future<Map<String, dynamic>> fetchAttendanceSummary({
    required String studentId,
    required String semesterId,
  }) async {
    try {
      const sql = """
        SELECT status, COUNT(*) as total
        FROM attendance
        WHERE student_id = ? AND semester_id = ?
        GROUP BY status
      """;
      final results = await _d1Service.query(sql, params: [studentId, semesterId]);
      
      final summary = <String, int>{'hadir': 0, 'izin': 0, 'sakit': 0, 'alpha': 0};
      for (final row in results) {
        final status = row['status'] as String? ?? 'alpha';
        summary[status] = (row['total'] as num?)?.toInt() ?? 0;
      }
      final total = summary.values.fold(0, (a, b) => a + b);
      final pct = total > 0 ? ((summary['hadir']! / total) * 100).toStringAsFixed(1) : '0';

      return {...summary, 'total': total, 'attendance_pct': pct};
    } catch (e) {
      print("Error fetchAttendanceSummary: $e");
      return {'hadir': 0, 'izin': 0, 'sakit': 0, 'alpha': 0, 'total': 0, 'attendance_pct': '0'};
    }
  }
}
