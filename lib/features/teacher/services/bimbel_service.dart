import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/teacher_models.dart';
import 'package:flutter/foundation.dart';

class BimbelService {
  final _d1Service = D1Service();

  // ── SESI BIMBEL ────────────────────────────────────────────

  Future<List<BimbelSession>> fetchTutorSessions(String teacherId) async {
    try {
      final sql = """
        SELECT bs.*, bp.nama as program_name
        FROM bimbel_sessions bs
        JOIN bimbel_programs bp ON bs.program_id = bp.id
        WHERE bs.teacher_id = ?
        ORDER BY bs.session_date DESC
      """;
      final results = await _d1Service.query(sql, params: [teacherId]);
      return results.map((e) => BimbelSession.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchTutorSessions: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProgramsByTeacher(String teacherId) async {
    try {
      final sql = "SELECT * FROM bimbel_programs WHERE guru_id = ? ORDER BY nama ASC";
      final results = await _d1Service.query(sql, params: [teacherId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchProgramsByTeacher: $e");
      return [];
    }
  }

  // ── PESERTA ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchParticipantsByProgram(String programId) async {
    try {
      final sql = """
        SELECT bpa.id, s.id as student_id, s.nis, s.nama as student_name
        FROM bimbel_participants bpa
        JOIN students s ON bpa.siswa_id = s.id
        WHERE bpa.program_id = ? AND bpa.status = 'active'
        ORDER BY s.nama ASC
      """;
      final results = await _d1Service.query(sql, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchParticipantsByProgram: $e");
      return [];
    }
  }

  // ── PROGRESS (ABSENSI + NILAI) ─────────────────────────────

  Future<void> saveBimbelProgress({
    required String sessionId,
    required String studentId,
    required bool isPresent,
    required double score,
    String? notes,
  }) async {
    try {
      // Cek apakah sudah ada
      final existing = await _d1Service.query(
        "SELECT id FROM bimbel_progress WHERE session_id = ? AND student_id = ?",
        params: [sessionId, studentId],
      );

      if (existing.isNotEmpty) {
        await _d1Service.query("""
          UPDATE bimbel_progress
          SET score = ?, notes = ?
          WHERE session_id = ? AND student_id = ?
        """, params: [score, notes ?? '', sessionId, studentId]);
      } else {
        final id = 'bp_${DateTime.now().millisecondsSinceEpoch}_${studentId.substring(0, 4)}';
        await _d1Service.query("""
          INSERT INTO bimbel_progress (id, session_id, student_id, score, notes)
          VALUES (?, ?, ?, ?, ?)
        """, params: [id, sessionId, studentId, score, notes ?? '']);
      }
    } catch (e) {
      debugPrint("Error saveBimbelProgress: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSessionProgress(String sessionId) async {
    try {
      final sql = """
        SELECT bp.*, s.nama as student_name, s.nis as student_nis
        FROM bimbel_progress bp
        JOIN students s ON bp.student_id = s.id
        WHERE bp.session_id = ?
        ORDER BY s.nama ASC
      """;
      final results = await _d1Service.query(sql, params: [sessionId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchSessionProgress: $e");
      return [];
    }
  }

  // ── MATERI (LINK, ZOOM, YOUTUBE, DLL) ─────────────────────

  Future<List<Map<String, dynamic>>> fetchMateri(
    String programId, {String? type}
  ) async {
    try {
      String sql = """
        SELECT * FROM bimbel_materi
        WHERE program_id = ?
      """;
      final params = <dynamic>[programId];

      if (type != null) {
        sql += " AND type = ?";
        params.add(type);
      }
      sql += " ORDER BY created_at DESC";

      final results = await _d1Service.query(sql, params: params);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchMateri: $e");
      return [];
    }
  }

  Future<void> saveMateri({
    required String programId,
    required String type,
    required String judul,
    required String url,
  }) async {
    try {
      final id = 'bm_${DateTime.now().millisecondsSinceEpoch}';
      await _d1Service.query("""
        INSERT INTO bimbel_materi (id, program_id, type, judul, url, created_at)
        VALUES (?, ?, ?, ?, ?, datetime('now'))
      """, params: [id, programId, type, judul, url]);
    } catch (e) {
      debugPrint("Error saveMateri: $e");
      rethrow;
    }
  }

  Future<void> deleteMateri(String id) async {
    await _d1Service.query("DELETE FROM bimbel_materi WHERE id = ?", params: [id]);
  }

  // ── SESI BARU ──────────────────────────────────────────────

  Future<void> createSession({
    required String programId,
    required String teacherId,
    required String topic,
    required DateTime sessionDate,
    int durationMinutes = 60,
  }) async {
    final id = 'bs_${DateTime.now().millisecondsSinceEpoch}';
    await _d1Service.query("""
      INSERT INTO bimbel_sessions (id, program_id, teacher_id, topic, session_date, duration_minutes)
      VALUES (?, ?, ?, ?, ?, ?)
    """, params: [
      id, programId, teacherId, topic,
      sessionDate.toIso8601String(), durationMinutes
    ]);
  }

  // ── WAKAKUR / KM REPORTING ──────────────────────────────
  
  Future<List<Map<String, dynamic>>> fetchProgramSummaries() async {
    try {
      const sql = """
        SELECT 
          bp.id, bp.nama, t.nama as teacher_name,
          (SELECT COUNT(*) FROM bimbel_participants bpa WHERE bpa.program_id = bp.id AND bpa.status = 'active') as student_count,
          (SELECT COUNT(*) FROM bimbel_sessions bs WHERE bs.program_id = bp.id) as session_count,
          (SELECT AVG(score) FROM bimbel_progress bpr 
           JOIN bimbel_sessions bs ON bpr.session_id = bs.id 
           WHERE bs.program_id = bp.id) as avg_score
        FROM bimbel_programs bp
        JOIN teachers t ON bp.guru_id = t.id
        ORDER BY bp.nama
      """;
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchProgramSummaries: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProgramPerformance(String programId) async {
    try {
      final sql = """
        SELECT 
          bs.session_date, bs.topic,
          AVG(bp.score) as avg_score,
          COUNT(bp.student_id) as attendance_count
        FROM bimbel_sessions bs
        LEFT JOIN bimbel_progress bp ON bs.id = bp.session_id
        WHERE bs.program_id = ?
        GROUP BY bs.id
        ORDER BY bs.session_date ASC
      """;
      final results = await _d1Service.query(sql, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchProgramPerformance: $e");
      return [];
    }
  }

  // ── MEETINGS (PERTEMUAN) ───────────────────────────────────

  Future<void> saveMeeting({
    required String programId,
    required String meetingNumber,
    required String title,
    required String driveUrl,
    required String zoomUrl,
    required String videoUrl,
  }) async {
    try {
      await _ensureBimbelTables();
      final id = 'meet_${DateTime.now().millisecondsSinceEpoch}';
      await _d1Service.query("""
        INSERT INTO bimbel_meetings (id, program_id, meeting_number, title, drive_url, zoom_url, video_url, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))
      """, params: [id, programId, meetingNumber, title, driveUrl, zoomUrl, videoUrl]);
    } catch (e) {
      debugPrint("Error saveMeeting: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMeetings(String programId) async {
    try {
      await _ensureBimbelTables();
      final sql = "SELECT * FROM bimbel_meetings WHERE program_id = ? ORDER BY CAST(meeting_number AS INTEGER) ASC";
      final results = await _d1Service.query(sql, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchMeetings: $e");
      return [];
    }
  }

  // ── CBT QUESTIONS (SOAL) ────────────────────────────────────

  Future<void> saveQuestion({
    required String programId,
    required String type, // pg, essai, listening
    required String questionText,
    String? optionsFormat, // A-D, A-E, A-F
    String? optionsJson,
    String? correctAnswer,
    String? audioUrl,
    int timeLimit = 60,
  }) async {
    try {
      await _ensureBimbelTables();
      final id = 'q_${DateTime.now().millisecondsSinceEpoch}';
      await _d1Service.query("""
        INSERT INTO bimbel_questions (id, program_id, type, question_text, options_format, options_json, correct_answer, audio_url, time_limit_seconds, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))
      """, params: [id, programId, type, questionText, optionsFormat, optionsJson, correctAnswer, audioUrl, timeLimit]);
    } catch (e) {
      debugPrint("Error saveQuestion: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestions(String programId) async {
    try {
      await _ensureBimbelTables();
      final sql = "SELECT * FROM bimbel_questions WHERE program_id = ? ORDER BY created_at ASC";
      final results = await _d1Service.query(sql, params: [programId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchQuestions: $e");
      return [];
    }
  }

  Future<void> _ensureBimbelTables() async {
    try {
      await _d1Service.query("""
        CREATE TABLE IF NOT EXISTS bimbel_meetings (
          id TEXT PRIMARY KEY,
          program_id TEXT,
          meeting_number TEXT,
          title TEXT,
          drive_url TEXT,
          zoom_url TEXT,
          video_url TEXT,
          created_at DATETIME
        )
      """);
      await _d1Service.query("""
        CREATE TABLE IF NOT EXISTS bimbel_questions (
          id TEXT PRIMARY KEY,
          program_id TEXT,
          type TEXT,
          question_text TEXT,
          options_format TEXT,
          options_json TEXT,
          correct_answer TEXT,
          audio_url TEXT,
          time_limit_seconds INTEGER,
          created_at DATETIME
        )
      """);
    } catch (_) {}
  }
}
