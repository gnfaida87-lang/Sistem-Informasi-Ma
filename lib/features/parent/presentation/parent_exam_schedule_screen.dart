import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';
import '../../../core/mixins/safe_async_mixin.dart';

class ParentExamScheduleScreen extends StatefulWidget {
  final String classLevel;
  final String studentName;
  const ParentExamScheduleScreen({super.key, required this.classLevel, required this.studentName});

  @override
  State<ParentExamScheduleScreen> createState() => _ParentExamScheduleScreenState();
}

class _ParentExamScheduleScreenState extends State<ParentExamScheduleScreen> with SafeAsync {
  final _d1Service = D1Service();
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      final results = await _d1Service.query(
        "SELECT * FROM exam_schedules WHERE class_level = ? ORDER BY date_label ASC, session_name ASC",
        params: [widget.classLevel],
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Jadwal Ujian Anak', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
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
          Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Belum ada jadwal ujian untuk Kelas ${widget.classLevel}', style: TextStyle(color: Colors.grey.shade500)),
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
          elevation: 2,
          shadowColor: Colors.black12,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text(item['date_label']?.replaceAll('Hari Ke-', 'H') ?? '-', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 18)),
                      const Text('DAY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['subject_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2B3674))),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${item['session_name']} (${item['time_range']})', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.meeting_room, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('Ruang: ${item['room_name']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
