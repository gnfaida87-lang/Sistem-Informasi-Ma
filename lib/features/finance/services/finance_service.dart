// lib/finance/services/finance_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_models.dart';
import '../../../core/utils/error_handler.dart';

class FinanceService {
  final _supabase = Supabase.instance.client;

  Future<List<SppRecord>> fetchSppByStudent(String studentId) async {
    try {
      final response = await _supabase
          .from('spp_records')
          .select('*, siswa(nama)')
          .eq('student_id', studentId)
          .order('paid_at', ascending: false);
      return (response as List).map((e) => SppRecord.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchSppByStudent');
      throw err;
    }
  }

  Future<void> addSppPayment(SppRecord record) async {
    try {
      await _supabase.from('spp_records').insert(record.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addSppPayment');
      throw err;
    }
  }

  Future<List<Savings>> fetchSavingsByStudent(String studentId) async {
    try {
      final response = await _supabase
          .from('savings')
          .select('*, siswa(nama)')
          .eq('student_id', studentId)
          .order('saved_at', ascending: false);
      return (response as List).map((e) => Savings.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchSavingsByStudent');
      throw err;
    }
  }

  Future<void> addSavings(Savings savings) async {
    try {
      await _supabase.from('savings').insert(savings.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addSavings');
      throw err;
    }
  }

  Future<List<OtherFee>> fetchOtherFees() async {
    try {
      final response = await _supabase
          .from('other_fees')
          .select('*, siswa(nama)')
          .order('due_date', ascending: false);
      return (response as List).map((e) => OtherFee.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchOtherFees');
      throw err;
    }
  }

  Future<void> payOtherFee(String feeId) async {
    try {
      await _supabase
          .from('other_fees')
          .update({
            'status': 'lunas',
            'paid_at': DateTime.now().toIso8601String(),
          })
          .eq('id', feeId);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'payOtherFee');
      throw err;
    }
  }

  Future<List<OperationalExpense>> fetchOperationalExpenses() async {
    try {
      final response = await _supabase
          .from('operational_expenses')
          .select('*')
          .order('date', ascending: false);
      return (response as List).map((e) => OperationalExpense.fromJson(e)).toList();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchOperationalExpenses');
      throw err;
    }
  }

  Future<void> addOperationalExpense(OperationalExpense expense) async {
    try {
      await _supabase.from('operational_expenses').insert(expense.toJson());
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'addOperationalExpense');
      throw err;
    }
  }

  Future<FinanceReport> fetchFinanceReport() async {
    try {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final year = now.year.toString();

      final sppRes = await _supabase
          .from('spp_records')
          .select('amount')
          .eq('status', 'lunas');
      final double totalSppIn = (sppRes as List)
          .fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());

      final savingsRes = await _supabase
          .from('savings')
          .select('amount, type');
      final double totalSavings = (savingsRes as List)
          .where((e) => e['type'] == 'setor')
          .fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());

      final otherRes = await _supabase
          .from('other_fees')
          .select('amount')
          .eq('status', 'lunas');
      final double totalOtherFees = (otherRes as List)
          .fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());

      final expRes = await _supabase
          .from('operational_expenses')
          .select('amount');
      final double totalExpenses = (expRes as List)
          .fold(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());

      return FinanceReport(
        totalSppIn: totalSppIn,
        totalSavings: totalSavings,
        totalOtherFees: totalOtherFees,
        totalExpenses: totalExpenses,
        month: month,
        year: year,
      );
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchFinanceReport');
      throw err;
    }
  }

  Future<double> getSppAmount(String? level) async {
    try {
      if (level == null || level.isEmpty) return 250000;
      final response = await _supabase
          .from('spp_config')
          .select('amount')
          .eq('level', level)
          .maybeSingle();
      
      if (response == null) return 250000;
      return (response['amount'] as num).toDouble();
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'getSppAmount');
      return 250000;
    }
  }

  Future<void> updateOperationalExpense(OperationalExpense expense) async {
    try {
      await _supabase
          .from('operational_expenses')
          .update(expense.toJson())
          .eq('id', expense.id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'updateOperationalExpense');
      throw err;
    }
  }

  Future<void> deleteOperationalExpense(String id) async {
    try {
      await _supabase.from('operational_expenses').delete().eq('id', id);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'deleteOperationalExpense');
      throw err;
    }
  }

  // ── INTEGRASI DATA MASTER (SISWA) ────────────────────────
  
  Future<List<Map<String, dynamic>>> fetchActiveStudentsForPayment() async {
    try {
      final response = await _supabase
          .from('siswa')
          .select('id, nis, nama, kelas(nama)')
          .eq('status', 'aktif')
          .order('nama');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      final err = handleSupabaseError(e);
      logError(err, context: 'fetchActiveStudentsForPayment');
      return [];
    }
  }
}
