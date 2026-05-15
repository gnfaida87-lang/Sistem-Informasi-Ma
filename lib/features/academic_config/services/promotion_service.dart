import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/promotion_models.dart';
import 'package:flutter/foundation.dart';

class PromotionService {
  final _d1Service = D1Service();

  Future<List<PromotionCriteria>> fetchCriteria() async {
    try {
      final sql = "SELECT * FROM promotion_criteria WHERE is_active = 1 ORDER BY category";
      final results = await _d1Service.query(sql);
      return results.map((e) => PromotionCriteria.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchCriteria: $e");
      return [];
    }
  }

  Future<List<Alumni>> fetchAlumni(String query) async {
    try {
      String sql = "SELECT a.*, s.name, s.nis FROM alumni a JOIN students s ON a.student_id = s.id";
      List<dynamic> params = [];
      if (query.isNotEmpty) {
        sql += " WHERE a.last_class_name LIKE ? OR s.name LIKE ?";
        params = ["%$query%", "%$query%"];
      }
      sql += " ORDER BY a.graduation_year DESC";
      
      final results = await _d1Service.query(sql, params: params);
      return results.map((e) => Alumni.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchAlumni: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPromotionEvaluations(String classId) async {
    try {
      final criteria = await fetchCriteria();
      final minAttendance = 85.0; // Default jika kriteria tidak ada
      
      final sqlStudents = "SELECT id, name, nis FROM students WHERE class_id = ? AND is_active = 1";
      final students = await _d1Service.query(sqlStudents, params: [classId]);

      List<Map<String, dynamic>> evaluations = [];

      for (var student in students) {
        final studentId = student['id'];

        // Hitung Absensi
        final sqlAtt = "SELECT status FROM attendance WHERE student_id = ?";
        final attList = await _d1Service.query(sqlAtt, params: [studentId]);
        double attendancePct = 100;
        if (attList.isNotEmpty) {
          final present = attList.where((a) => a['status'] == 'hadir').length;
          attendancePct = (present / attList.length) * 100;
        }

        // Hitung Nilai Tidak Tuntas
        final sqlGrades = "SELECT sg.score, s.min_score FROM student_grades sg JOIN subjects s ON sg.subject_id = s.id WHERE sg.student_id = ?";
        final gradesList = await _d1Service.query(sqlGrades, params: [studentId]);
        int failingSubjects = gradesList.where((s) => (s['score'] as num) < (s['min_score'] as num)).length;

        bool isRecommended = attendancePct >= minAttendance && failingSubjects <= 3;

        evaluations.add({
          'student_id': studentId,
          'name': student['name'],
          'nis': student['nis'],
          'attendance_pct': attendancePct.toStringAsFixed(1),
          'failing_subjects': failingSubjects,
          'is_recommended': isRecommended,
          'manual_status': isRecommended,
        });
      }

      return evaluations;
    } catch (e) {
      debugPrint("Error fetchPromotionEvaluations: $e");
      return [];
    }
  }

  Future<void> addCriteria(PromotionCriteria criteria) async {
    try {
      const sql = "INSERT INTO promotion_criteria (id, title, value, category, is_active) VALUES (?, ?, ?, ?, 1)";
      await _d1Service.query(sql, params: [
        criteria.id ?? 'crit_${DateTime.now().millisecondsSinceEpoch}',
        criteria.title,
        criteria.value,
        criteria.category
      ]);
    } catch (e) {
      debugPrint("Error addCriteria: $e");
      rethrow;
    }
  }

  Future<void> updateCriteria(PromotionCriteria criteria) async {
    try {
      const sql = "UPDATE promotion_criteria SET title = ?, value = ?, category = ? WHERE id = ?";
      await _d1Service.query(sql, params: [criteria.title, criteria.value, criteria.category, criteria.id]);
    } catch (e) {
      debugPrint("Error updateCriteria: $e");
      rethrow;
    }
  }

  Future<void> deleteCriteria(String id) async {
    try {
      const sql = "UPDATE promotion_criteria SET is_active = 0 WHERE id = ?";
      await _d1Service.query(sql, params: [id]);
    } catch (e) {
      debugPrint("Error deleteCriteria: $e");
      rethrow;
    }
  }

  Future<void> executeMassPromotion({
    required List<String> studentIds,
    required String targetClassId,
    required String userId,
    required bool isGraduation,
  }) async {
    try {
      if (isGraduation) {
        for (var id in studentIds) {
          const sqlAlumni = "INSERT INTO alumni (id, student_id, graduation_year, last_class_name) VALUES (?, ?, ?, ?)";
          await _d1Service.query(sqlAlumni, params: [
            'alm_${DateTime.now().millisecondsSinceEpoch}_$id',
            id,
            DateTime.now().year.toString(),
            'Kelas XII'
          ]);
          await _d1Service.query("UPDATE students SET is_active = 0, status = 'alumni' WHERE id = ?", params: [id]);
        }
      } else {
        if (studentIds.isEmpty) return;
        final placeholders = studentIds.map((_) => '?').join(',');
        final sql = "UPDATE students SET class_id = ? WHERE id IN ($placeholders)";
        await _d1Service.query(sql, params: [targetClassId, ...studentIds]);
      }
    } catch (e) {
      debugPrint("Error executeMassPromotion: $e");
      rethrow;
    }
  }
}
