import 'package:flutter/material.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/utils/context_extensions.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';

class FinanceOtherFees extends StatefulWidget {
  const FinanceOtherFees({super.key});

  @override
  State<FinanceOtherFees> createState() => _FinanceOtherFeesState();
}

class _FinanceOtherFeesState extends State<FinanceOtherFees> with SafeAsync {
  final _financeService = FinanceService();
  List<OtherFee> _fees = [];

  @override
  void initState() {
    super.initState();
    _fetchFees();
  }

  Future<void> _fetchFees() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _financeService.fetchOtherFees();
        setState(() {
          _fees = data;
        });
      },
    );
  }

  Future<void> _payFee(OtherFee fee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Text('Apakah Anda ingin memproses pembayaran "${fee.type}" sebesar Rp ${fee.amount.toStringAsFixed(0)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Bayar')),
        ],
      ),
    );

    if (confirmed == true) {
      await safeCall(
        context: context,
        successMessage: 'Pembayaran berhasil diproses!',
        action: () async {
          await _financeService.payOtherFee(fee.id);
          await _fetchFees();
        },
      );
    }
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
                'Pembayaran Tagihan Lainnya',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daftar Tagihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (isLoading && _fees.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.orange.shade50),
                      columns: const [
                        DataColumn(label: Text('Nama Siswa')),
                        DataColumn(label: Text('Jenis Tagihan')),
                        DataColumn(label: Text('Nominal')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: _fees.map((e) => DataRow(
                        cells: [
                          DataCell(Text(e.studentName ?? e.studentId)),
                          DataCell(Text(e.type)),
                          DataCell(Text('Rp ${e.amount.toStringAsFixed(0)}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: e.isPaid ? Colors.green.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(e.isPaid ? 'Lunas' : 'Tunggak',
                                  style: TextStyle(color: e.isPaid ? Colors.green.shade800 : Colors.red.shade800)),
                            ),
                          ),
                          DataCell(
                            e.isPaid
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : ElevatedButton(
                                    onPressed: isLoading ? null : () => _payFee(e),
                                    child: const Text('Bayar'),
                                  ),
                          ),
                        ],
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

