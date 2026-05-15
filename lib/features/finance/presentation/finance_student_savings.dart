import 'package:flutter/material.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import '../../../core/utils/context_extensions.dart';
import '../services/finance_service.dart';
import '../models/finance_models.dart';
import '../../master_data/services/master_service.dart';
import '../../master_data/models/master_models.dart';
import '../../../core/utils/receipt_helper.dart';
import '../../../core/providers/system_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinanceStudentSavings extends StatefulWidget {
  const FinanceStudentSavings({super.key});

  @override
  State<FinanceStudentSavings> createState() => _FinanceStudentSavingsState();
}

class _FinanceStudentSavingsState extends State<FinanceStudentSavings> with SafeAsync {
  final _financeService = FinanceService();
  final _masterService = MasterService();
  final _searchController = TextEditingController();
  
  Student? _foundSiswa;
  List<Savings> _savings = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchSiswa() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.showErrorSnackBar('Masukkan NIS atau Nama Siswa terlebih dahulu.');
      return;
    }

    await safeCall(
      context: context,
      action: () async {
        final results = await _masterService.searchStudents(query);
        if (results.isEmpty) {
          _foundSiswa = null;
          _savings = [];
          if (mounted) context.showErrorSnackBar('Siswa tidak ditemukan.');
        } else {
          _foundSiswa = results.first;
          await _fetchSavings(_foundSiswa!.id);
        }
        setState(() {});
      },
    );
  }

  Future<void> _fetchSavings(String studentId) async {
    final data = await _financeService.fetchSavingsByStudent(studentId);
    setState(() {
      _savings = data;
    });
  }

  Future<void> _addSavings() async {
    if (_foundSiswa == null) return;
    
    final amountController = TextEditingController();
    String type = 'setor';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Catat Tabungan — ${_foundSiswa!.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Nominal (Rp)', prefixText: 'Rp '),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'setor', child: Text('Setoran (Menabung)')),
                  DropdownMenuItem(value: 'tarik', child: Text('Penarikan (Ambil Uang)')),
                ],
                onChanged: (v) => setDialogState(() => type = v!),
                decoration: const InputDecoration(labelText: 'Jenis Transaksi', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
              child: const Text('Simpan Transaksi'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final amount = double.tryParse(amountController.text) ?? 0;
      if (amount <= 0) return;

      // Validasi Saldo untuk Penarikan
      if (type == 'tarik' && amount > _saldo) {
        if (mounted) {
          context.showErrorSnackBar('Gagal! Saldo tidak mencukupi (Saldo saat ini: Rp ${_saldo.toStringAsFixed(0)})');
        }
        return;
      }

      await safeCall(
        context: context,
        successMessage: 'Transaksi tabungan berhasil dicatat!',
        action: () async {
          final savings = Savings(
            id: '',
            studentId: _foundSiswa!.id,
            amount: amount,
            savedAt: DateTime.now(),
            type: type,
          );
          await _financeService.addSavings(savings);
          await _fetchSavings(_foundSiswa!.id);
        },
      );
    }
  }

  double get _totalSetor => _savings
      .where((s) => s.type == 'setor')
      .fold(0.0, (sum, s) => sum + s.amount);

  double get _totalTarik => _savings
      .where((s) => s.type == 'tarik')
      .fold(0.0, (sum, s) => sum + s.amount);

  double get _saldo => _totalSetor - _totalTarik;

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
                'Manajemen Tabungan Siswa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 24),

          // Search bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cari Siswa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _searchSiswa(),
                        decoration: InputDecoration(
                          hintText: 'Ketik NIS atau Nama Siswa',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty 
                            ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                            : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _searchSiswa,
                      icon: const Icon(Icons.search),
                      label: const Text('Cari'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_foundSiswa != null) ...[
            const SizedBox(height: 24),
            // Student Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_foundSiswa!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('NIS: ${_foundSiswa!.nis}'),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ReceiptHelper.printSavingsHistory(
                        studentName: _foundSiswa!.name,
                        nis: _foundSiswa!.nis,
                        transactions: _savings,
                        currentBalance: _saldo,
                      );
                    },
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Cetak Buku Tabungan'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addSavings,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Transaksi'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Saldo summary
            Row(
              children: [
                _summaryCard('Total Setoran', _totalSetor, Colors.green),
                const SizedBox(width: 12),
                _summaryCard('Total Penarikan', _totalTarik, Colors.red),
                const SizedBox(width: 12),
                _summaryCard('Saldo Saat Ini', _saldo, Colors.blue),
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
                  const Text('Riwayat Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_savings.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Belum ada riwayat tabungan.')))
                  else
                    SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                        columns: const [
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Jenis')),
                          DataColumn(label: Text('Nominal')),
                          DataColumn(label: Text('Aksi')),
                        ],
                        rows: _savings.map((s) => DataRow(
                          cells: [
                            DataCell(Text('${s.savedAt.day}/${s.savedAt.month}/${s.savedAt.year}')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: s.type == 'setor' ? Colors.green.shade100 : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(s.type == 'setor' ? 'Setoran' : 'Penarikan',
                                    style: TextStyle(color: s.type == 'setor' ? Colors.green.shade800 : Colors.red.shade800, fontSize: 12)),
                              ),
                            ),
                            DataCell(Text('Rp ${s.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.print_outlined, size: 20, color: Colors.blue),
                                tooltip: 'Cetak Kwitansi',
                                onPressed: () {
                                  final settings = context.mounted ? null : null; // Placeholder for schoolName if needed
                                  ReceiptHelper.printReceipt(
                                    title: s.type == 'setor' ? 'SETORAN TABUNGAN' : 'PENARIKAN TABUNGAN',
                                    studentName: _foundSiswa!.name,
                                    nis: _foundSiswa!.nis,
                                    amount: 'Rp ${s.amount.toStringAsFixed(0)}',
                                    description: 'Transaksi tabungan ${s.type == 'setor' ? 'masuk' : 'keluar'}',
                                    transactionId: s.id.isEmpty ? 'SAV-${DateTime.now().millisecondsSinceEpoch}' : s.id,
                                  );
                                },
                              ),
                            ),
                          ],
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ] else if (!isLoading)
             Center(
               child: Padding(
                 padding: const EdgeInsets.all(60.0),
                 child: Column(
                   children: [
                     Icon(Icons.savings_outlined, size: 80, color: Colors.grey.shade200),
                     const SizedBox(height: 16),
                     const Text('Cari siswa untuk melihat atau mencatat tabungan'),
                   ],
                 ),
               ),
             ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              'Rp ${value.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
