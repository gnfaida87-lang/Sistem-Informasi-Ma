import 'package:flutter/material.dart';
import '../services/bimbel_service.dart';
import '../models/teacher_models.dart';
import '../bimbel_submenus_screen.dart';
import '../../../core/mixins/safe_async_mixin.dart';

class BimbelAbsensiUnifiedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> myPrograms;
  final String teacherId;

  const BimbelAbsensiUnifiedScreen({super.key, required this.myPrograms, required this.teacherId});

  @override
  State<BimbelAbsensiUnifiedScreen> createState() => _BimbelAbsensiUnifiedScreenState();
}

class _BimbelAbsensiUnifiedScreenState extends State<BimbelAbsensiUnifiedScreen> with SafeAsync {
  final _service = BimbelService();
  int _activeTab = 0; // 0: Input Absensi, 1: Riwayat, 2: Rekap
  Map<String, dynamic>? _selectedProgram;
  List<BimbelSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    if (widget.myPrograms.isNotEmpty) {
      _selectedProgram = widget.myPrograms.first;
      _loadSessions();
    }
  }

  Future<void> _loadSessions() async {
    if (_selectedProgram == null) return;
    await safeCall(
      context: context,
      action: () async {
        final all = await _service.fetchTutorSessions(widget.teacherId);
        setState(() {
          _sessions = all.where((s) => s.programId == _selectedProgram!['id']).toList();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Absensi Siswa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildProgramPicker(),
          _buildTopMenu(),
          Expanded(
            child: _selectedProgram == null 
              ? const Center(child: Text('Belum ada program bimbel'))
              : _buildActiveView(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade700,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedProgram,
            isExpanded: true,
            hint: const Text('Pilih Program'),
            items: widget.myPrograms.map((p) => DropdownMenuItem(
              value: p,
              child: Text(p['nama'] ?? 'Bimbel', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            )).toList(),
            onChanged: (val) {
              setState(() => _selectedProgram = val);
              _loadSessions();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuItem(0, 'Input Absen', Icons.fact_check, Colors.green),
          _buildMenuItem(1, 'Riwayat', Icons.history_edu, Colors.blue),
          _buildMenuItem(2, 'Statistik', Icons.pie_chart_outline, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String label, IconData icon, Color color) {
    bool isActive = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))] : [],
            ),
            child: Icon(icon, color: isActive ? Colors.white : color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? color : Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildActiveView() {
    if (_activeTab == 2) {
      return _buildStatsView();
    }
    
    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Tidak ada sesi untuk absensi', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final s = _sessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(_activeTab == 0 ? Icons.how_to_reg : Icons.history, color: Colors.green, size: 20),
            ),
            title: Text(s.topic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(s.sessionDate.toString().split(' ')[0], style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => BimbelAbsensiScreen(
                 isRiwayat: _activeTab == 1,
                 sessionId: s.id,
                 programId: s.programId ?? '',
               )));
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Kehadiran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildStatCard('Total Pertemuan', '${_sessions.length}', Icons.event_available, Colors.green),
          const SizedBox(height: 16),
          _buildStatCard('Rata-rata Kehadiran', '95%', Icons.check_circle_outline, Colors.teal),
          const SizedBox(height: 16),
          _buildStatCard('Siswa Paling Rajin', 'Budi Santoso', Icons.person_outline, Colors.blue),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.green),
                SizedBox(width: 16),
                Expanded(child: Text('Tingkat kehadiran yang tinggi menunjukkan antusiasme siswa yang baik.', style: TextStyle(fontSize: 12, color: Colors.green))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
