import '../../../core/network/d1_service.dart';
import '../models/academic_models.dart';

class AcademicService {
  final _d1Service = D1Service();

  // ── SEMESTER / TAHUN AJARAN ───────────────────────────
  Future<List<Semester>> getActiveSemesters() async {
    try {
      // D1 (SQLite): flat JOIN query, bukan nested object
      const sql = """
        SELECT s.*, ay.year_name as tahun_ajaran_nama
        FROM semesters s
        LEFT JOIN academic_years ay ON s.academic_year_id = ay.id
        ORDER BY ay.year_name DESC, s.name ASC
      """;
      final results = await _d1Service.query(sql);
      return results.map((json) => Semester.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error getActiveSemesters: $e");
      // Fallback: langsung dari academic_years jika tabel semesters belum ada
      return _getFallbackFromAcademicYears();
    }
  }

  Future<List<Semester>> _getFallbackFromAcademicYears() async {
    try {
      const sql = """
        SELECT id, year_name as nama, is_active, 75 as kkm_default, 0 as is_validated,
               NULL as validated_by, year_name as tahun_ajaran_nama
        FROM academic_years
        ORDER BY year_name DESC
      """;
      final results = await _d1Service.query(sql);
      return results.map((json) => Semester.fromFlatJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error _getFallbackFromAcademicYears: $e");
      return [];
    }
  }

  Future<bool> validateSemester(String semesterId, String userId) async {
    try {
      // Coba update tabel semesters dulu, fallback ke academic_years
      try {
        const sql = "UPDATE semesters SET is_validated = 1, validated_by = ? WHERE id = ?";
        await _d1Service.query(sql, params: [userId, semesterId]);
      } catch (_) {
        const sql = "UPDATE academic_years SET is_active = 1 WHERE id = ?";
        await _d1Service.query(sql, params: [semesterId]);
      }
      return true;
    } catch (e) {
      print("Error validateSemester: $e");
      return false;
    }
  }

  Future<bool> validateAllActiveSemesters(String userId) async {
    try {
      try {
        const sql = "UPDATE semesters SET is_validated = 1, validated_by = ? WHERE is_active = 1";
        await _d1Service.query(sql, params: [userId]);
      } catch (_) {
        const sql = "UPDATE academic_years SET is_active = 1";
        await _d1Service.query(sql, params: []);
      }
      return true;
    } catch (e) {
      print("Error validateAllActiveSemesters: $e");
      return false;
    }
  }

  // ── DEPARTMENTS / JURUSAN ─────────────────────────────
  Future<List<Department>> getDepartments() async {
    try {
      const sql = "SELECT id, code as kode, name as nama FROM departments ORDER BY name";
      final results = await _d1Service.query(sql);
      return results.map((map) => Department.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error getDepartments: $e");
      return [];
    }
  }

  Future<void> addDepartment(String code, String name) async {
    final id = 'dept_${DateTime.now().millisecondsSinceEpoch}';
    const sql = "INSERT INTO departments (id, code, name) VALUES (?, ?, ?)";
    await _d1Service.query(sql, params: [id, code, name]);
  }

  Future<void> updateDepartment(String id, String code, String name) async {
    const sql = "UPDATE departments SET code = ?, name = ? WHERE id = ?";
    await _d1Service.query(sql, params: [code, name, id]);
  }

  Future<void> deleteDepartment(String id) async {
    await _d1Service.query("DELETE FROM departments WHERE id = ?", params: [id]);
  }

  // ── DROPDOWN HELPERS ──────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchStudentsForDropdown() async {
    try {
      const sql = "SELECT id, nis, name as nama, class_id as kelas_id FROM students WHERE is_active = 1 ORDER BY name";
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchStudentsForDropdown: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTeachersForDropdown() async {
    try {
      const sql = "SELECT id, nip, name as nama FROM teachers ORDER BY name";
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchTeachersForDropdown: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchClassesForDropdown() async {
    try {
      const sql = "SELECT id, name as nama FROM classes ORDER BY name";
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchClassesForDropdown: $e");
      return [];
    }
  }
}
