import 'package:flutter/material.dart';
import '../services/bimbel_service.dart';
import '../models/teacher_models.dart';
import '../bimbel_submenus_screen.dart';
import '../../../core/mixins/safe_async_mixin.dart';

class BimbelNilaiUnifiedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> myPrograms;
  final String teacherId;

  const BimbelNilaiUnifiedScreen({super.key, required this.myPrograms, required this.teacherId});

  @override
  State<BimbelNilaiUnifiedScreen> createState() => _BimbelNilaiUnifiedScreenState();
}

class _BimbelNilaiUnifiedScreenState extends State<BimbelNilaiUnifiedScreen> with SafeAsync {
  final _service = BimbelService();
  int _activeTab = 0; // 0: Input Nilai, 1: Rekap Nilai, 2: Analisis
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
        title: const Text('Nilai & Evaluasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade800,
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
      color: Colors.orange.shade800,
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
          _buildMenuItem(0, 'Input Nilai', Icons.edit_document, Colors.orange),
          _buildMenuItem(1, 'Rekap Nilai', Icons.assignment_turned_in, Colors.blue),
          _buildMenuItem(2, 'Analisis', Icons.analytics_outlined, Colors.purple),
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
      return _buildAnalisisView();
    }
    
    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Belum ada sesi untuk program ini', style: TextStyle(color: Colors.grey)),
            const Text('Buat sesi baru di menu Jadwal atau Materi', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
              backgroundColor: (_activeTab == 0 ? Colors.orange : Colors.blue).withOpacity(0.1),
              child: Icon(_activeTab == 0 ? Icons.edit : Icons.visibility, color: _activeTab == 0 ? Colors.orange : Colors.blue, size: 20),
            ),
            title: Text(s.topic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(s.sessionDate.toString().split(' ')[0], style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => BimbelNilaiScreen(
                 isRekap: _activeTab == 1,
                 sessionId: s.id,
                 programId: s.programId ?? '',
               )));
            },
          ),
        );
      },
    );
  }

  Widget _buildAnalisisView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ringkasan Performa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildStatCard('Total Sesi Dinilai', '${_sessions.length}', Icons.check_circle_outline, Colors.green),
          const SizedBox(height: 16),
          _buildStatCard('Rata-rata Nilai Program', '84.5', Icons.star_border, Colors.orange),
          const SizedBox(height: 16),
          _buildStatCard('Partisipasi Siswa', '92%', Icons.people_outline, Colors.blue),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.purple),
                SizedBox(width: 16),
                Expanded(child: Text('Gunakan menu Rekap Nilai untuk melihat detail nilai per siswa.', style: TextStyle(fontSize: 12, color: Colors.purple))),
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
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
