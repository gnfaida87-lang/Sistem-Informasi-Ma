import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/teacher_models.dart';
import 'package:flutter/foundation.dart';

class TeacherService {
  final _d1Service = D1Service();

  /// Mengambil jadwal mengajar guru dari tabel teaching_schedules
  Future<List<TeachingSchedule>> fetchScheduleByTeacher(String teacherId) async {
    try {
      final sql = """
        SELECT ts.*, c.nama as class_name, s.nama as subject_name, t.jam_mulai as start_time, t.jam_selesai as end_time, t.hari as day
        FROM jadwal_pelajaran ts
        JOIN classes c ON ts.kelas_id = c.id
        JOIN subjects s ON ts.mapel_id = s.id
        JOIN time_slots t ON ts.time_slot_id = t.id
        WHERE ts.guru_id = ?
      """;
      final results = await _d1Service.query(sql, params: [teacherId]);
      return results.map((e) => TeachingSchedule.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("Error fetchScheduleByTeacher: $e");
      return [];
    }
  }

  /// Mengambil profil guru berdasarkan user_id
  Future<Map<String, dynamic>?> getTeacherProfileByUserId(String userId) async {
    try {
      final sql = "SELECT id, nip, nama, is_wali_kelas FROM teachers WHERE user_id = ? LIMIT 1";
      final results = await _d1Service.query(sql, params: [userId]);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      debugPrint("Error getTeacherProfileByUserId: $e");
      return null;
    }
  }

  /// Mengambil daftar siswa dalam satu kelas
  Future<List<Map<String, dynamic>>> fetchStudentsByClass(String classId) async {
    try {
      final sql = "SELECT id, nis, nama FROM students WHERE kelas_id = ? AND status = 'active' ORDER BY nama";
      final results = await _d1Service.query(sql, params: [classId]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchStudentsByClass: $e");
      return [];
    }
  }

  /// Pengumuman (Kepala Sekolah -> Guru)
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final sql = "SELECT * FROM announcements WHERE target_role IN ('all', 'guru') ORDER BY created_at DESC";
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error getAnnouncements: $e");
      return [];
    }
  }
}
