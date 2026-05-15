import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/finance_models.dart';
import 'package:flutter/foundation.dart';

class FinanceService {
  final _d1Service = D1Service();

  Future<List<SppRecord>> fetchSppByStudent(String studentId) async {
    try {
      final sql = """
        SELECT sr.*, s.nama as student_name
        FROM pembayaran_spp sr
        JOIN students s ON sr.siswa_id = s.id
        WHERE sr.siswa_id = ?
        ORDER BY sr.tanggal_bayar DESC
      """;
      final results = await _d1Service.query(sql, params: [studentId]);
      return results.map((e) => SppRecord.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchSppByStudent: $e");
      return [];
    }
  }

  Future<void> addSppPayment(SppRecord record) async {
    try {
      await _ensureFinanceColumns();
      final sql = """
        INSERT INTO pembayaran_spp (id, siswa_id, bulan, tahun, amount, status, tanggal_bayar)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      """;
      final id = "SPP_${DateTime.now().millisecondsSinceEpoch}";
      await _d1Service.query(sql, params: [
        id,
        record.studentId,
        record.month,
        record.year,
        record.amount,
        record.status,
        record.paidAt.toIso8601String()
      ]);

      // Kirim Notifikasi
      await _sendPaymentNotification(
        studentId: record.studentId,
        title: 'Pembayaran SPP Berhasil',
        content: 'Pembayaran SPP untuk bulan ${record.month} ${record.year} sebesar Rp ${record.amount.toStringAsFixed(0)} telah diterima. Terima kasih.',
      );
    } catch (e) {
      debugPrint("Error addSppPayment: $e");
      rethrow;
    }
  }

  Future<void> _sendPaymentNotification({
    required String studentId,
    required String title,
    required String content,
  }) async {
    try {
      final id = "NOTIF_${DateTime.now().millisecondsSinceEpoch}";
      final sql = """
        INSERT INTO announcements (id, title, content, target_role, created_at)
        VALUES (?, ?, ?, 'orang_tua', ?)
      """;
      await _d1Service.query(sql, params: [
        id,
        title,
        "[$studentId] $content", // Prefix dengan studentId agar bisa difilter di sisi orang tua jika perlu
        DateTime.now().toIso8601String()
      ]);
    } catch (e) {
      debugPrint("Error _sendPaymentNotification: $e");
    }
  }

  Future<List<Savings>> fetchSavingsByStudent(String studentId) async {
    try {
      final sql = """
        SELECT sv.*, s.nama as student_name
        FROM tabungan sv
        JOIN students s ON sv.siswa_id = s.id
        WHERE sv.siswa_id = ?
        ORDER BY sv.tanggal DESC
      """;
      final results = await _d1Service.query(sql, params: [studentId]);
      return results.map((e) => Savings.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchSavingsByStudent: $e");
      return [];
    }
  }

  Future<FinanceReport> fetchFinanceReport() async {
    try {
      await _ensureFinanceColumns();
      final now = DateTime.now();
      
      final sppSum = await _d1Service.query("SELECT SUM(amount) as total FROM pembayaran_spp WHERE status = 'lunas'");
      final savingsSum = await _d1Service.query("SELECT SUM(amount) as total FROM tabungan WHERE jenis = 'setor'");
      final otherSum = await _d1Service.query("SELECT SUM(amount) as total FROM biaya_lainnya WHERE status = 'lunas'");
      final expSum = await _d1Service.query("SELECT SUM(amount) as total FROM pengeluaran_operasional");
      
      return FinanceReport(
        totalSppIn: (sppSum.isNotEmpty ? (sppSum.first['total'] ?? 0) : 0).toDouble(),
        totalSavings: (savingsSum.isNotEmpty ? (savingsSum.first['total'] ?? 0) : 0).toDouble(),
        totalOtherFees: (otherSum.isNotEmpty ? (otherSum.first['total'] ?? 0) : 0).toDouble(),
        totalExpenses: (expSum.isNotEmpty ? (expSum.first['total'] ?? 0) : 0).toDouble(),
        month: now.month.toString().padLeft(2, '0'),
        year: now.year.toString(),
      );
    } catch (e) {
      debugPrint("Error fetchFinanceReport: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecentTransactions({int limit = 10}) async {
    try {
      const sql = """
        SELECT 'pemasukan' as type, 'SPP' as category, s.nama as description, amount, tanggal_bayar as date 
        FROM pembayaran_spp p JOIN students s ON p.siswa_id = s.id
        UNION ALL
        SELECT 'pemasukan' as type, 'Tabungan' as category, s.nama as description, amount, tanggal as date 
        FROM tabungan t JOIN students s ON t.siswa_id = s.id WHERE jenis = 'setor'
        UNION ALL
        SELECT 'pengeluaran' as type, kategori as category, keterangan as description, amount, tanggal as date 
        FROM pengeluaran_operasional
        ORDER BY date DESC LIMIT ?
      """;
      final results = await _d1Service.query(sql, params: [limit]);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchRecentTransactions: $e");
      return [];
    }
  }

  Future<double> getSppAmount(String? levelStr) async {
    final d1 = D1Service();
    final res = await d1.query("SELECT spp_nominal_x, spp_nominal_xi, spp_nominal_xii FROM system_settings WHERE id = 1 LIMIT 1");
    
    double x = 250000;
    double xi = 275000;
    double xii = 300000;

    if (res.isNotEmpty) {
      x = (res.first['spp_nominal_x'] ?? 250000).toDouble();
      xi = (res.first['spp_nominal_xi'] ?? 275000).toDouble();
      xii = (res.first['spp_nominal_xii'] ?? 300000).toDouble();
    }

    final level = int.tryParse(levelStr ?? '') ?? (levelStr == 'X' ? 10 : levelStr == 'XI' ? 11 : levelStr == 'XII' ? 12 : 10);
    switch (level) {
      case 10: return x;
      case 11: return xi;
      case 12: return xii;
      default: return x;
    }
  }

  Future<List<OtherFee>> fetchOtherFees() async {
    try {
      const sql = "SELECT * FROM biaya_lainnya ORDER BY tenggat_waktu DESC";
      final results = await _d1Service.query(sql);
      return results.map((e) => OtherFee.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchOtherFees: $e");
      return [];
    }
  }

  Future<void> payOtherFee(String feeId) async {
    try {
      // Ambil detail tagihan dulu untuk notifikasi
      final feeResult = await _d1Service.query("SELECT * FROM biaya_lainnya WHERE id = ?", params: [feeId]);
      if (feeResult.isEmpty) return;
      final fee = feeResult.first;

      const sql = "UPDATE biaya_lainnya SET status = 'lunas' WHERE id = ?";
      await _d1Service.query(sql, params: [feeId]);

      // Kirim Notifikasi
      await _sendPaymentNotification(
        studentId: fee['siswa_id'],
        title: 'Pembayaran Tagihan Berhasil',
        content: 'Pembayaran tagihan "${fee['name']}" sebesar Rp ${fee['amount']} telah berhasil diverifikasi. Terima kasih.',
      );
    } catch (e) {
      debugPrint("Error payOtherFee: $e");
      rethrow;
    }
  }

  Future<void> addOtherFees({
    required String name,
    required double amount,
    required DateTime dueDate,
    required String targetType, // 'all', 'grade_10', 'grade_11', 'grade_12', 'specific'
    List<String>? specificStudentIds,
  }) async {
    try {
      String filterSql = "";
      List<dynamic> params = [];

      if (targetType == 'all') {
        filterSql = "WHERE is_active = 1";
      } else if (targetType.startsWith('grade_')) {
        final level = targetType.split('_')[1];
        filterSql = "WHERE is_active = 1 AND kelas_id IN (SELECT id FROM classes WHERE SUBSTR(nama, 1, instr(nama, ' ') - 1) = ? OR nama LIKE ?)";
        params = [level, "$level %"];
      } else if (targetType == 'specific' && specificStudentIds != null) {
        filterSql = "WHERE id IN (${specificStudentIds.map((_) => '?').join(',')})";
        params = specificStudentIds;
      }

      final studentResults = await _d1Service.query("SELECT id FROM students $filterSql", params: params);
      
      for (var student in studentResults) {
        final feeId = "FEE_${DateTime.now().millisecondsSinceEpoch}_${student['id'].toString().substring(0, 4)}";
        await _d1Service.query("""
          INSERT INTO biaya_lainnya (id, name, amount, siswa_id, tenggat_waktu, status)
          VALUES (?, ?, ?, ?, ?, 'belum')
        """, params: [
          feeId,
          name,
          amount,
          student['id'],
          dueDate.toIso8601String()
        ]);
      }
    } catch (e) {
      debugPrint("Error addOtherFees: $e");
      rethrow;
    }
  }

  Future<List<OperationalExpense>> fetchOperationalExpenses() async {
    try {
      const sql = "SELECT * FROM pengeluaran_operasional ORDER BY tanggal DESC";
      final results = await _d1Service.query(sql);
      return results.map((e) => OperationalExpense.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetchOperationalExpenses: $e");
      return [];
    }
  }

  Future<void> addOperationalExpense(OperationalExpense expense) async {
    try {
      await _ensureFinanceColumns();
      const sql = "INSERT INTO pengeluaran_operasional (id, keterangan, amount, tanggal, kategori) VALUES (?, ?, ?, ?, ?)";
      await _d1Service.query(sql, params: [
        expense.id,
        expense.description,
        expense.amount,
        expense.date.toIso8601String(),
        expense.category
      ]);
    } catch (e) {
      debugPrint("Error addOperationalExpense: $e");
      rethrow;
    }
  }

  Future<void> updateOperationalExpense(OperationalExpense expense) async {
    try {
      const sql = "UPDATE pengeluaran_operasional SET keterangan = ?, amount = ?, tanggal = ?, kategori = ? WHERE id = ?";
      await _d1Service.query(sql, params: [
        expense.description,
        expense.amount,
        expense.date.toIso8601String(),
        expense.category,
        expense.id
      ]);
    } catch (e) {
      debugPrint("Error updateOperationalExpense: $e");
      rethrow;
    }
  }

  Future<void> deleteOperationalExpense(String id) async {
    try {
      await _d1Service.query("DELETE FROM pengeluaran_operasional WHERE id = ?", params: [id]);
    } catch (e) {
      debugPrint("Error deleteOperationalExpense: $e");
      rethrow;
    }
  }

  Future<void> addSavings(Savings savings) async {
    try {
      await _ensureFinanceColumns();
      final id = "SAV_${DateTime.now().millisecondsSinceEpoch}";
      const sql = "INSERT INTO tabungan (id, siswa_id, amount, tanggal, jenis) VALUES (?, ?, ?, ?, ?)";
      await _d1Service.query(sql, params: [
        id,
        savings.studentId,
        savings.amount,
        savings.savedAt.toIso8601String(),
        savings.type
      ]);

      // Kirim Notifikasi
      final isSetor = savings.type == 'setor';
      await _sendPaymentNotification(
        studentId: savings.studentId,
        title: isSetor ? 'Setoran Tabungan Berhasil' : 'Penarikan Tabungan Berhasil',
        content: '${isSetor ? "Setoran" : "Penarikan"} tabungan sebesar Rp ${savings.amount.toStringAsFixed(0)} telah berhasil dicatat. Saldo Anda telah diperbarui.',
      );
    } catch (e) {
      debugPrint("Error addSavings: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveStudentsForPayment() async {
    try {
      final sql = """
        SELECT s.id, s.nis, s.nama, c.nama as kelas_nama
        FROM students s
        JOIN classes c ON s.kelas_id = c.id
        WHERE s.is_active = 1
        ORDER BY s.nama
      """;
      final results = await _d1Service.query(sql);
      return List<Map<String, dynamic>>.from(results);
    } catch (e) {
      debugPrint("Error fetchActiveStudentsForPayment: $e");
      return [];
    }
  }

  Future<void> _ensureFinanceColumns() async {
    try {
      // Pastikan kolom amount ada di semua tabel keuangan
      await _d1Service.query("ALTER TABLE pembayaran_spp ADD COLUMN amount REAL DEFAULT 0");
      await _d1Service.query("ALTER TABLE tabungan ADD COLUMN amount REAL DEFAULT 0");
      await _d1Service.query("ALTER TABLE biaya_lainnya ADD COLUMN amount REAL DEFAULT 0");
      await _d1Service.query("ALTER TABLE pengeluaran_operasional ADD COLUMN amount REAL DEFAULT 0");
      
      // Migrasi data jika perlu (dari jumlah ke amount)
      try { await _d1Service.query("UPDATE pembayaran_spp SET amount = jumlah WHERE amount = 0 AND jumlah > 0"); } catch (_) {}
      try { await _d1Service.query("UPDATE tabungan SET amount = jumlah WHERE amount = 0 AND jumlah > 0"); } catch (_) {}
      try { await _d1Service.query("UPDATE pengeluaran_operasional SET amount = jumlah WHERE amount = 0 AND jumlah > 0"); } catch (_) {}
    } catch (_) {}
  }
}
