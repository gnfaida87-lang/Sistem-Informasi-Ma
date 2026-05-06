// lib/features/master_data/services/master_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/master_models.dart';
import '../../../core/utils/error_handler.dart';

class MasterService {
  final _supabase = Supabase.instance.client;

  // ── SISWA (STUDENTS) ──────────────────────────────────
  Future<List<Student>> fetchAllStudents() async {
    try {
      final response = await _supabase
          .from('siswa')
          .select('*, orang_tua_siswa(orang_tua(*))')
          .order('nama');
      return response.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllStudents');
      throw err;
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      await _supabase.from('siswa').insert(student.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addStudent');
      throw err;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _supabase
          .from('siswa')
          .update(student.toJson())
          .eq('id', student.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateStudent');
      throw err;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _supabase.from('siswa').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteStudent');
      throw err;
    }
  }

  // ── GURU (TEACHERS) ───────────────────────────────────
  Future<List<Teacher>> fetchAllTeachers() async {
    try {
      final response = await _supabase
          .from('guru')
          .select('id, nip, nama, is_wali_kelas')
          .order('nama');
      return response.map((e) => Teacher.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllTeachers');
      throw err;
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    try {
      await _supabase.from('guru').insert(teacher.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addTeacher');
      throw err;
    }
  }

  Future<void> updateTeacher(Teacher teacher) async {
    try {
      await _supabase
          .from('guru')
          .update(teacher.toJson())
          .eq('id', teacher.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateTeacher');
      throw err;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      await _supabase.from('guru').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteTeacher');
      throw err;
    }
  }

  // ── KELAS (CLASSES) ───────────────────────────────────
  Future<List<ClassRoom>> fetchAllClasses() async {
    try {
      // Fetch with wali_kelas join if needed, or simple fetch
      final response = await _supabase
          .from('kelas')
          .select('id, nama, wali_kelas_id, kapasitas')
          .order('nama');
      return response.map((e) => ClassRoom.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllClasses');
      throw err;
    }
  }

  Future<void> addClass(ClassRoom classRoom) async {
    try {
      await _supabase.from('kelas').insert(classRoom.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addClass');
      throw err;
    }
  }

  Future<void> updateClass(ClassRoom classRoom) async {
    try {
      await _supabase
          .from('kelas')
          .update(classRoom.toJson())
          .eq('id', classRoom.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateClass');
      throw err;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await _supabase.from('kelas').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteClass');
      throw err;
    }
  }

  // ── MAPEL (SUBJECTS) ──────────────────────────────────
  Future<List<Subject>> fetchAllSubjects() async {
    try {
      final response = await _supabase
          .from('mapel')
          .select('id, kode, nama, kkm')
          .order('nama');
      return response.map((e) => Subject.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllSubjects');
      throw err;
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      await _supabase.from('mapel').insert(subject.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addSubject');
      throw err;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      await _supabase
          .from('mapel')
          .update(subject.toJson())
          .eq('id', subject.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateSubject');
      throw err;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _supabase.from('mapel').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteSubject');
      throw err;
    }
  }

  // ── JURUSAN (MAJORS) ──────────────────────────────────
  Future<List<Major>> fetchAllMajors() async {
    try {
      final response = await _supabase
          .from('jurusan')
          .select('id, kode, nama')
          .order('nama');
      return response.map((e) => Major.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllMajors');
      throw err;
    }
  }

  Future<void> addMajor(Major major) async {
    try {
      await _supabase.from('jurusan').insert(major.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addMajor');
      throw err;
    }
  }

  Future<void> updateMajor(Major major) async {
    try {
      await _supabase
          .from('jurusan')
          .update(major.toJson())
          .eq('id', major.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateMajor');
      throw err;
    }
  }

  Future<void> deleteMajor(String id) async {
    try {
      await _supabase.from('jurusan').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteMajor');
      throw err;
    }
  }

  // ── TAHUN AJARAN (ACADEMIC YEARS) ─────────────────────
  Future<List<AcademicYear>> fetchAllAcademicYears() async {
    try {
      final response = await _supabase
          .from('tahun_ajaran')
          .select('id, tahun, is_active')
          .order('tahun', ascending: false);
      return response.map((e) => AcademicYear.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllAcademicYears');
      throw err;
    }
  }

  Future<AcademicYear> fetchActiveAcademicYear() async {
    try {
      final response = await _supabase
          .from('tahun_ajaran')
          .select('id, tahun, is_active')
          .eq('is_active', true)
          .single();
      return AcademicYear.fromJson(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchActiveAcademicYear');
      throw err;
    }
  }

  Future<void> addAcademicYear(AcademicYear academicYear) async {
    try {
      await _supabase.from('tahun_ajaran').insert(academicYear.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addAcademicYear');
      throw err;
    }
  }

  Future<void> updateAcademicYear(AcademicYear academicYear) async {
    try {
      await _supabase
          .from('tahun_ajaran')
          .update(academicYear.toJson())
          .eq('id', academicYear.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateAcademicYear');
      throw err;
    }
  }

  Future<void> deleteAcademicYear(String id) async {
    try {
      await _supabase.from('tahun_ajaran').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteAcademicYear');
      throw err;
    }
  }

  // ── EKSKUL (EXTRACURRICULAR) ──────────────────────────
  Future<List<Extracurricular>> fetchAllEkskul() async {
    try {
      final response = await _supabase
          .from('ekskul')
          .select('id, nama, pembina')
          .order('nama');
      return response.map((e) => Extracurricular.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllEkskul');
      throw err;
    }
  }

  Future<void> addEkskul(Extracurricular ekskul) async {
    try {
      await _supabase.from('ekskul').insert(ekskul.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addEkskul');
      throw err;
    }
  }

  Future<void> updateEkskul(Extracurricular ekskul) async {
    try {
      await _supabase
          .from('ekskul')
          .update(ekskul.toJson())
          .eq('id', ekskul.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateEkskul');
      throw err;
    }
  }

  Future<void> deleteEkskul(String id) async {
    try {
      await _supabase.from('ekskul').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteEkskul');
      throw err;
    }
  }

  // ── BIMBEL (TUTORING) ─────────────────────────────────
  Future<List<Tutoring>> fetchAllBimbel() async {
    try {
      final response = await _supabase
          .from('program_bimbel')
          .select('id, nama, guru_id')
          .order('nama');
      return response.map((e) => Tutoring.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchAllBimbel');
      throw err;
    }
  }

  Future<void> addBimbel(Tutoring bimbel) async {
    try {
      await _supabase.from('program_bimbel').insert(bimbel.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addBimbel');
      throw err;
    }
  }

  Future<void> updateBimbel(Tutoring bimbel) async {
    try {
      await _supabase
          .from('program_bimbel')
          .update(bimbel.toJson())
          .eq('id', bimbel.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateBimbel');
      throw err;
    }
  }

  Future<void> deleteBimbel(String id) async {
    try {
      await _supabase.from('program_bimbel').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteBimbel');
      throw err;
    }
  }

  // ── PESERTA BIMBEL (BIMBEL PARTICIPANTS) ──────────────
  Future<List<BimbelParticipant>> fetchBimbelParticipants(String programId) async {
    try {
      final response = await _supabase
          .from('peserta_bimbel')
          .select('id, program_id, siswa_id, siswa:siswa(*)')
          .eq('program_id', programId);
      return response.map((e) => BimbelParticipant.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchBimbelParticipants');
      throw err;
    }
  }

  Future<void> addBimbelParticipant(String programId, String studentId) async {
    try {
      await _supabase.from('peserta_bimbel').insert({
        'program_id': programId,
        'siswa_id': studentId,
      });
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addBimbelParticipant');
      throw err;
    }
  }

  Future<void> removeBimbelParticipant(String participantId) async {
    try {
      await _supabase.from('peserta_bimbel').delete().eq('id', participantId);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'removeBimbelParticipant');
      throw err;
    }
  }

  // ── PESERTA EKSKUL (EKSKUL PARTICIPANTS) ──────────────
  Future<List<EkskulParticipant>> fetchEkskulParticipants(String ekskulId) async {
    try {
      final response = await _supabase
          .from('peserta_ekskul')
          .select('id, ekskul_id, siswa_id, siswa:siswa(*)')
          .eq('ekskul_id', ekskulId);
      return response.map((e) => EkskulParticipant.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchEkskulParticipants');
      throw err;
    }
  }

  Future<void> addEkskulParticipant(String ekskulId, String studentId) async {
    try {
      await _supabase.from('peserta_ekskul').insert({
        'ekskul_id': ekskulId,
        'siswa_id': studentId,
      });
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addEkskulParticipant');
      throw err;
    }
  }

  Future<void> removeEkskulParticipant(String participantId) async {
    try {
      await _supabase.from('peserta_ekskul').delete().eq('id', participantId);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'removeEkskulParticipant');
      throw err;
    }
  }

  Future<List<Student>> searchStudents(String query) async {
    try {
      final response = await _supabase
          .from('siswa')
          .select('*, orang_tua_siswa(orang_tua(*))')
          .or('nama.ilike.%$query%,nis.ilike.%$query%')
          .limit(10);
      return response.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'searchStudents');
      throw err;
    }
  }
}

