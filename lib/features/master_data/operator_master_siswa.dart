import 'package:flutter/material.dart';

class OperatorMasterSiswa extends StatelessWidget {
  const OperatorMasterSiswa({super.key});

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
                'Data Master Siswa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: const Text('Tambah Siswa (Baru/Pindahan)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Seluruh Siswa Aktif Madrasah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                    Container(
                      width: 200,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari Nama/NISN...',
                          hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          isDense: true,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                    columns: const [
                      DataColumn(label: Text('NISN', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      _buildDataRow('10103982', 'Ahmad Rizal Fachry', 'XII IPA 1', 'Laki-laki', Colors.green),
                      _buildDataRow('10103983', 'Nadia Safira', 'X IPS 2', 'Perempuan', Colors.green),
                      _buildDataRow('10103984', 'Bagas Pramoedya', '-', 'Laki-laki', Colors.red), // Belum dapat kelas
                      _buildDataRow('10103985', 'Siti Maimunah', 'XI IPA 3', 'Perempuan', Colors.green),
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

  DataRow _buildDataRow(String nisn, String nama, String kelas, String jk, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(nisn, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(nama)),
        DataCell(Text(kelas)),
        DataCell(Text(jk)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(statusColor == Colors.green ? 'Aktif' : 'Unmapped', style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () {}),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18), onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
