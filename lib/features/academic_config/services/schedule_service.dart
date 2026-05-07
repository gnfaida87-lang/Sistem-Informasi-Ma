import '../../../core/network/d1_service.dart';
import '../models/scheduling_models.dart';
import '../models/school_models.dart';
import '../../../shared/models/guru.dart';

class ScheduleService {
  final _d1Service = D1Service();

  Future<List<TimeSlot>> getTimeSlots(String day) async {
    try {
      final sql = "SELECT * FROM time_slots WHERE day = ? ORDER BY start_time ASC";
      final results = await _d1Service.query(sql, params: [day]);
      return results.map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      print("Error getTimeSlots: $e");
      return [];
    }
  }

  Future<List<Guru>> getAllTeachers() async {
    try {
      final sql = "SELECT * FROM teachers ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((json) => Guru.fromJson(json)).toList();
    } catch (e) {
      print("Error getAllTeachers: $e");
      return [];
    }
  }

  Future<List<Mapel>> getAllSubjects() async {
    try {
      final sql = "SELECT * FROM subjects ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((json) => Mapel.fromJson(json)).toList();
    } catch (e) {
      print("Error getAllSubjects: $e");
      return [];
    }
  }

  Future<List<Kelas>> getClassesByLevel(String level) async {
    try {
      final sql = "SELECT c.*, t.name as wali_nama FROM classes c LEFT JOIN teachers t ON c.teacher_id = t.id WHERE c.name LIKE ? ORDER BY c.name ASC";
      final results = await _d1Service.query(sql, params: ["$level%"]);
      return results.map((json) => Kelas.fromJson(json)).toList();
    } catch (e) {
      print("Error getClassesByLevel: $e");
      return [];
    }
  }

  Future<List<ScheduleRow>> getTeacherSchedules(String teacherId, String semesterId) async {
    try {
      final sql = """
        SELECT ts.*, t.start_time, t.end_time, t.day, c.name as class_name, s.name as subject_name
        FROM teaching_schedules ts
        JOIN time_slots t ON ts.time_slot_id = t.id
        JOIN classes c ON ts.class_id = c.id
        JOIN subjects s ON ts.subject_id = s.id
        WHERE ts.teacher_id = ? AND ts.academic_year_id = ?
      """;
      final results = await _d1Service.query(sql, params: [teacherId, semesterId]);
      return results.map((json) => ScheduleRow.fromJson(json)).toList();
    } catch (e) {
      print("Error getTeacherSchedules: $e");
      return [];
    }
  }

  Future<List<ScheduleRow>> getClassSchedules(String classId, String semesterId) async {
    try {
      final sql = """
        SELECT ts.*, t.start_time, t.end_time, t.day, tc.name as teacher_name, s.name as subject_name
        FROM teaching_schedules ts
        JOIN time_slots t ON ts.time_slot_id = t.id
        JOIN teachers tc ON ts.teacher_id = tc.id
        JOIN subjects s ON ts.subject_id = s.id
        WHERE ts.class_id = ? AND ts.academic_year_id = ?
      """;
      final results = await _d1Service.query(sql, params: [classId, semesterId]);
      return results.map((json) => ScheduleRow.fromJson(json)).toList();
    } catch (e) {
      print("Error getClassSchedules: $e");
      return [];
    }
  }

  Future<bool> saveSchedule(String semesterId, String classId, String timeSlotId, String teacherId, String subjectId) async {
    try {
      final sql = """
        INSERT INTO teaching_schedules (id, academic_year_id, class_id, time_slot_id, teacher_id, subject_id)
        VALUES (?, ?, ?, ?, ?, ?)
        ON CONFLICT(academic_year_id, class_id, time_slot_id) DO UPDATE SET
        teacher_id = excluded.teacher_id,
        subject_id = excluded.subject_id
      """;
      final id = "${semesterId}_${classId}_${timeSlotId}";
      await _d1Service.query(sql, params: [id, semesterId, classId, timeSlotId, teacherId, subjectId]);
      return true;
    } catch (e) {
      print("Error saveSchedule: $e");
      return false;
    }
  }
}
