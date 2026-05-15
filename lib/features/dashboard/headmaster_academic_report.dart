import 'package:flutter/material.dart';
import '../../core/network/d1_service.dart';

class HeadmasterAcademicReport extends StatefulWidget {
  const HeadmasterAcademicReport({super.key});

  @override
  State<HeadmasterAcademicReport> createState() => _HeadmasterAcademicReportState();
}

class _HeadmasterAcademicReportState extends State<HeadmasterAcademicReport> {
  final _d1Service = D1Service();
  List<Map<String, dynamic>> _classStats = [];
  int _totalStudents = 0;
  int _totalTeachers = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAcademicStats();
  }

  Future<void> _fetchAcademicStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Ambil data kelas
      final classData = await _d1Service.query(
        """
        SELECT k.*, g.nama as guru_nama 
        FROM kelas k
        LEFT JOIN guru g ON k.wali_id = g.id
        ORDER BY k.nama ASC
        """
      );
      
      // 2. Ambil total siswa
      final studentRes = await _d1Service.query("SELECT COUNT(*) as total FROM siswa");
      
      // 3. Ambil total guru
      final teacherRes = await _d1Service.query("SELECT COUNT(*) as total FROM guru");

      setState(() {
        _classStats = List<Map<String, dynamic>>.from(classData as List);
        _totalStudents = (studentRes as List).isNotEmpty ? studentRes.first['total'] : 0;
        _totalTeachers = (teacherRes as List).isNotEmpty ? teacherRes.first['total'] : 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data akademik dari D1.";
        _isLoading = false;
      });
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
            'Laporan Akademik',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),
          
          // SUMMARY CARDS
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Siswa', _totalStudents.toString(), Icons.people, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Guru & Staf', _totalTeachers.toString(), Icons.school, Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 24),
          _buildClassTable(),
        ],
      ),
    );
  }

  Widget _buildClassTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rekapitulasi per Kelas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!))
          else if (_classStats.isEmpty)
            const Center(child: Text('Belum ada data kelas.'))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nama Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Wali Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _classStats.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['nama'] ?? '-')),
                      DataCell(Text(item['guru_nama'] ?? 'Belum ditentukan')),
                      DataCell(TextButton(onPressed: () {}, child: const Text('Detail'))),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
        ],
      ),
    );
  }
}
