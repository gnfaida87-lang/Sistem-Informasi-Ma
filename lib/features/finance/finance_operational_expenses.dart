import 'package:flutter/material.dart';
import '../../core/mixins/safe_async_mixin.dart';
import '../../core/utils/context_extensions.dart';
import 'services/finance_service.dart';
import 'models/finance_models.dart';

class FinanceOperationalExpenses extends StatefulWidget {
  const FinanceOperationalExpenses({super.key});

  @override
  State<FinanceOperationalExpenses> createState() => _FinanceOperationalExpensesState();
}

class _FinanceOperationalExpensesState extends State<FinanceOperationalExpenses> with SafeAsync {
  final _financeService = FinanceService();
  List<OperationalExpense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
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
            id: '',
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
                const Text('Arus Kas Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      rows: _expenses.map((e) => DataRow(
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
