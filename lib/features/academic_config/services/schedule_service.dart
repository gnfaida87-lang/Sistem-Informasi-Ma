import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scheduling_models.dart';
import '../models/school_models.dart';
import '../../../shared/models/guru.dart';
import '../../../core/utils/error_handler.dart';

class ScheduleService {
  final _supabase = Supabase.instance.client;

  /// Mengambil jam pelajaran berdasarkan hari (Data dari Operator)
  Future<List<TimeSlot>> getTimeSlots(String day) async {
    try {
      final response = await _supabase
          .from('jam_pelajaran')
          .select()
          .eq('hari', day)
          .order('waktu_mulai', ascending: true);
      
      return (response as List).map((json) => TimeSlot.fromJson(json)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getTimeSlots');
      return [];
    }
  }

  /// Mengambil semua guru aktif (Data Master Operator)
  Future<List<Guru>> getAllTeachers() async {
    try {
      final response = await _supabase
          .from('guru')
          .select('*, users(username)')
          .order('nama');
      return (response as List).map((json) => Guru.fromJson(json)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getAllTeachers');
      return [];
    }
  }

  /// Mengambil semua mata pelajaran (Data Master Operator)
  Future<List<Mapel>> getAllSubjects() async {
    try {
      final response = await _supabase
          .from('mapel')
          .select()
          .order('nama');
      return (response as List).map((json) => Mapel.fromJson(json)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getAllSubjects');
      return [];
    }
  }

  /// Mengambil kelas berdasarkan level (Data Master Operator)
  Future<List<Kelas>> getClassesByLevel(String level) async {
    try {
      final response = await _supabase
          .from('kelas')
          .select('*, guru(nama)')
          .ilike('nama', '$level%')
          .order('nama', ascending: true);
      
      return (response as List).map((json) => Kelas.fromJson(json)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getClassesByLevel');
      return [];
    }
  }

  Future<List<ScheduleRow>> getTeacherSchedules(String teacherId, String semesterId) async {
    try {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('*, jam_pelajaran(*), kelas(nama), mapel(nama)')
          .eq('guru_id', teacherId)
          .eq('semester_id', semesterId);
      
      return (response as List).map((json) => ScheduleRow.fromJson(json)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getTeacherSchedules');
      return [];
    }
  }

  Future<List<ScheduleRow>> getClassSchedules(String classId, String semesterId) async {
    try {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('*, jam_pelajaran(*), guru(nama), mapel(nama)')
          .eq('kelas_id', classId)
          .eq('semester_id', semesterId);
      
      return (response as List).map((json) => ScheduleRow.fromJson(json)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getClassSchedules');
      return [];
    }
  }

  Future<List<ScheduleRow>> getSchedules(String semesterId, List<String> classIds, String day) async {
    try {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('*, guru(nama), mapel(nama), jam_pelajaran(*)')
          .eq('semester_id', semesterId)
          .inFilter('kelas_id', classIds)
          .eq('jam_pelajaran.hari', day);
      
      return (response as List).map((json) => ScheduleRow.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveSchedule(String semesterId, String classId, String timeSlotId, String teacherId, String subjectId) async {
    try {
      await _supabase.from('jadwal_pelajaran').upsert({
        'semester_id': semesterId,
        'kelas_id': classId,
        'jam_pelajaran_id': timeSlotId,
        'guru_id': teacherId,
        'mapel_id': subjectId,
      }, onConflict: 'semester_id, kelas_id, jam_pelajaran_id');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteSchedule(String semesterId, String classId, String timeSlotId) async {
    try {
      await _supabase
          .from('jadwal_pelajaran')
          .delete()
          .match({
            'semester_id': semesterId,
            'kelas_id': classId,
            'jam_pelajaran_id': timeSlotId,
          });
      return true;
    } catch (e) {
      return false;
    }
  }
}
