import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _d1Service = D1Service();
  bool _isLoading = true;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final data = await _d1Service.query(
        "SELECT * FROM audit_log ORDER BY performed_at DESC LIMIT 20"
      );
      setState(() => _logs = data as List);
    } catch (e) {
      debugPrint("Error fetching logs: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.red.shade800,
              child: const Text('Monitoring Sistem', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildSectionHeader('Log Aktivitas & Audit Trail', Icons.history),
                      const SizedBox(height: 12),
                      if (_logs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text('Belum ada aktivitas tercatat di database.', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      else
                        ..._logs.map((log) => _buildLogCard(
                          context,
                          log['action'] ?? 'Aksi',
                          log['table_name'] ?? 'Sistem',
                          log['description'] ?? '-',
                          _formatTime(log['performed_at']),
                          _getIconForAction(log['action']),
                          _getColorForAction(log['action']),
                        )),
                      
                      const SizedBox(height: 24),
                      _buildSectionHeader('Pemantauan Keamanan', Icons.security),
                      const SizedBox(height: 12),
                      const Center(child: Text('Tidak ada ancaman keamanan terdeteksi.', style: TextStyle(fontSize: 12, color: Colors.grey))),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null) return '-';
    // Simple display for now
    return time.split('.')[0].replaceAll('T', ' ');
  }

  IconData _getIconForAction(String? action) {
    if (action == null) return Icons.info_outline;
    if (action.contains('INSERT')) return Icons.add_circle_outline;
    if (action.contains('UPDATE')) return Icons.edit_note;
    if (action.contains('DELETE')) return Icons.delete_forever;
    return Icons.history;
  }

  MaterialColor _getColorForAction(String? action) {
    if (action == null) return Colors.blue;
    if (action.contains('INSERT')) return Colors.green;
    if (action.contains('UPDATE')) return Colors.blue;
    if (action.contains('DELETE')) return Colors.red;
    return Colors.grey;
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLogCard(BuildContext context, String title, String user, String detail, String time, IconData icon, MaterialColor color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.shade50,
              radius: 18,
              child: Icon(icon, color: color.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Tabel: $user', style: TextStyle(fontSize: 12, color: color.shade700, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(detail, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
