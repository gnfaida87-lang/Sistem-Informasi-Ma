import 'package:flutter/material.dart';

class OperatorMasterGuru extends StatelessWidget {
  const OperatorMasterGuru({super.key});

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
                'Data Master Guru & Pegawai',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Registrasi Guru Baru'),
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
                const Text('Daftar Rekan Pendidik dan Tenaga Kependidikan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.brown.shade50),
                    columns: const [
                      DataColumn(label: Text('Nama / NIP', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Bidang Studi Utama', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Tugas Tambahan', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      _buildDataRow('Ahmad Fauzi, S.Pd\nNIP. 198002...', 'Matematika Terapan', 'Kepala Laboratorium'),
                      _buildDataRow('Siti Aminah, M.Pd\nNIP. 198211...', 'Bahasa Indonesia', 'Wali Kelas X IPS 1'),
                      _buildDataRow('H. Budi Santoso, S.Ag\nNIP. 197505...', 'Pendidikan Agama Islam', '-'),
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

  DataRow _buildDataRow(String identitas, String mapel, String tugas) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: Colors.brown, child: Icon(Icons.person, size: 18, color: Colors.white)),
            const SizedBox(width: 12),
            Text(identitas),
          ],
        )),
        DataCell(Text(mapel)),
        DataCell(Text(tugas, style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold))),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () {}),
              IconButton(icon: const Icon(Icons.info_outline, color: Colors.teal, size: 18), onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
