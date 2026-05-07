import '../../../core/network/d1_service.dart';
import '../models/master_models.dart';

class MasterService {
  final _d1Service = D1Service();

  // ══════════════════════════════════════════════════════
  // STEP 8 — TABEL SISWA (STUDENTS)
  // ══════════════════════════════════════════════════════

  Future<List<Student>> fetchAllStudents() async {
    try {
      const sql = """
        SELECT s.id, s.nis, s.name, s.class_id, s.is_active, s.status,
               p.name as parent_name, p.phone as parent_phone
        FROM students s
        LEFT JOIN student_parents sp ON s.id = sp.student_id
        LEFT JOIN parents p ON sp.parent_id = p.id
        ORDER BY s.name
      """;
      final results = await _d1Service.query(sql);
      return results.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchAllStudents: $e");
      return [];
    }
  }

  Future<void> addStudent(Student student) async {
    try {
      final id = student.id.isEmpty
          ? 'stu_${DateTime.now().millisecondsSinceEpoch}'
          : student.id;
      const sql = """
        INSERT INTO students (id, nis, name, class_id, is_active, status)
        VALUES (?, ?, ?, ?, 1, 'active')
      """;
      await _d1Service.query(sql, params: [id, student.nis, student.name, student.classId]);
    } catch (e) {
      print("Error addStudent: $e");
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      const sql = """
        UPDATE students SET nis = ?, name = ?, class_id = ? WHERE id = ?
      """;
      await _d1Service.query(sql, params: [student.nis, student.name, student.classId, student.id]);
    } catch (e) {
      print("Error updateStudent: $e");
      rethrow;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _d1Service.query("UPDATE students SET is_active = 0 WHERE id = ?", params: [id]);
    } catch (e) {
      print("Error deleteStudent: $e");
      rethrow;
    }
  }

  Future<List<Student>> searchStudents(String query) async {
    try {
      const sql = """
        SELECT s.id, s.nis, s.name, s.class_id, s.is_active, s.status
        FROM students s
        WHERE s.name LIKE ? OR s.nis LIKE ?
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
      const sql = "SELECT id, nip, name as nama, is_wali_kelas, is_active FROM teachers ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((e) => Teacher.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchAllTeachers: $e");
      return [];
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    try {
      final id = teacher.id.isEmpty
          ? 'tch_${DateTime.now().millisecondsSinceEpoch}'
          : teacher.id;
      const sql = """
        INSERT INTO teachers (id, nip, name, is_wali_kelas, is_active)
        VALUES (?, ?, ?, ?, 1)
      """;
      await _d1Service.query(sql, params: [id, teacher.nip, teacher.name, teacher.isWaliKelas ? 1 : 0]);
    } catch (e) {
      print("Error addTeacher: $e");
      rethrow;
    }
  }

  Future<void> updateTeacher(Teacher teacher) async {
    try {
      const sql = """
        UPDATE teachers SET nip = ?, name = ?, is_wali_kelas = ? WHERE id = ?
      """;
      await _d1Service.query(sql, params: [teacher.nip, teacher.name, teacher.isWaliKelas ? 1 : 0, teacher.id]);
    } catch (e) {
      print("Error updateTeacher: $e");
      rethrow;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      // Soft delete agar data historis terjaga
      await _d1Service.query("UPDATE teachers SET is_active = 0 WHERE id = ?", params: [id]);
    } catch (e) {
      print("Error deleteTeacher: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL KELAS (CLASSES)
  // ══════════════════════════════════════════════════════

  Future<List<ClassRoom>> fetchAllClasses() async {
    try {
      const sql = "SELECT id, name as nama, teacher_id as wali_kelas_id FROM classes ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((e) => ClassRoom.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchAllClasses: $e");
      return [];
    }
  }

  Future<void> addClass(ClassRoom kelas) async {
    try {
      final id = kelas.id.isEmpty
          ? 'cls_${DateTime.now().millisecondsSinceEpoch}'
          : kelas.id;
      const sql = "INSERT INTO classes (id, name, teacher_id) VALUES (?, ?, ?)";
      await _d1Service.query(sql, params: [id, kelas.name, kelas.waliKelasId]);
    } catch (e) {
      print("Error addClass: $e");
      rethrow;
    }
  }

  Future<void> updateClass(ClassRoom kelas) async {
    try {
      const sql = "UPDATE classes SET name = ?, teacher_id = ? WHERE id = ?";
      await _d1Service.query(sql, params: [kelas.name, kelas.waliKelasId, kelas.id]);
    } catch (e) {
      print("Error updateClass: $e");
      rethrow;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await _d1Service.query("DELETE FROM classes WHERE id = ?", params: [id]);
    } catch (e) {
      print("Error deleteClass: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL MAPEL (SUBJECTS)
  // ══════════════════════════════════════════════════════

  Future<List<Subject>> fetchAllSubjects() async {
    try {
      const sql = "SELECT id, code as kode, name as nama, min_score as kkm FROM subjects ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((e) => Subject.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchAllSubjects: $e");
      return [];
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      final id = subject.id.isEmpty
          ? 'subj_${DateTime.now().millisecondsSinceEpoch}'
          : subject.id;
      const sql = "INSERT INTO subjects (id, code, name, min_score) VALUES (?, ?, ?, ?)";
      await _d1Service.query(sql, params: [id, subject.code, subject.name, subject.kkm]);
    } catch (e) {
      print("Error addSubject: $e");
      rethrow;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      const sql = "UPDATE subjects SET code = ?, name = ?, min_score = ? WHERE id = ?";
      await _d1Service.query(sql, params: [subject.code, subject.name, subject.kkm, subject.id]);
    } catch (e) {
      print("Error updateSubject: $e");
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _d1Service.query("DELETE FROM subjects WHERE id = ?", params: [id]);
    } catch (e) {
      print("Error deleteSubject: $e");
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL JURUSAN (MAJORS)
  // ══════════════════════════════════════════════════════

  Future<List<Major>> fetchAllMajors() async {
    try {
      const sql = "SELECT id, code as kode, name as nama FROM majors ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((e) => Major.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchAllMajors: $e");
      return [];
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL TAHUN AJARAN (ACADEMIC YEARS)
  // ══════════════════════════════════════════════════════

  Future<List<AcademicYear>> fetchAllAcademicYears() async {
    try {
      const sql = "SELECT id, year_name as tahun, is_active FROM academic_years ORDER BY year_name DESC";
      final results = await _d1Service.query(sql);
      return results.map((e) => AcademicYear.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchAllAcademicYears: $e");
      return [];
    }
  }

  Future<AcademicYear?> fetchActiveAcademicYear() async {
    try {
      const sql = "SELECT id, year_name as tahun, is_active FROM academic_years WHERE is_active = 1 LIMIT 1";
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
      const sql = "SELECT id, name as nama, coach as pembina FROM extracurriculars ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((e) => Extracurricular.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchAllEkskul: $e");
      return [];
    }
  }

  Future<List<EkskulParticipant>> fetchEkskulParticipants(String ekskulId) async {
    try {
      const sql = """
        SELECT ep.id, ep.extracurricular_id as ekskul_id, ep.student_id as siswa_id,
               s.name as siswa_nama, s.nis as siswa_nis
        FROM extracurricular_participants ep
        JOIN students s ON ep.student_id = s.id
        WHERE ep.extracurricular_id = ?
        ORDER BY s.name
      """;
      final results = await _d1Service.query(sql, params: [ekskulId]);
      return results.map((e) => EkskulParticipant.fromJson({
        ...e,
        'siswa': {'id': e['siswa_id'], 'nama': e['siswa_nama'], 'nis': e['siswa_nis']},
      })).toList();
    } catch (e) {
      print("Error fetchEkskulParticipants: $e");
      return [];
    }
  }

  // ══════════════════════════════════════════════════════
  // TABEL BIMBEL (TUTORING)
  // ══════════════════════════════════════════════════════

  Future<List<Tutoring>> fetchAllBimbel() async {
    try {
      const sql = "SELECT id, name as nama, teacher_id as guru_id FROM tutoring_programs ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((e) => Tutoring.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchAllBimbel: $e");
      return [];
    }
  }

  Future<List<BimbelParticipant>> fetchBimbelParticipants(String bimbelId) async {
    try {
      const sql = """
        SELECT bp.id, bp.program_id, bp.student_id as siswa_id,
               s.name as siswa_nama, s.nis as siswa_nis
        FROM tutoring_participants bp
        JOIN students s ON bp.student_id = s.id
        WHERE bp.program_id = ?
        ORDER BY s.name
      """;
      final results = await _d1Service.query(sql, params: [bimbelId]);
      return results.map((e) => BimbelParticipant.fromJson({
        ...e,
        'bimbel_id': bimbelId,
        'siswa': {'id': e['siswa_id'], 'nama': e['siswa_nama'], 'nis': e['siswa_nis']},
      })).toList();
    } catch (e) {
      print("Error fetchBimbelParticipants: $e");
      return [];
    }
  }
}
