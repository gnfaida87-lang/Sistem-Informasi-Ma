import 'package:flutter/material.dart';
import '../services/bimbel_service.dart';
import '../models/teacher_models.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import 'package:intl/intl.dart';

class BimbelJadwalScreen extends StatefulWidget {
  final String teacherId;
  const BimbelJadwalScreen({super.key, required this.teacherId});

  @override
  State<BimbelJadwalScreen> createState() => _BimbelJadwalScreenState();
}

class _BimbelJadwalScreenState extends State<BimbelJadwalScreen> with SafeAsync {
  final _service = BimbelService();
  List<BimbelSession> _allSessions = [];
  Map<String, List<BimbelSession>> _groupedSessions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await safeCall(
      context: context,
      action: () async {
        final sessions = await _service.fetchTutorSessions(widget.teacherId);
        setState(() {
          _allSessions = sessions;
          _groupedSessions = {};
          for (var s in sessions) {
            final progName = s.programName ?? 'Bimbel';
            if (!_groupedSessions.containsKey(progName)) {
              _groupedSessions[progName] = [];
            }
            _groupedSessions[progName]!.add(s);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Jadwal Lengkap Bimbel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allSessions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _groupedSessions.length,
                  itemBuilder: (context, index) {
                    final programName = _groupedSessions.keys.elementAt(index);
                    final sessions = _groupedSessions[programName]!;
                    return _buildProgramGroup(programName, sessions);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Belum ada jadwal yang disetting', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildProgramGroup(String programName, List<BimbelSession> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4, height: 24,
                decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Text(programName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(20)),
                child: Text('${sessions.length} Pertemuan', style: TextStyle(color: Colors.deepPurple.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        ...sessions.map((s) => _buildSessionCard(s)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSessionCard(BimbelSession s) {
    final dateStr = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(s.sessionDate);
    final timeStr = DateFormat('HH:mm').format(s.sessionDate);
    final isPast = s.sessionDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text('WIB', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.topic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (isPast)
            const Icon(Icons.check_circle, color: Colors.green, size: 20)
          else
             Icon(Icons.pending_actions, color: Colors.orange.shade300, size: 20),
        ],
      ),
    );
  }
}
