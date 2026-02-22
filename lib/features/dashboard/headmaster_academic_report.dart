import 'package:flutter/material.dart';

class HeadmasterAcademicReport extends StatelessWidget {
  const HeadmasterAcademicReport({super.key});

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
                'Laporan Akademik Terpadu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.print),
                label: const Text('Cetak Laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TABEL REKAP KELAS
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
                const Text('Rekapitulasi Kinerja per Kelas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
                    columns: const [
                      DataColumn(label: Text('Nama Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Wali Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Jumlah Siswa', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Rata-rata Nilai', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Ketuntasan', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Absensi', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      _buildDataRow('X IPA 1', 'Agus Prayitno, M.Pd', '32', '85.4', '94%', '98%'),
                      _buildDataRow('X IPS 1', 'Siti Rahmawati, S.Pd', '30', '82.1', '88%', '95%'),
                      _buildDataRow('XI IPA 1', 'Drs. Budi Santoso', '31', '86.2', '96%', '99%'),
                      _buildDataRow('XII IPA 1', 'Rina Marlina, S.Si', '28', '88.5', '100%', '99%'),
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

  DataRow _buildDataRow(String kelas, String wali, String jumlah, String nilai, String lulus, String absen) {
    return DataRow(
      cells: [
        DataCell(Text(kelas, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(wali)),
        DataCell(Text(jumlah)),
        DataCell(Text(nilai, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
        DataCell(Text(lulus, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold))),
        DataCell(Text(absen)),
        DataCell(
          TextButton(
            onPressed: () {},
            child: const Text('Lihat Detail Rapor'),
          ),
        ),
      ],
    );
  }
}
