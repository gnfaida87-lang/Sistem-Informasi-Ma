import 'package:flutter/material.dart';

class WakakurLaporanBimbel extends StatefulWidget {
  const WakakurLaporanBimbel({super.key});

  @override
  State<WakakurLaporanBimbel> createState() => _WakakurLaporanBimbelState();
}

class _WakakurLaporanBimbelState extends State<WakakurLaporanBimbel> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Layanan Bimbel',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 8),
          const Text('Monitoring keaktifan peserta dan kehadiran instruktur bimbingan belajar.', 
            style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 32),

          // 1. STATS SUMMARY (PESERTA AKTIF)
          _buildStatsSummary(),
          const SizedBox(height: 32),

          // 2. KEHADIRAN GURU BIMBEL
          _buildSectionHeader('Kehadiran Guru / Instruktur Bimbel', Icons.person_search_outlined, Colors.purple),
          _buildTeacherAttendanceTable(),
          const SizedBox(height: 32),

          // 3. KEHADIRAN SISWA BIMBEL
          _buildSectionHeader('Monitoring Kehadiran Siswa per Program', Icons.people_outline, Colors.teal),
          _buildStudentAttendanceProgress(),
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

  Widget _buildStatsSummary() {
    return Row(
      children: [
        _buildStatCard('Total Peserta Aktif', '124', 'Siswa Terdaftar', Icons.groups, Colors.blue),
        const SizedBox(width: 20),
        _buildStatCard('Program Aktif', '6', 'Fokus Olimpiade & UTBK', Icons.auto_graph, Colors.orange),
        const SizedBox(width: 20),
        _buildStatCard('Rata-rata Kehadiran', '92%', 'Bulan Februari', Icons.check_circle_outline, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                Text(subtitle, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherAttendanceTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nama Pengajar')),
          DataColumn(label: Text('Mata Pelajaran')),
          DataColumn(label: Text('Jadwal Sesi')),
          DataColumn(label: Text('Status Kehadiran')),
        ],
        rows: [
          _teacherRow('Drs. Heru Prasetyo', 'Fisika Olimpiade', '15:30 - 17:00', 'HADIR', Colors.green),
          _teacherRow('Lina Marlina, S.Si', 'Biologi Kedokteran', '15:30 - 17:00', 'HADIR', Colors.green),
          _teacherRow('Ahmad Fauzi, S.Pd', 'Matematika UTBK', '15:30 - 17:00', 'IJIN (Diganti)', Colors.orange),
          _teacherRow('Siti Aminah, M.Pd', 'B. Inggris TOEFL', '15:30 - 17:00', 'BELUM ABSEN', Colors.red),
        ],
      ),
    );
  }

  DataRow _teacherRow(String name, String mapel, String session, String status, Color color) {
    return DataRow(cells: [
      DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(mapel)),
      DataCell(Text(session)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ),
      ),
    ]);
  }

  Widget _buildStudentAttendanceProgress() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      shrinkWrap: true,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _studentProgessCard('Kelas Intensif UTBK - Saintek', 45, 42),
        _studentProgessCard('Kelas Intensif UTBK - Soshum', 38, 35),
        _studentProgessCard('Olimpiade Matematika', 12, 12),
        _studentProgessCard('Olimpiade Fisika', 15, 13),
      ],
    );
  }

  Widget _studentProgessCard(String title, int total, int hadir) {
    double percent = hadir / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hadir: $hadir / $total Siswa', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text('${(percent * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.teal.withOpacity(0.1),
            color: Colors.teal,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
