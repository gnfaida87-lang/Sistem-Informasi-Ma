import 'package:flutter/material.dart';

class WakakurMonitoringAkademik extends StatefulWidget {
  const WakakurMonitoringAkademik({super.key});

  @override
  State<WakakurMonitoringAkademik> createState() => _WakakurMonitoringAkademikState();
}

class _WakakurMonitoringAkademikState extends State<WakakurMonitoringAkademik> {
  String _selectedSemester = 'Ganjil 2025/2026';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monitoring Akademik',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Pantau kepatuhan input data guru & progres akademik secara real-time.', 
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              // SEMESTER SELECTOR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
                child: Row(
                  children: [
                    const Icon(Icons.history_edu, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedSemester,
                      underline: const SizedBox(),
                      items: ['Ganjil 2025/2026', 'Genap 2025/2026', 'Ganjil 2024/2025'].map((e) => 
                        DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) => setState(() => _selectedSemester = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 1. PROGRESS PENILAIAN (WIDE TABLE)
          _buildSectionHeader('Progress Input Nilai & Ketuntasan per Kategori', Icons.analytics_outlined, Colors.blue),
          _buildProgressPenilaianTable(),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. GURU BELUM INPUT NILAI
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Guru Belum Input Nilai', Icons.pending_actions, Colors.red),
                    _buildGuruBelumInputTable(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // 3. KELAS BELUM ABSENSI
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Kelas Belum Absensi Hari Ini', Icons.event_busy, Colors.orange),
                    _buildKelasBelumAbsensiTable(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
        ],
      ),
    );
  }

  Widget _buildProgressPenilaianTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
          columns: const [
            DataColumn(label: Text('Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Absensi', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Sikap/Siswa', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('UH (Harian)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('PTS', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('PAS / UAS', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status Akhir', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: [
            _buildProgressRow('Matematika', 'X IPA 1', '98%', 'A', '90%', '100%', '0%', 75, Colors.blue),
            _buildProgressRow('B. Indonesia', 'XI IPS 2', '100%', 'B+', '100%', '100%', '100%', 100, Colors.green),
            _buildProgressRow('Fisika', 'XII IPA 1', '85%', 'B', '40%', '0%', '0%', 25, Colors.orange),
            _buildProgressRow('Sejarah', 'X IPS 1', '95%', 'A-', '100%', '100%', '0%', 80, Colors.blue),
          ],
        ),
      ),
    );
  }

  DataRow _buildProgressRow(String mapel, String kelas, String absensi, String sikap, String uh, String pts, String pas, double progress, Color color) {
    return DataRow(cells: [
      DataCell(Text(mapel, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(kelas)),
      DataCell(Text(absensi, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
      DataCell(Text(sikap, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold))),
      DataCell(Text(uh)),
      DataCell(Text(pts)),
      DataCell(Text(pas)),
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${progress.toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: color.withOpacity(0.1),
                color: color,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildGuruBelumInputTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSimpleRow('Nama Guru', 'Mata Pelajaran', 'Ket.', isHeader: true),
          const Divider(),
          _buildSimpleRow('Ahmad Fauzi, S.Pd', 'Matematika - X IPA 1', 'PAS Belum', color: Colors.red),
          _buildSimpleRow('Lina Marlina, S.Si', 'Biologi - XI IPA 2', 'Tugas 4 Belum', color: Colors.orange),
          _buildSimpleRow('Drs. Joko Susilo', 'Sejarah - XII IPS 1', 'PH 2 Belum', color: Colors.orange),
          _buildSimpleRow('Rina Fitriani, M.Pd', 'B. Inggris - X IPS 2', 'PTS Belum', color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildKelasBelumAbsensiTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSimpleRow('Kelas', 'Wali Kelas', 'Status', isHeader: true),
          const Divider(),
          _buildSimpleRow('X IPA 2', 'H. Muhidin', 'Belum Absen', color: Colors.red),
          _buildSimpleRow('XI IPS 3', 'Siti Aminah', 'Belum Absen', color: Colors.red),
          _buildSimpleRow('XII IPA 2', 'Budi Santoso', 'Belum Absen', color: Colors.red),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.notifications_active_outlined, size: 16),
            label: const Text('Ingatkan Semua Wali Kelas', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSimpleRow(String col1, String col2, String col3, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(col1, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.w600, fontSize: 13))),
          Expanded(flex: 3, child: Text(col2, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
          Expanded(flex: 2, child: Text(col3, textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color ?? (isHeader ? Colors.black : Colors.grey.shade800)))),
        ],
      ),
    );
  }
}
