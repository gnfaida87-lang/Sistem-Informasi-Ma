// lib/features/academic_config/services/grading_service.dart
import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';

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
        SELECT sg.id, sg.nilai as score, sg.jenis_ujian as type,
               s.nama as subject_name, s.kode as subject_code, s.kkm
        FROM nilai_siswa sg
        JOIN subjects s ON sg.mapel_id = s.id
        WHERE sg.siswa_id = ?
      """;
      final params = <dynamic>[studentId];

      if (semesterId != null) {
        sql += " AND sg.tahun_ajaran_id = ?";
        params.add(semesterId);
      }
      sql += " ORDER BY s.nama ASC";

      final results = await _d1Service.query(sql, params: params);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchStudentGrades: $e");
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
        SELECT sg.siswa_id as student_id, sg.nilai as score, sg.jenis_ujian as type,
               s.nama as student_name, s.nis,
               sub.nama as subject_name, sub.kkm
        FROM nilai_siswa sg
        JOIN students s ON sg.siswa_id = s.id
        JOIN subjects sub ON sg.mapel_id = sub.id
        WHERE s.kelas_id = ? AND sg.tahun_ajaran_id = ?
        ORDER BY s.nama, sub.nama
      """;
      final results = await _d1Service.query(sql, params: [classId, semesterId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchClassGradesRecap: $e");
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
        INSERT INTO nilai_siswa (id, siswa_id, mapel_id, tahun_ajaran_id, nilai, jenis_ujian)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(siswa_id, mapel_id, tahun_ajaran_id, jenis_ujian) DO UPDATE SET
          nilai = excluded.nilai
      """;
      final id = '${studentId}_${subjectId}_${semesterId}_$type';
      await _d1Service.query(sql, params: [id, studentId, subjectId, semesterId, score, type]);
    } catch (e) {
      debugPrint("Error upsertGrade: $e");
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
        debugPrint("Skip grade entry due to error: $e");
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
        SELECT es.id, es.tanggal_ujian as exam_date, es.jam_mulai as start_time, es.jam_selesai as end_time, es.ruangan as room, es.jenis_ujian as type,
               sub.nama as subject_name, sub.kode as subject_code,
               c.nama as class_name
        FROM jadwal_ujian es
        JOIN subjects sub ON es.mapel_id = sub.id
        LEFT JOIN classes c ON es.kelas_id = c.id
        WHERE es.tahun_ajaran_id = ?
        ORDER BY es.tanggal_ujian ASC, es.jam_mulai ASC
      """;
      final results = await _d1Service.query(sql, params: [semesterId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchExamSchedules: $e");
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
        INSERT INTO jadwal_ujian (id, mapel_id, kelas_id, tahun_ajaran_id, tanggal_ujian, jam_mulai, jam_selesai, ruangan, jenis_ujian)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      """;
      await _d1Service.query(sql, params: [
        id, subjectId, classId, semesterId, examDate, startTime, endTime, room, type
      ]);
    } catch (e) {
      debugPrint("Error addExamSchedule: $e");
      rethrow;
    }
  }

  /// Hapus jadwal ujian
  Future<void> deleteExamSchedule(String id) async {
    try {
      await _d1Service.query("DELETE FROM jadwal_ujian WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteExamSchedule: $e");
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
          INSERT INTO absensi (id, siswa_id, kelas_id, guru_id, tanggal, status, keterangan)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(siswa_id, tanggal) DO UPDATE SET
            status = excluded.status,
            keterangan = excluded.keterangan
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
        debugPrint("Skip attendance entry: $e");
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
        FROM absensi
        WHERE siswa_id = ? AND tahun_ajaran_id = ?
        GROUP BY status
      """;
      final results = await _d1Service.query(sql, params: [studentId, semesterId]);
      
      final summary = <String, int>{'hadir': 0, 'izin': 0, 'sakit': 0, 'alpha': 0};
      for (final row in results) {
        final status = (row['status'] as String? ?? 'alpha').toLowerCase();
        summary[status] = (row['total'] as num?)?.toInt() ?? 0;
      }
      final total = summary.values.fold(0, (a, b) => a + b);
      final pct = total > 0 ? ((summary['hadir']! / total) * 100).toStringAsFixed(1) : '0';

      return {...summary, 'total': total, 'attendance_pct': pct};
    } catch (e) {
      debugPrint("Error fetchAttendanceSummary: $e");
      return {'hadir': 0, 'izin': 0, 'sakit': 0, 'alpha': 0, 'total': 0, 'attendance_pct': '0'};
    }
  }
}
