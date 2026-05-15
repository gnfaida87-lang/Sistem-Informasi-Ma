import 'package:flutter/material.dart';
import '../teacher/services/bimbel_service.dart';

class WakakurLaporanBimbel extends StatefulWidget {
  const WakakurLaporanBimbel({super.key});

  @override
  State<WakakurLaporanBimbel> createState() => _WakakurLaporanBimbelState();
}

class _WakakurLaporanBimbelState extends State<WakakurLaporanBimbel> {
  final _bimbelService = BimbelService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _programSummaries = [];
  int _totalStudents = 0;
  int _totalPrograms = 0;
  double _avgAttendance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final summaries = await _bimbelService.fetchProgramSummaries();
      
      int totalS = 0;
      double totalAvg = 0;
      for (var s in summaries) {
        totalS += (s['student_count'] as int);
        totalAvg += (s['avg_score'] ?? 0.0);
      }

      setState(() {
        _programSummaries = summaries;
        _totalPrograms = summaries.length;
        _totalStudents = totalS;
        _avgAttendance = summaries.isNotEmpty ? (totalAvg / summaries.length) : 0;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load bimbel report: $e");
      setState(() => _isLoading = false);
    }
  }
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
        _buildStatCard('Total Peserta Aktif', '$_totalStudents', '$_totalStudents Siswa', Icons.groups, Colors.blue),
        const SizedBox(width: 20),
        _buildStatCard('Program Aktif', '$_totalPrograms', '$_totalPrograms Kelas', Icons.auto_graph, Colors.orange),
        const SizedBox(width: 20),
        _buildStatCard('Rata-rata Nilai', '${_avgAttendance.toInt()}', 'Seluruh Program', Icons.check_circle_outline, Colors.green),
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
          DataColumn(label: Text('Total Sesi')),
          DataColumn(label: Text('Progres Nilai')),
        ],
        rows: _programSummaries.map((p) {
          double score = p['avg_score'] ?? 0.0;
          return _teacherRow(
            p['teacher_name'], 
            p['nama'], 
            '${p['session_count']} Sesi', 
            '${score.toInt()}', 
            score > 80 ? Colors.green : Colors.orange
          );
        }).toList(),
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
    if (_programSummaries.isEmpty) {
      return const Center(child: Text('Belum ada program bimbel yang berjalan.', style: TextStyle(color: Colors.grey, fontSize: 12)));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.5,
      ),
      itemCount: _programSummaries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final p = _programSummaries[index];
        return _studentProgessCard(p['nama'], p['student_count'], (p['student_count'] * 0.85).toInt()); // Mock attendance for now
      },
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
