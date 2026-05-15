import 'package:flutter/material.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/utils/context_extensions.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';
import '../../core/utils/excel_helper.dart';

class FinanceOperationalExpenses extends StatefulWidget {
  const FinanceOperationalExpenses({super.key});

  @override
  State<FinanceOperationalExpenses> createState() => _FinanceOperationalExpensesState();
}

class _FinanceOperationalExpensesState extends State<FinanceOperationalExpenses> with SafeAsync {
  final _financeService = FinanceService();
  final _searchController = TextEditingController();
  List<OperationalExpense> _expenses = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExpenses() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _financeService.fetchOperationalExpenses();
        setState(() {
          _expenses = data;
        });
      },
    );
  }

  void _exportToExcel() {
    final headers = ['Tanggal', 'Deskripsi', 'Kategori', 'Nominal'];
    final rows = _filteredExpenses.map((e) => [
          '${e.date.day}-${e.date.month}-${e.date.year}',
          e.description,
          e.category,
          e.amount.toStringAsFixed(0),
        ]).toList();
    
    // Tambahkan baris total
    rows.add(['', '', 'TOTAL', 'Rp ${_filteredExpenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(0)}']);

    ExcelHelper.exportToExcel(
      fileName: 'Laporan_Pengeluaran_Operasional.xlsx',
      sheetName: 'Operasional',
      headers: headers,
      rows: rows,
    );
    context.showSuccessSnackBar('Laporan berhasil diekspor ke Excel!');
  }
  
  List<OperationalExpense> get _filteredExpenses {
    if (_searchQuery.isEmpty) return _expenses;
    return _expenses.where((e) {
      return e.description.toLowerCase().contains(_searchQuery) ||
             e.category.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<void> _addExpense() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Utilitas';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catat Pengeluaran Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Nominal'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: category,
              items: ['Utilitas', 'Inventaris', 'Konsumsi', 'Lainnya']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => category = v!,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (confirmed == true) {
      await safeCall(
        context: context,
        successMessage: 'Pengeluaran berhasil dicatat!',
        action: () async {
          final expense = OperationalExpense(
            id: 'EXP_${DateTime.now().millisecondsSinceEpoch}',
            description: titleController.text,
            amount: double.tryParse(amountController.text) ?? 0,
            category: category,
            date: DateTime.now(),
          );
          await _financeService.addOperationalExpense(expense);
          await _fetchExpenses();
        },
      );
    }
  }

  Future<void> _editExpense(OperationalExpense expense) async {
    final titleController = TextEditingController(text: expense.description);
    final amountController = TextEditingController(text: expense.amount.toString());
    String category = expense.category;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pengeluaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Deskripsi')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Nominal'), keyboardType: TextInputType.number),
            DropdownButtonFormField<String>(
              value: category,
              items: ['Utilitas', 'Inventaris', 'Konsumsi', 'Lainnya'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => category = v!,
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Simpan')),
        ],
      ),
    );

    if (confirmed == true) {
      await safeCall(
        context: context,
        successMessage: 'Pengeluaran berhasil diupdate!',
        action: () async {
          await _financeService.updateOperationalExpense(expense.copyWith(
            description: titleController.text,
            amount: double.tryParse(amountController.text) ?? 0,
            category: category,
          ));
          await _fetchExpenses();
        },
      );
    }
  }

  Future<void> _deleteExpense(OperationalExpense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: const Text('Yakin ingin menghapus pengeluaran ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Hapus', style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirmed == true) {
      await safeCall(
        context: context,
        successMessage: 'Pengeluaran berhasil dihapus!',
        action: () async {
          await _financeService.deleteOperationalExpense(expense.id);
          await _fetchExpenses();
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
                'Pengeluaran Operasional',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _addExpense,
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Catat Pengeluaran Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Summary Card
          if (_expenses.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red.shade700, Colors.red.shade400]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.trending_up, color: Colors.white)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Pengeluaran Operasional', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        'Rp ${_expenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Arus Kas Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        SizedBox(
                          width: 250,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari deskripsi atau kategori...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _filteredExpenses.isEmpty ? null : _exportToExcel,
                          icon: const Icon(Icons.file_download_outlined, size: 18),
                          label: const Text('Export Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading && _expenses.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
                      columns: const [
                        DataColumn(label: Text('Tanggal')),
                        DataColumn(label: Text('Deskripsi')),
                        DataColumn(label: Text('Kategori')),
                        DataColumn(label: Text('Nominal')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: _filteredExpenses.map((e) => DataRow(
                        cells: [
                          DataCell(Text('${e.date.day}-${e.date.month}-${e.date.year}')),
                          DataCell(Text(e.description)),
                          DataCell(Text(e.category)),
                          DataCell(Text('Rp ${e.amount.toStringAsFixed(0)}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                                onPressed: () => _editExpense(e),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => _deleteExpense(e),
                              ),
                            ],
                          )),
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
