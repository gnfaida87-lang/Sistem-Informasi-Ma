import 'package:flutter/material.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/utils/context_extensions.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';

class FinanceReports extends StatefulWidget {
  const FinanceReports({super.key});

  @override
  State<FinanceReports> createState() => _FinanceReportsState();
}

class _FinanceReportsState extends State<FinanceReports> with SafeAsync {
  final _financeService = FinanceService();
  FinanceReport? _report;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _financeService.fetchFinanceReport();
        setState(() {
          _report = data;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Laporan & Rekapitulasi Jurnal Keuangan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _fetchReport,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (_report != null)
            _buildProfessionalReport()
          else if (!isLoading)
            _buildErrorReport()
          else
            const Center(child: Padding(
              padding: EdgeInsets.all(100.0),
              child: CircularProgressIndicator(),
            )),
        ],
      ),
    );
  }

  Widget _buildErrorReport() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade200),
          const SizedBox(height: 16),
          const Text('Gagal memuat laporan. Pastikan data transaksi sudah tersedia.', 
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchReport, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildProfessionalReport() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          // Header Laporan
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3674),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('JURNAL KAS MADRASAH', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Periode: ${_report!.month}/${_report!.year}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const Icon(Icons.account_balance, color: Colors.white, size: 40),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('REKAPITULASI PEMASUKAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const Divider(height: 24),
                _reportRow('Penerimaan SPP Bulanan', _report!.totalSppIn, isIncome: true),
                _reportRow('Penerimaan Tagihan Lainnya', _report!.totalOtherFees, isIncome: true),
                _reportRow('Penerimaan Tabungan Siswa', _report!.totalSavings, isIncome: true),
                const SizedBox(height: 16),
                _totalBox('TOTAL PEMASUKAN', _report!.totalSppIn + _report!.totalOtherFees + _report!.totalSavings, Colors.green),
                
                const SizedBox(height: 48),
                
                const Text('REKAPITULASI PENGELUARAN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const Divider(height: 24),
                _reportRow('Beban Pengeluaran Operasional', _report!.totalExpenses, isIncome: false),
                const SizedBox(height: 16),
                _totalBox('TOTAL PENGELUARAN', _report!.totalExpenses, Colors.red),
                
                const SizedBox(height: 48),
                const Divider(thickness: 2),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SALDO BERSIH (SURPLUS/DEFISIT)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      'Rp ${(_report!.totalSppIn + _report!.totalOtherFees + _report!.totalSavings - _report!.totalExpenses).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: (_report!.totalSppIn + _report!.totalOtherFees + _report!.totalSavings - _report!.totalExpenses) >= 0 
                          ? Colors.blue.shade800 
                          : Colors.red.shade800
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
            child: const Center(
              child: Text('Laporan ini dihasilkan secara otomatis oleh Sistem Informasi Madrasah', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportRow(String label, double amount, {required bool isIncome}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            '${isIncome ? "+" : "-"} Rp ${amount.toStringAsFixed(0)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: isIncome ? Colors.green.shade700 : Colors.red.shade700),
          ),
        ],
      ),
    );
  }

  Widget _totalBox(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text('Rp ${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
