import 'package:flutter/material.dart';
import '../services/parent_service.dart';
import 'parent_exam_schedule_screen.dart';

class ParentAkademikScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String classLevel;

  const ParentAkademikScreen({super.key, required this.studentId, required this.studentName, required this.classLevel});

  @override
  State<ParentAkademikScreen> createState() => _ParentAkademikScreenState();
}

class _ParentAkademikScreenState extends State<ParentAkademikScreen> {
  final _service = ParentService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _grades = [];
  List<Map<String, dynamic>> _attendanceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.getStudentGrades(widget.studentId),
        // Kita gunakan kueri langsung untuk riwayat absensi jika belum ada di service
        // Untuk sekarang kita tampilkan yang ada
      ]);
      
      setState(() {
        _grades = results[0];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akademik: ${widget.studentName}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2B3674),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : DefaultTabController(
            length: 3,
            child: Column(
              children: [
                const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: 'Nilai Siswa'),
                    Tab(text: 'Absensi'),
                    Tab(text: 'Jadwal Ujian'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildGradesTab(),
                      _buildAttendanceTab(),
                      ParentExamScheduleScreen(classLevel: widget.classLevel, studentName: widget.studentName),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildGradesTab() {
    if (_grades.isEmpty) {
      return const Center(child: Text('Belum ada data nilai tersedia.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _grades.length,
      itemBuilder: (context, index) {
        final g = _grades[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(g['mapel_nama'] ?? 'Mata Pelajaran', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Jenis: ${g['jenis_ujian'] ?? '-'}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                '${g['nilai'] ?? 0}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fact_check_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Fitur riwayat absensi sedang disinkronkan.'),
        ],
      ),
    );
  }
}
