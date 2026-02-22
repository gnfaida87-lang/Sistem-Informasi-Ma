import 'package:flutter/material.dart';

class OperatorMasterMapel extends StatelessWidget {
  const OperatorMasterMapel({super.key});

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
                'Data Master Mata Pelajaran',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Tambah Mapel'),
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
                const Text('Daftar Kode Rekapitulasi Rapor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                    columns: const [
                      DataColumn(label: Text('Kode', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nama Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Kelompok Rapor', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Jenis', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      _buildMapelRow('PAI', 'Pend. Agama Islam & Budi Pekerti', 'Kelompok A (Wajib)', 'Teori'),
                      _buildMapelRow('MTKW', 'Matematika', 'Kelompok A (Wajib)', 'Hitungan'),
                      _buildMapelRow('SND', 'Seni & Budaya Lokal', 'Kelompok B (Keterampilan)', 'Praktek'),
                      _buildMapelRow('FIS', 'Fisika Peminatan', 'Kelompok C (Peminatan)', 'Teori & Hitungan'),
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

  DataRow _buildMapelRow(String kode, String nama, String kelompok, String jenis) {
    return DataRow(
      cells: [
        DataCell(Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(4)),
            child: Text(kode, style: TextStyle(color: Colors.brown.shade800, fontWeight: FontWeight.bold)),
        )),
        DataCell(Text(nama)),
        DataCell(Text(kelompok, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(jenis)),
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
