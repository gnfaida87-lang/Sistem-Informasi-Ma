import 'package:flutter/material.dart';

class FinanceOtherFees extends StatelessWidget {
  const FinanceOtherFees({super.key});

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
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Buat Tagihan Massal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daftar Rekap Tunggakan Ekstrakurikuler, Seragam & Buku', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.orange.shade50),
                    columns: const [
                      DataColumn(label: Text('Nama Siswa / NISN', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Jenis Tagihan', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nominal', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      _buildTagihanRow('Nadia Safira (10103983)', 'Uang Buku Semester Ganjil', 'Rp 450.000', false),
                      _buildTagihanRow('Ahmad Rizal F (10103982)', 'Iuran Field Trip', 'Rp 250.000', true),
                      _buildTagihanRow('Siti Maimunah (10103985)', 'Daftar Ulang Tahunan', 'Rp 1.500.000', false),
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

  DataRow _buildTagihanRow(String nama, String jenis, String nominal, bool isPaid) {
    return DataRow(
      cells: [
        DataCell(Text(nama, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(jenis)),
        DataCell(Text(nominal, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: isPaid ? Colors.green.shade100 : Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
            child: Text(isPaid ? 'Lunas' : 'Tunggak', style: TextStyle(color: isPaid ? Colors.green.shade800 : Colors.red.shade800, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(
          Row(
            children: [
              if (!isPaid)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, minimumSize: const Size(0, 30)),
                  child: const Text('Kasir', style: TextStyle(fontSize: 11)),
                ),
              if (isPaid)
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey), minimumSize: const Size(0, 30)),
                  child: const Text('Cetak Cetakan', style: TextStyle(fontSize: 11, color: Colors.black87)),
                )
            ],
          ),
        ),
      ],
    );
  }
}
