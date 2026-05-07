import '../../../core/network/d1_service.dart';
import '../models/finance_models.dart';

class FinanceService {
  final _d1Service = D1Service();

  Future<List<SppRecord>> fetchSppByStudent(String studentId) async {
    try {
      final sql = """
        SELECT sr.*, s.name as student_name
        FROM spp_records sr
        JOIN students s ON sr.student_id = s.id
        WHERE sr.student_id = ?
        ORDER BY sr.paid_at DESC
      """;
      final results = await _d1Service.query(sql, params: [studentId]);
      return results.map((e) => SppRecord.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchSppByStudent: $e");
      return [];
    }
  }

  Future<void> addSppPayment(SppRecord record) async {
    try {
      final sql = """
        INSERT INTO spp_records (id, student_id, month, year, amount, status, paid_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      """;
      await _d1Service.query(sql, params: [
        record.id,
        record.studentId,
        record.month,
        record.year,
        record.amount,
        record.status,
        record.paidAt?.toIso8601String()
      ]);
    } catch (e) {
      print("Error addSppPayment: $e");
      rethrow;
    }
  }

  Future<List<Savings>> fetchSavingsByStudent(String studentId) async {
    try {
      final sql = """
        SELECT sv.*, s.name as student_name
        FROM savings sv
        JOIN students s ON sv.student_id = s.id
        WHERE sv.student_id = ?
        ORDER BY sv.saved_at DESC
      """;
      final results = await _d1Service.query(sql, params: [studentId]);
      return results.map((e) => Savings.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchSavingsByStudent: $e");
      return [];
    }
  }

  Future<FinanceReport> fetchFinanceReport() async {
    try {
      final now = DateTime.now();
      
      final sppSum = await _d1Service.query("SELECT SUM(amount) as total FROM spp_records WHERE status = 'lunas'");
      final savingsSum = await _d1Service.query("SELECT SUM(amount) as total FROM savings WHERE type = 'setor'");
      final otherSum = await _d1Service.query("SELECT SUM(amount) as total FROM other_fees WHERE status = 'lunas'");
      final expSum = await _d1Service.query("SELECT SUM(amount) as total FROM operational_expenses");

      return FinanceReport(
        totalSppIn: (sppSum.first['total'] ?? 0).toDouble(),
        totalSavings: (savingsSum.first['total'] ?? 0).toDouble(),
        totalOtherFees: (otherSum.first['total'] ?? 0).toDouble(),
        totalExpenses: (expSum.first['total'] ?? 0).toDouble(),
        month: now.month.toString().padLeft(2, '0'),
        year: now.year.toString(),
      );
    } catch (e) {
      print("Error fetchFinanceReport: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveStudentsForPayment() async {
    try {
      final sql = """
        SELECT s.id, s.nis, s.name as nama, c.name as kelas_nama
        FROM students s
        JOIN classes c ON s.class_id = c.id
        WHERE s.is_active = 1
        ORDER BY s.name
      """;
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      print("Error fetchActiveStudentsForPayment: $e");
      return [];
    }
  }
}
