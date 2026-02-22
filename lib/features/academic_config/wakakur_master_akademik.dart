import 'package:flutter/material.dart';

class WakakurMasterAkademik extends StatelessWidget {
  const WakakurMasterAkademik({super.key});

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
                'Master Akademik',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Tahun Ajaran Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TABEL TAHUN AJARAN & SEMESTER
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
                const Text('Daftar Periode & KKM Standar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                    columns: const [
                      DataColumn(label: Text('Tahun Ajaran', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Semester', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('KKM Umum', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: [
                      _buildDataRow('2025/2026', 'Ganjil', '75', true),
                      _buildDataRow('2024/2025', 'Genap', '75', false),
                      _buildDataRow('2024/2025', 'Ganjil', '75', false),
                      _buildDataRow('2023/2024', 'Genap', '70', false),
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

  DataRow _buildDataRow(String tahun, String semester, String kkm, bool isActive) {
    return DataRow(
      cells: [
        DataCell(Text(tahun, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(semester)),
        DataCell(Text(kkm)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'Aktif' : 'Tutup',
            style: TextStyle(color: isActive ? Colors.green.shade700 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        )),
        DataCell(
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue, size: 18), onPressed: () {}),
              if (!isActive)
                IconButton(icon: const Icon(Icons.check_circle_outline, color: Colors.teal, size: 18), tooltip: 'Set Aktif', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
