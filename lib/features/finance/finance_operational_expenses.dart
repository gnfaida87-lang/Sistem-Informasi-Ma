import 'package:flutter/material.dart';

class FinanceOperationalExpenses extends StatelessWidget {
  const FinanceOperationalExpenses({super.key});

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
                onPressed: () {},
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Catat Pengeluaran Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TABEL PENGELUARAN 
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Arus Kas Keluar (Bulan Ini)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
                    columns: const [
                      DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Deskripsi Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nominal Keluaran', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Lampiran', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      _buildExpenseRow('21 Feb 2026', 'Membayar Tagihan Listrik PLN', 'Utilitas', 'Rp 4.500.000'),
                      _buildExpenseRow('20 Feb 2026', 'Membeli ATK Spidol & Kertas HVS', 'Inventaris', 'Rp 850.000'),
                      _buildExpenseRow('15 Feb 2026', 'Konsumsi Rapat Guru Pleno', 'Konsumsi', 'Rp 1.250.000'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildExpenseRow(String tgl, String deskripsi, String kategori, String nominal) {
    return DataRow(
      cells: [
        DataCell(Text(tgl, style: TextStyle(color: Colors.grey.shade600))),
        DataCell(Text(deskripsi, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
            child: Text(kategori, style: TextStyle(color: Colors.blue.shade800, fontSize: 11)),
          ),
        ),
        DataCell(Text(nominal, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
        DataCell(
          IconButton(icon: const Icon(Icons.receipt_long, color: Colors.blueGrey, size: 20), tooltip: 'Lihat Nota', onPressed: () {}),
        ),
      ],
    );
  }
}
