import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';

class TeacherExamProctoringScreen extends StatefulWidget {
  final String teacherName;
  const TeacherExamProctoringScreen({super.key, required this.teacherName});

  @override
  State<TeacherExamProctoringScreen> createState() => _TeacherExamProctoringScreenState();
}

class _TeacherExamProctoringScreenState extends State<TeacherExamProctoringScreen> {
  final _d1Service = D1Service();
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProctoringSchedule();
  }

  Future<void> _fetchProctoringSchedule() async {
    setState(() => _isLoading = true);
    try {
      // Cari jadwal di mana nama guru ini terdaftar sebagai supervisor_name
      final results = await _d1Service.query(
        "SELECT * FROM exam_schedules WHERE supervisor_name = ? ORDER BY date_label ASC, session_name ASC",
        params: [widget.teacherName],
      );
      setState(() {
        _schedules = results.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Jadwal Mengawas Ujian', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? _buildEmptyState()
              : _buildScheduleList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Anda tidak memiliki jadwal mengawas ujian.', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final item = _schedules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.fact_check, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['subject_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${item['date_label']} | ${item['session_name']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text('Waktu: ${item['time_range']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Text(item['room_name'] ?? '-', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    const SizedBox(height: 4),
                    Text('Kelas ${item['class_level']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
