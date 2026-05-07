import '../../../core/network/d1_service.dart';
import '../models/academic_models.dart';

class AcademicService {
  final _d1Service = D1Service();

  Future<List<Semester>> getActiveSemesters() async {
    try {
      final sql = """
        SELECT ay.*, ay.year_name as tahun
        FROM academic_years ay
        ORDER BY ay.id DESC
        LIMIT 20
      """;
      final results = await _d1Service.query(sql);
      return results.map((json) => Semester.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error getActiveSemesters: $e");
      return [];
    }
  }

  Future<bool> validateSemester(String semesterId, String userId) async {
    try {
      final sql = "UPDATE academic_years SET is_validated = 1, validated_by = ? WHERE id = ?";
      await _d1Service.query(sql, params: [userId, semesterId]);
      return true;
    } catch (e) {
      print("Error validateSemester: $e");
      return false;
    }
  }

  Future<List<Department>> getDepartments() async {
    try {
      final sql = "SELECT * FROM departments LIMIT 10";
      final results = await _d1Service.query(sql);
      return results.map((map) => Department.fromJson(map as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error getDepartments: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchStudentsForDropdown() async {
    try {
      final sql = "SELECT id, nis, name as nama, class_id as kelas_id FROM students WHERE is_active = 1 ORDER BY name";
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchStudentsForDropdown: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTeachersForDropdown() async {
    try {
      final sql = "SELECT id, nip, name as nama FROM teachers ORDER BY name";
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchTeachersForDropdown: $e");
      return [];
    }
  }
}
