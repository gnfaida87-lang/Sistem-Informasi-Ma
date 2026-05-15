import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/master_models.dart';
import 'package:flutter/foundation.dart';

class MasterService {
  final _d1Service = D1Service();

  // ══════════════════════════════════════════════════════
  // STEP 8 — TABEL SISWA (STUDENTS)
  // ══════════════════════════════════════════════════════

  Future<List<Student>> fetchAllStudents() async {
    try {
      const sql = """
        SELECT s.id, s.nis, s.nama, s.kelas_id, s.status, s.is_active
        FROM students s
        ORDER BY s.nama
      """;
      final results = await _d1Service.query(sql);
      return results.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAllStudents: $e");
      return [];
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      final id = student.id.isEmpty
          ? 'stu_${DateTime.now().millisecondsSinceEpoch}'
          : student.id;
      
      // 1. Simpan ke tabel students
      const sqlStudent = """
        INSERT INTO students (id, nis, nama, kelas_id, status, is_active, nama_wali, no_hp)
        VALUES (?, ?, ?, ?, 'active', 1, ?, ?)
      """;
      await _d1Service.query(sqlStudent, params: [
        id, 
        student.nis, 
        student.name, 
        student.classId,
        student.parentName,
        student.phone
      ]);

      // 2. Buat otomatis akun Orang Tua
      // Username menggunakan NISN siswa
      const sqlUser = """
        INSERT INTO users (id, username, password, role, ref_id, is_active)
        VALUES (?, ?, ?, 'parent', ?, 1)
      """;
      
      await _d1Service.query(sqlUser, params: [
        'usr_${DateTime.now().millisecondsSinceEpoch + 1}',
        student.nis,
        'madrasah123', // Password default
        id // Hubungkan ke ID siswa (sebagai wali dari siswa ini)
      ]);

    } catch (e) {
      debugPrint("Error addStudent: $e");
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      const sql = """
        UPDATE students 
        SET nis = ?, nama = ?, kelas_id = ?, nama_wali = ?, no_hp = ? 
        WHERE id = ?
      """;
      await _d1Service.query(sql, params: [
        student.nis, 
        student.name, 
        student.classId, 
        student.parentName,
        student.phone,
        student.id
      ]);
    } catch (e) {
      debugPrint("Error updateStudent: $e");
      rethrow;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _d1Service.query("UPDATE students SET is_active = 0 WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteStudent: $e");
      rethrow;
    }
  }

  Future<List<Student>> searchStudents(String query) async {
    try {
      const sql = """
        SELECT s.id, s.nis, s.nama, s.kelas_id, s.status, s.is_active
        FROM students s
        WHERE s.nama LIKE ? OR s.nis LIKE ?
        LIMIT 20
      """;
      final results = await _d1Service.query(sql, params: ["%$query%", "%$query%"]);
      return results.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // ══════════════════════════════════════════════════════
  // STEP 8 — TABEL GURU (TEACHERS)
  // ══════════════════════════════════════════════════════

  Future<List<Teacher>> fetchAllTeachers() async {
    try {
      const sql = "SELECT id, nip, nama, is_wali_kelas, is_active FROM teachers ORDER BY nama";
      final results = await _d1Service.query(sql);
      return results.map((e) => Teacher.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAllTeachers: $e");
      return [];
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    try {
      final id = teacher.id.isEmpty
          ? 'tch_${DateTime.now().millisecondsSinceEpoch}'
          : teacher.id;
      
      // 1. Simpan data guru ke tabel teachers
      const sqlTeacher = """
        INSERT INTO teachers (id, nip, nama, is_wali_kelas, is_active)
        VALUES (?, ?, ?, ?, 1)
      """;
      await _d1Service.query(sqlTeacher, params: [id, teacher.nip, teacher.name, teacher.isWaliKelas ? 1 : 0]);

      // 2. Buat otomatis akun user login
      // Username menggunakan NIP jika ada, jika tidak gunakan nama tanpa spasi
      final username = (teacher.nip != null && teacher.nip!.isNotEmpty) 
          ? teacher.nip 
          : teacher.name.replaceAll(' ', '').toLowerCase();
      
      const sqlUser = """
        INSERT INTO users (id, username, password, role, ref_id, is_active)
        VALUES (?, ?, ?, 'teacher', ?, 1)
      """;
      
      await _d1Service.query(sqlUser, params: [
        'usr_${DateTime.now().millisecondsSinceEpoch}',
        username,
        'madrasah123', // Password default
        id // Menghubungkan user ke ID guru
      ]);
      
    } catch (e) {
      debugPrint("Error addTeacher with Account Creation: $e");
      rethrow;
    }
  }

  Future<void> updateTeacher(Teacher teacher) async {
    try {
      const sql = """
        UPDATE teachers SET nip = ?, nama = ?, is_wali_kelas = ? WHERE id = ?
      """;
      await _d1Service.query(sql, params: [teacher.nip, teacher.name, teacher.isWaliKelas ? 1 : 0, teacher.id]);
    } catch (e) {
      debugPrint("Error updateTeacher: $e");
      rethrow;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      // Soft delete agar data historis terjaga
      await _d1Service.query("UPDATE teachers SET is_active = 0 WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteTeacher: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL KELAS (CLASSES)
  // ══════════════════════════════════════════════════════

  Future<List<ClassRoom>> fetchAllClasses() async {
    try {
      const sql = """
        SELECT 
          c.id, 
          c.nama, 
          c.wali_kelas_id,
          t.nama as wali_kelas_nama,
          (SELECT COUNT(*) FROM students s WHERE s.kelas_id = c.id AND s.is_active = 1) as jumlah_siswa,
          c.kapasitas
        FROM classes c
        LEFT JOIN teachers t ON c.wali_kelas_id = t.id
        ORDER BY c.nama
      """;
      final results = await _d1Service.query(sql);
      return results.map((e) => ClassRoom.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAllClasses: $e");
      return [];
    }
  }

  Future<void> addClass(ClassRoom kelas) async {
    try {
      final id = kelas.id.isEmpty
          ? 'cls_${DateTime.now().millisecondsSinceEpoch}'
          : kelas.id;
      const sql = "INSERT INTO classes (id, nama, wali_kelas_id) VALUES (?, ?, ?)";
      await _d1Service.query(sql, params: [id, kelas.name, kelas.waliKelasId]);
    } catch (e) {
      debugPrint("Error addClass: $e");
      rethrow;
    }
  }

  Future<void> updateClass(ClassRoom kelas) async {
    try {
      const sql = "UPDATE classes SET nama = ?, wali_kelas_id = ? WHERE id = ?";
      await _d1Service.query(sql, params: [kelas.name, kelas.waliKelasId, kelas.id]);
    } catch (e) {
      debugPrint("Error updateClass: $e");
      rethrow;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await _d1Service.query("DELETE FROM classes WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteClass: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL MAPEL (SUBJECTS)
  // ══════════════════════════════════════════════════════

  Future<List<Subject>> fetchAllSubjects() async {
    try {
      const sql = "SELECT id, kode, nama, kkm FROM subjects ORDER BY nama";
      final results = await _d1Service.query(sql);
      return results.map((e) => Subject.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAllSubjects: $e");
      return [];
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      final id = subject.id.isEmpty
          ? 'subj_${DateTime.now().millisecondsSinceEpoch}'
          : subject.id;
      const sql = "INSERT INTO subjects (id, kode, nama, kkm) VALUES (?, ?, ?, ?)";
      await _d1Service.query(sql, params: [id, subject.code, subject.name, subject.kkm]);
    } catch (e) {
      debugPrint("Error addSubject: $e");
      rethrow;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      const sql = "UPDATE subjects SET kode = ?, nama = ?, kkm = ? WHERE id = ?";
      await _d1Service.query(sql, params: [subject.code, subject.name, subject.kkm, subject.id]);
    } catch (e) {
      debugPrint("Error updateSubject: $e");
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _d1Service.query("DELETE FROM subjects WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteSubject: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL JURUSAN (MAJORS)
  // ══════════════════════════════════════════════════════

  Future<List<Major>> fetchAllMajors() async {
    try {
      const sql = "SELECT id, kode, nama FROM departments ORDER BY nama";
      final results = await _d1Service.query(sql);
      return results.map((e) => Major.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAllMajors: $e");
      return [];
    }
  }

  Future<void> addMajor(Major major) async {
    try {
      final id = major.id.isEmpty ? 'mjr_${DateTime.now().millisecondsSinceEpoch}' : major.id;
      const sql = "INSERT INTO departments (id, kode, nama) VALUES (?, ?, ?)";
      await _d1Service.query(sql, params: [id, major.code, major.name]);
    } catch (e) {
      debugPrint("Error addMajor: $e");
      rethrow;
    }
  }

  Future<void> updateMajor(Major major) async {
    try {
      const sql = "UPDATE departments SET kode = ?, nama = ? WHERE id = ?";
      await _d1Service.query(sql, params: [major.code, major.name, major.id]);
    } catch (e) {
      debugPrint("Error updateMajor: $e");
      rethrow;
    }
  }

  Future<void> deleteMajor(String id) async {
    try {
      await _d1Service.query("DELETE FROM departments WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteMajor: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL TAHUN AJARAN (ACADEMIC YEARS)
  // ══════════════════════════════════════════════════════

  Future<List<AcademicYear>> fetchAllAcademicYears() async {
    try {
      const sql = "SELECT id, tahun, is_active FROM academic_years ORDER BY tahun DESC";
      final results = await _d1Service.query(sql);
      return results.map((e) => AcademicYear.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAllAcademicYears: $e");
      return [];
    }
  }

  Future<void> addAcademicYear(AcademicYear year) async {
    try {
      final id = year.id.isEmpty ? 'ay_${DateTime.now().millisecondsSinceEpoch}' : year.id;
      const sql = "INSERT INTO academic_years (id, tahun, is_active) VALUES (?, ?, ?)";
      await _d1Service.query(sql, params: [id, year.year, year.isActive ? 1 : 0]);
    } catch (e) {
      debugPrint("Error addAcademicYear: $e");
      rethrow;
    }
  }

  Future<void> updateAcademicYear(AcademicYear year) async {
    try {
      const sql = "UPDATE academic_years SET tahun = ?, is_active = ? WHERE id = ?";
      await _d1Service.query(sql, params: [year.year, year.isActive ? 1 : 0, year.id]);
    } catch (e) {
      debugPrint("Error updateAcademicYear: $e");
      rethrow;
    }
  }

  Future<void> setActiveAcademicYear(String id) async {
    try {
      // Nonaktifkan semua tahun ajaran terlebih dahulu
      await _d1Service.query("UPDATE academic_years SET is_active = 0");
      // Aktifkan hanya tahun ajaran yang dipilih
      await _d1Service.query("UPDATE academic_years SET is_active = 1 WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error setActiveAcademicYear: $e");
      rethrow;
    }
  }

  Future<void> deleteAcademicYear(String id) async {
    try {
      await _d1Service.query("DELETE FROM academic_years WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteAcademicYear: $e");
      rethrow;
    }
  }

  Future<AcademicYear?> fetchActiveAcademicYear() async {
    try {
      const sql = "SELECT id, tahun, is_active FROM academic_years WHERE is_active = 1 LIMIT 1";
      final results = await _d1Service.query(sql);
      return results.isNotEmpty ? AcademicYear.fromJson(results.first) : null;
    } catch (e) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL EKSKUL (EXTRACURRICULARS)
  // ══════════════════════════════════════════════════════

  Future<List<Extracurricular>> fetchAllEkskul() async {
    try {
      const sql = "SELECT id, nama, pembina FROM ekskul ORDER BY nama";
      final results = await _d1Service.query(sql);
      return results.map((e) => Extracurricular.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAllEkskul: $e");
      return [];
    }
  }

  Future<void> addEkskul(Extracurricular ekskul) async {
    try {
      final id = ekskul.id.isEmpty ? 'ex_${DateTime.now().millisecondsSinceEpoch}' : ekskul.id;
      const sql = "INSERT INTO ekskul (id, nama, pembina) VALUES (?, ?, ?)";
      await _d1Service.query(sql, params: [id, ekskul.name, ekskul.coach]);
    } catch (e) {
      debugPrint("Error addEkskul: $e");
      rethrow;
    }
  }

  Future<void> updateEkskul(Extracurricular ekskul) async {
    try {
      const sql = "UPDATE ekskul SET nama = ?, pembina = ? WHERE id = ?";
      await _d1Service.query(sql, params: [ekskul.name, ekskul.coach, ekskul.id]);
    } catch (e) {
      debugPrint("Error updateEkskul: $e");
      rethrow;
    }
  }

  Future<void> deleteEkskul(String id) async {
    try {
      await _d1Service.query("DELETE FROM ekskul WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteEkskul: $e");
      rethrow;
    }
  }

  Future<List<EkskulParticipant>> fetchEkskulParticipants(String ekskulId) async {
    try {
      const sql = """
        SELECT ep.id, ep.ekskul_id, ep.siswa_id,
               s.nama as siswa_nama, s.nis as siswa_nis
        FROM ekskul_participants ep
        JOIN students s ON ep.siswa_id = s.id
        WHERE ep.ekskul_id = ?
        ORDER BY s.nama
      """;
      final results = await _d1Service.query(sql, params: [ekskulId]);
      return results.map((e) => EkskulParticipant.fromJson({
        ...e,
        'siswa': {'id': e['siswa_id'], 'nama': e['siswa_nama'], 'nis': e['siswa_nis']},
      })).toList();
    } catch (e) {
      debugPrint("Error fetchEkskulParticipants: $e");
      return [];
    }
  }

  Future<void> addEkskulParticipant(String ekskulId, String studentId) async {
    try {
      const sql = "INSERT INTO ekskul_participants (id, ekskul_id, siswa_id) VALUES (?, ?, ?)";
      await _d1Service.query(sql, params: [
        'ep_${DateTime.now().millisecondsSinceEpoch}',
        ekskulId,
        studentId
      ]);
    } catch (e) {
      debugPrint("Error addEkskulParticipant: $e");
      rethrow;
    }
  }

  Future<void> removeEkskulParticipant(String participantId) async {
    try {
      await _d1Service.query("DELETE FROM ekskul_participants WHERE id = ?", params: [participantId]);
    } catch (e) {
      debugPrint("Error removeEkskulParticipant: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL BIMBEL (TUTORING)
  // ══════════════════════════════════════════════════════

  Future<List<Tutoring>> fetchAllBimbel() async {
    try {
      const sql = "SELECT id, nama, guru_id FROM bimbel_programs ORDER BY nama";
      final results = await _d1Service.query(sql);
      return results.map((e) => Tutoring.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAllBimbel: $e");
      return [];
    }
  }

  Future<void> addBimbel(Tutoring bimbel) async {
    try {
      final id = bimbel.id.isEmpty ? 'tut_${DateTime.now().millisecondsSinceEpoch}' : bimbel.id;
      const sql = "INSERT INTO bimbel_programs (id, nama, guru_id) VALUES (?, ?, ?)";
      await _d1Service.query(sql, params: [id, bimbel.name, bimbel.teacherId]);
    } catch (e) {
      debugPrint("Error addBimbel: $e");
      rethrow;
    }
  }

  Future<void> updateBimbel(Tutoring bimbel) async {
    try {
      const sql = "UPDATE bimbel_programs SET nama = ?, guru_id = ? WHERE id = ?";
      await _d1Service.query(sql, params: [bimbel.name, bimbel.teacherId, bimbel.id]);
    } catch (e) {
      debugPrint("Error updateBimbel: $e");
      rethrow;
    }
  }

  Future<void> deleteBimbel(String id) async {
    try {
      await _d1Service.query("DELETE FROM bimbel_programs WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteBimbel: $e");
      rethrow;
    }
  }

  Future<void> addBimbelParticipant(String bimbelId, String studentId) async {
    try {
      const sql = "INSERT INTO bimbel_participants (id, program_id, siswa_id) VALUES (?, ?, ?)";
      final id = 'tp_${DateTime.now().millisecondsSinceEpoch}';
      await _d1Service.query(sql, params: [id, bimbelId, studentId]);
    } catch (e) {
      debugPrint("Error addBimbelParticipant: $e");
      rethrow;
    }
  }

  Future<void> removeBimbelParticipant(String participantId) async {
    try {
      const sql = "DELETE FROM bimbel_participants WHERE id = ?";
      await _d1Service.query(sql, params: [participantId]);
    } catch (e) {
      debugPrint("Error removeBimbelParticipant: $e");
      rethrow;
    }
  }

  Future<List<BimbelParticipant>> fetchBimbelParticipants(String bimbelId) async {
    try {
      const sql = """
        SELECT bp.id, bp.program_id, bp.siswa_id,
               s.nama as siswa_nama, s.nis as siswa_nis
        FROM bimbel_participants bp
        JOIN students s ON bp.siswa_id = s.id
        WHERE bp.program_id = ?
        ORDER BY s.nama
      """;
      final results = await _d1Service.query(sql, params: [bimbelId]);
      return results.map((e) => BimbelParticipant.fromJson({
        ...e,
        'bimbel_id': bimbelId,
        'siswa': {'id': e['siswa_id'], 'nama': e['siswa_nama'], 'nis': e['siswa_nis']},
      })).toList();
    } catch (e) {
      debugPrint("Error fetchBimbelParticipants: $e");
      return [];
    }
  }
}
