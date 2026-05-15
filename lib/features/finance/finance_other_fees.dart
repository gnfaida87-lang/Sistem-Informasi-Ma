import 'package:flutter/material.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/utils/context_extensions.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';
import '../../core/utils/receipt_helper.dart';

class FinanceOtherFees extends StatefulWidget {
  const FinanceOtherFees({super.key});

  @override
  State<FinanceOtherFees> createState() => _FinanceOtherFeesState();
}

class _FinanceOtherFeesState extends State<FinanceOtherFees> with SafeAsync {
  final _financeService = FinanceService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<OtherFee> _fees = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFees();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  void _showAddFeeDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String targetType = 'all';
    List<String> selectedStudentIds = [];
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Buat Tagihan Baru', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Jenis Pembayaran', hintText: 'Contoh: Uang Gedung, Study Tour')),
                const SizedBox(height: 16),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal Pembayaran', prefixText: 'Rp ')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: targetType,
                  decoration: const InputDecoration(labelText: 'Target Pembayaran'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Semua Siswa')),
                    DropdownMenuItem(value: 'grade_X', child: Text('Kelas X')),
                    DropdownMenuItem(value: 'grade_XI', child: Text('Kelas XI')),
                    DropdownMenuItem(value: 'grade_XII', child: Text('Kelas XII')),
                    DropdownMenuItem(value: 'specific', child: Text('Siswa Khusus')),
                  ],
                  onChanged: (val) => setDialogState(() => targetType = val!),
                ),
                if (targetType == 'specific') ...[
                  const SizedBox(height: 16),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _financeService.fetchActiveStudentsForPayment(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const LinearProgressIndicator();
                      final students = snapshot.data!;
                      return Container(
                        height: 200,
                        width: double.maxFinite,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final s = students[index];
                            final id = s['id'].toString();
                            return CheckboxListTile(
                              title: Text(s['nama'], style: const TextStyle(fontSize: 12)),
                              subtitle: Text(s['kelas_nama'] ?? '-', style: const TextStyle(fontSize: 10)),
                              value: selectedStudentIds.contains(id),
                              onChanged: (val) {
                                setDialogState(() {
                                  if (val == true) selectedStudentIds.add(id);
                                  else selectedStudentIds.remove(id);
                                });
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Tenggat Waktu', style: TextStyle(fontSize: 14)),
                  subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text;
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (name.isEmpty || amount <= 0) return;

                Navigator.pop(context);
                await safeCall(
                  context: context,
                  successMessage: 'Tagihan berhasil dibuat untuk target terpilih!',
                  action: () async {
                    await _financeService.addOtherFees(
                      name: name,
                      amount: amount,
                      dueDate: selectedDate,
                      targetType: targetType,
                      specificStudentIds: targetType == 'specific' ? selectedStudentIds : null,
                    );
                    await _fetchFees();
                  },
                );
              },
              child: const Text('Simpan & Terbitkan'),
            ),
          ],
        ),
      ),
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
                'Pembayaran Tagihan Lainnya',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddFeeDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Tagihan'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3674), foregroundColor: Colors.white),
              ),
              const SizedBox(width: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Tagihan Berjalan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Cari Nama Siswa atau Jenis Tagihan...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          fillColor: const Color(0xFFF4F7FE),
                          filled: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                      ),
                    ),
                  ],
                ),
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
                      rows: _fees.where((e) {
                        final nameMatch = (e.studentName ?? '').toLowerCase().contains(_searchQuery);
                        final typeMatch = e.type.toLowerCase().contains(_searchQuery);
                        return nameMatch || typeMatch;
                      }).map((e) => DataRow(
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
                            Row(
                              children: [
                                if (e.isPaid)
                                  IconButton(
                                    icon: const Icon(Icons.print_outlined, size: 20, color: Colors.blue),
                                    onPressed: () {
                                      ReceiptHelper.printReceipt(
                                        title: 'PEMBAYARAN TAGIHAN',
                                        studentName: e.studentName ?? e.studentId,
                                        nis: e.studentId,
                                        amount: 'Rp ${e.amount.toStringAsFixed(0)}',
                                        description: 'Pelunasan tagihan: ${e.type}',
                                        transactionId: e.id,
                                      );
                                    },
                                  ),
                                if (!e.isPaid)
                                  ElevatedButton(
                                    onPressed: isLoading ? null : () => _payFee(e),
                                    child: const Text('Bayar'),
                                  ),
                              ],
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

