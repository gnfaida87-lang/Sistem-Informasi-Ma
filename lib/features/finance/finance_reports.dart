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
              if (isLoading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 24),
          
          if (_report != null)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                border: Border.all(color: Colors.green.shade200, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('LAPORAN LABA RUGI OPERASIONAL MURNI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 48, thickness: 2),

                  const Text('LAPORAN PEMASUKAN (+)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 12),
                  _reportItem('1. Total Kolektivitas SPP Bulanan', 'Rp ${_report!.totalSpp.toStringAsFixed(0)}'),
                  _reportItem('2. Total Tagihan Lainnya', 'Rp ${_report!.totalOtherFees.toStringAsFixed(0)}'),
                  const Divider(),
                  _reportTotal('TOTAL PEMASUKAN', 'Rp ${(_report!.totalSpp + _report!.totalOtherFees).toStringAsFixed(0)}', Colors.green.shade800),
                  
                  const SizedBox(height: 32),

                  const Text('LAPORAN PENGELUARAN (-)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 12),
                  _reportItem('1. Beban Pengeluaran Operasional', 'Rp ${_report!.totalOperationalExpenses.toStringAsFixed(0)}'),
                  const Divider(),
                  _reportTotal('TOTAL PENGELUARAN', 'Rp ${_report!.totalOperationalExpenses.toStringAsFixed(0)}', Colors.red.shade800),

                  const Divider(height: 48, thickness: 2),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('NET CASH FLOW / SURPLUS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text('Rp ${_report!.netIncome.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      )
                    ],
                  ),
                ],
              ),
            )
          else if (!isLoading)
            const Center(child: Text('Gagal memuat laporan.')),
        ],
      ),
    );
  }

  Widget _reportItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _reportTotal(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}

