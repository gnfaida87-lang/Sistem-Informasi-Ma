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

  Future<double> getSppAmount(String? levelStr) async {
    // Sederhanakan logic nominal SPP berdasarkan tingkatan
    final level = int.tryParse(levelStr ?? '') ?? (levelStr == 'X' ? 10 : levelStr == 'XI' ? 11 : levelStr == 'XII' ? 12 : 10);
    switch (level) {
      case 10: return 250000;
      case 11: return 275000;
      case 12: return 300000;
      default: return 250000;
    }
  }

  Future<List<OtherFee>> fetchOtherFees() async {
    try {
      const sql = "SELECT * FROM other_fees ORDER BY due_date DESC";
      final results = await _d1Service.query(sql);
      return results.map((e) => OtherFee.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchOtherFees: $e");
      return [];
    }
  }

  Future<void> payOtherFee(String feeId) async {
    try {
      const sql = "UPDATE other_fees SET status = 'lunas' WHERE id = ?";
      await _d1Service.query(sql, params: [feeId]);
    } catch (e) {
      print("Error payOtherFee: $e");
      rethrow;
    }
  }

  Future<List<OperationalExpense>> fetchOperationalExpenses() async {
    try {
      const sql = "SELECT * FROM operational_expenses ORDER BY date DESC";
      final results = await _d1Service.query(sql);
      return results.map((e) => OperationalExpense.fromJson(e)).toList();
    } catch (e) {
      print("Error fetchOperationalExpenses: $e");
      return [];
    }
  }

  Future<void> addOperationalExpense(OperationalExpense expense) async {
    try {
      const sql = "INSERT INTO operational_expenses (id, description, amount, date, category) VALUES (?, ?, ?, ?, ?)";
      await _d1Service.query(sql, params: [
        expense.id,
        expense.description,
        expense.amount,
        expense.date.toIso8601String(),
        expense.category
      ]);
    } catch (e) {
      print("Error addOperationalExpense: $e");
      rethrow;
    }
  }

  Future<void> updateOperationalExpense(OperationalExpense expense) async {
    try {
      const sql = "UPDATE operational_expenses SET description = ?, amount = ?, date = ?, category = ? WHERE id = ?";
      await _d1Service.query(sql, params: [
        expense.description,
        expense.amount,
        expense.date.toIso8601String(),
        expense.category,
        expense.id
      ]);
    } catch (e) {
      print("Error updateOperationalExpense: $e");
      rethrow;
    }
  }

  Future<void> deleteOperationalExpense(String id) async {
    try {
      await _d1Service.query("DELETE FROM operational_expenses WHERE id = ?", params: [id]);
    } catch (e) {
      print("Error deleteOperationalExpense: $e");
      rethrow;
    }
  }

  Future<void> addSavings(Savings savings) async {
    try {
      const sql = "INSERT INTO savings (id, student_id, amount, saved_at, type) VALUES (?, ?, ?, ?, ?)";
      await _d1Service.query(sql, params: [
        savings.id,
        savings.studentId,
        savings.amount,
        savings.savedAt.toIso8601String(),
        savings.type
      ]);
    } catch (e) {
      print("Error addSavings: $e");
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
