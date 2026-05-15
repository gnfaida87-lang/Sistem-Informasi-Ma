import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/parent_models.dart';
import 'package:flutter/foundation.dart';

class ParentService {
  final _d1Service = D1Service();

  // ── PROFIL ─────────────────────────────────────────────────
  Future<ParentChildProfile?> getParentDashboardProfile(String userId) async {
    try {
      final sql = """
        SELECT u.id, u.full_name as name, s.id as student_id, s.nis,
               s.nama as student_name, c.nama as class_name, c.id as class_id,
               t.nama as teacher_name
        FROM users u
        LEFT JOIN students s ON (u.id = s.user_id OR u.nis_nip = s.nis)
        LEFT JOIN classes c ON s.kelas_id = c.id
        LEFT JOIN teachers t ON c.teacher_id = t.id
        WHERE u.id = ?
        LIMIT 1
      """;
      final results = await _d1Service.query(sql, params: [userId]);
      if (results.isNotEmpty && results.first['student_id'] != null) {
        return ParentChildProfile.fromMap(results.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getParentDashboardProfile: $e');
      return null;
    }
  }

  // ── ABSENSI ────────────────────────────────────────────────
  Future<ChildAttendanceSummary?> getChildAttendanceToday(String studentId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final results = await _d1Service.query(
        "SELECT * FROM absensi WHERE siswa_id = ? AND tanggal = ? LIMIT 1",
        params: [studentId, today]);
      if (results.isNotEmpty) {
        final d = results.first;
        return ChildAttendanceSummary(
          status: d['status']?.toString().toUpperCase() ?? 'HADIR',
          time:   '--:--', 
          date:   DateTime.parse(d['tanggal']));
      }
      return null;
    } catch (e) { return null; }
  }

  // ── KEUANGAN ───────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getStudentFinances(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT * FROM pembayaran_spp 
        WHERE siswa_id = ? 
        ORDER BY tanggal_bayar DESC
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  Future<List<Map<String, dynamic>>> getOtherFees(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT * FROM biaya_lainnya 
        WHERE siswa_id = ? 
        ORDER BY status ASC, tenggat_waktu DESC
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  Future<double> getStudentSavings(String studentId) async {
    try {
      final results = await _d1Service.query("SELECT SUM(CASE WHEN jenis = 'setor' THEN jumlah ELSE -jumlah END) as total FROM tabungan WHERE siswa_id = ?", params: [studentId]);
      return (results.isNotEmpty ? (results.first['total'] ?? 0.0) : 0.0).toDouble();
    } catch (e) { return 0.0; }
  }

  Future<List<Map<String, dynamic>>> getStudentSavingsHistory(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT * FROM tabungan 
        WHERE siswa_id = ? 
        ORDER BY tanggal DESC
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  // ── NILAI ──────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getStudentGrades(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT sg.*, sub.nama as mapel_nama
        FROM nilai_siswa sg
        JOIN subjects sub ON sg.mapel_id = sub.id
        WHERE sg.siswa_id = ?
        ORDER BY sg.id DESC
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  // ── JADWAL ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchChildSchedule(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT ts.*, sub.nama as subject_name, t.nama as teacher_name,
               ts2.jam_mulai as start_time, ts2.jam_selesai as end_time,
               ts2.hari as day
        FROM jadwal_pelajaran ts
        JOIN students stu ON ts.kelas_id = stu.kelas_id
        JOIN subjects sub ON ts.mapel_id = sub.id
        JOIN teachers t ON ts.guru_id = t.id
        JOIN time_slots ts2 ON ts.time_slot_id = ts2.id
        WHERE stu.id = ?
        ORDER BY ts2.hari, ts2.jam_mulai
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  // ── PENGUMUMAN ─────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final results = await _d1Service.query(
        "SELECT * FROM announcements WHERE target_role IN ('all','orang_tua') ORDER BY created_at DESC");
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  // ── MATERI PELAJARAN ──────────────────────────────────────
  /// Ambil materi dari program bimbel anak — bisa ditampilkan ke orang tua
  Future<List<Map<String, dynamic>>> getChildMateri(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT bm.*, bp.nama as program_name,
               sub.nama as subject_name, sub.id as subject_id
        FROM bimbel_materi bm
        JOIN bimbel_programs bp ON bm.program_id = bp.id
        JOIN bimbel_participants bpa ON bpa.program_id = bp.id
        LEFT JOIN subjects sub ON bp.nama = sub.nama
        WHERE bpa.siswa_id = ? AND bpa.status = 'active'
          AND bm.type IN ('drive','youtube','link','arsip')
        ORDER BY bm.created_at DESC
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint('Error getChildMateri: $e');
      return [];
    }
  }

  /// Ambil daftar tugas anak (dari tabel bimbel_materi type='cbt' atau tugas)
  Future<List<Map<String, dynamic>>> getChildTugas(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT bm.*, bp.nama as program_name,
               sub.nama as subject_name, sub.id as subject_id
        FROM bimbel_materi bm
        JOIN bimbel_programs bp ON bm.program_id = bp.id
        JOIN bimbel_participants bpa ON bpa.program_id = bp.id
        LEFT JOIN subjects sub ON bp.nama = sub.nama
        WHERE bpa.siswa_id = ? AND bpa.status = 'active'
          AND bm.type IN ('cbt','tugas')
        ORDER BY bm.created_at DESC
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint('Error getChildTugas: $e');
      return [];
    }
  }

  /// Ambil daftar mata pelajaran anak untuk filter
  Future<List<Map<String, dynamic>>> getChildSubjects(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT DISTINCT sub.id, sub.nama, sub.kode
        FROM jadwal_pelajaran ts
        JOIN students stu ON ts.kelas_id = stu.kelas_id
        JOIN subjects sub ON ts.mapel_id = sub.id
        WHERE stu.id = ?
        ORDER BY sub.nama
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  // ── BIMBEL ─────────────────────────────────────────────────
  /// Ambil program bimbel + info guru untuk anak
  Future<List<Map<String, dynamic>>> getStudentBimbelDetail(String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT bpa.program_id, bp.nama as program_name,
               t.nama as teacher_name, bpa.status,
               COUNT(bs.id) as total_sessions
        FROM bimbel_participants bpa
        JOIN bimbel_programs bp ON bpa.program_id = bp.id
        LEFT JOIN teachers t ON bp.guru_id = t.id
        LEFT JOIN bimbel_sessions bs ON bs.program_id = bp.id
        WHERE bpa.siswa_id = ? AND bpa.status = 'active'
        GROUP BY bpa.program_id
      """, params: [studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint('Error getStudentBimbelDetail: $e');
      return [];
    }
  }

  /// Ambil sesi bimbel dalam suatu program
  Future<List<Map<String, dynamic>>> getBimbelSessions(String programId) async {
    try {
      final results = await _d1Service.query("""
        SELECT * FROM bimbel_sessions
        WHERE program_id = ?
        ORDER BY session_date DESC
      """, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  /// Ambil nilai & absensi anak dalam suatu program
  Future<List<Map<String, dynamic>>> getBimbelProgress(
      String programId, String studentId) async {
    try {
      final results = await _d1Service.query("""
        SELECT bp.*, bs.topic, bs.session_date, bs.duration_minutes
        FROM bimbel_progress bp
        JOIN bimbel_sessions bs ON bp.session_id = bs.id
        WHERE bs.program_id = ? AND bp.student_id = ?
        ORDER BY bs.session_date DESC
      """, params: [programId, studentId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  /// Ambil materi dalam suatu program bimbel
  Future<List<Map<String, dynamic>>> getBimbelMateri(String programId) async {
    try {
      final results = await _d1Service.query("""
        SELECT * FROM bimbel_materi
        WHERE program_id = ?
        ORDER BY created_at DESC
      """, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  Future<List<Map<String, dynamic>>> getBimbelMeetings(String programId) async {
    try {
      final sql = "SELECT * FROM bimbel_meetings WHERE program_id = ? ORDER BY CAST(meeting_number AS INTEGER) ASC";
      final results = await _d1Service.query(sql, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  Future<List<Map<String, dynamic>>> getBimbelQuestions(String programId) async {
    try {
      final sql = "SELECT * FROM bimbel_questions WHERE program_id = ? ORDER BY created_at ASC";
      final results = await _d1Service.query(sql, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) { return []; }
  }

  /// Alias untuk getStudentBimbelDetail — digunakan oleh ParentBimbelProgramScreen
  Future<List<Map<String, dynamic>>> getStudentBimbelPrograms(String studentId) =>
      getStudentBimbelDetail(studentId);
}
