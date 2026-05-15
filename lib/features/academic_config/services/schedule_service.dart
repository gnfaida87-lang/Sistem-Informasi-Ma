import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/scheduling_models.dart';
import 'package:flutter/foundation.dart';
import '../models/school_models.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/models/guru.dart';
import 'package:flutter/foundation.dart';

class ScheduleService {
  final _d1Service = D1Service();

  Future<List<TimeSlot>> getTimeSlots(String day) async {
    try {
      final sql = "SELECT * FROM time_slots WHERE hari = ? ORDER BY jam_mulai ASC";
      final results = await _d1Service.query(sql, params: [day]);
      return results.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error getTimeSlots: $e");
      return [];
    }
  }

  Future<List<Guru>> getAllTeachers() async {
    try {
      final sql = "SELECT id, nip, nama FROM teachers ORDER BY nama";
      final results = await _d1Service.query(sql);
      return results.map((json) => Guru.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error getAllTeachers: $e");
      return [];
    }
  }

  Future<List<Mapel>> getAllSubjects() async {
    try {
      final sql = "SELECT id, kode, nama, kkm FROM subjects ORDER BY nama";
      final results = await _d1Service.query(sql);
      return results.map((json) => Mapel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error getAllSubjects: $e");
      return [];
    }
  }

  Future<List<Kelas>> getClassesByLevel(String level) async {
    try {
      final sql = "SELECT c.*, t.nama as wali_nama FROM classes c LEFT JOIN teachers t ON c.wali_kelas_id = t.id WHERE c.nama LIKE ? ORDER BY c.nama ASC";
      final results = await _d1Service.query(sql, params: ["$level%"]);
      return results.map((json) => Kelas.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error getClassesByLevel: $e");
      return [];
    }
  }

  Future<List<ScheduleRow>> getTeacherSchedules(String teacherId, String semesterId) async {
    try {
      final sql = """
        SELECT ts.*, t.jam_mulai, t.jam_selesai, t.hari, c.nama as class_name, s.nama as subject_name
        FROM jadwal_pelajaran ts
        JOIN time_slots t ON ts.time_slot_id = t.id
        JOIN classes c ON ts.kelas_id = c.id
        JOIN subjects s ON ts.mapel_id = s.id
        WHERE ts.guru_id = ? AND ts.tahun_ajaran_id = ?
      """;
      final results = await _d1Service.query(sql, params: [teacherId, semesterId]);
      return results.map((json) => ScheduleRow.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error getTeacherSchedules: $e");
      return [];
    }
  }

  Future<List<ScheduleRow>> getClassSchedules(String classId, String semesterId) async {
    try {
      final sql = """
        SELECT ts.*, t.jam_mulai, t.jam_selesai, t.hari, tc.nama as teacher_name, s.nama as subject_name
        FROM jadwal_pelajaran ts
        JOIN time_slots t ON ts.time_slot_id = t.id
        JOIN teachers tc ON ts.guru_id = tc.id
        JOIN subjects s ON ts.mapel_id = s.id
        WHERE ts.kelas_id = ? AND ts.tahun_ajaran_id = ?
      """;
      final results = await _d1Service.query(sql, params: [classId, semesterId]);
      return results.map((json) => ScheduleRow.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error getClassSchedules: $e");
      return [];
    }
  }

  Future<bool> saveSchedule(String semesterId, String classId, String timeSlotId, String teacherId, String subjectId) async {
    try {
      final sql = """
        INSERT INTO jadwal_pelajaran (id, tahun_ajaran_id, kelas_id, time_slot_id, guru_id, mapel_id)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(tahun_ajaran_id, kelas_id, time_slot_id) DO UPDATE SET
        guru_id = excluded.guru_id,
        mapel_id = excluded.mapel_id
      """;
      final id = "${semesterId}_${classId}_${timeSlotId}";
      await _d1Service.query(sql, params: [id, semesterId, classId, timeSlotId, teacherId, subjectId]);
      return true;
    } catch (e) {
      debugPrint("Error saveSchedule: $e");
      return false;
    }
  }

  Future<List<ScheduleRow>> getSchedules(String semesterId, List<String> classIds, String day) async {
    try {
      if (classIds.isEmpty) return [];
      final placeholders = classIds.map((_) => '?').join(',');
      final sql = """
        SELECT ts.*, t.jam_mulai, t.jam_selesai, t.hari, tc.nama as teacher_name, s.nama as subject_name, c.nama as class_name
        FROM jadwal_pelajaran ts
        JOIN time_slots t ON ts.time_slot_id = t.id
        JOIN teachers tc ON ts.guru_id = tc.id
        JOIN subjects s ON ts.mapel_id = s.id
        JOIN classes c ON ts.kelas_id = c.id
        WHERE ts.tahun_ajaran_id = ? AND ts.kelas_id IN ($placeholders) AND t.hari = ?
      """;
      final results = await _d1Service.query(sql, params: [semesterId, ...classIds, day]);
      return results.map((json) => ScheduleRow.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error getSchedules: $e");
      return [];
    }
  }

  Future<void> deleteSchedule(String semesterId, String classId, String timeSlotId) async {
    try {
      const sql = "DELETE FROM jadwal_pelajaran WHERE tahun_ajaran_id = ? AND kelas_id = ? AND time_slot_id = ?";
      await _d1Service.query(sql, params: [semesterId, classId, timeSlotId]);
    } catch (e) {
      debugPrint("Error deleteSchedule: $e");
      rethrow;
    }
  }

  Future<void> deleteSchedulesByClassAndDay(String semesterId, String classId, String day) async {
    try {
      final sql = """
        DELETE FROM jadwal_pelajaran 
        WHERE tahun_ajaran_id = ? 
        AND kelas_id = ? 
        AND time_slot_id IN (SELECT id FROM time_slots WHERE hari = ?)
      """;
      await _d1Service.query(sql, params: [semesterId, classId, day]);
    } catch (e) {
      debugPrint("Error deleteSchedulesByClassAndDay: $e");
      rethrow;
    }
  }
}
