import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../services/parent_service.dart';
import 'package:flutter/foundation.dart';

class ParentBimbelScreen extends StatefulWidget {
  final String studentId;
  const ParentBimbelScreen({super.key, required this.studentId});

  @override
  State<ParentBimbelScreen> createState() => _ParentBimbelScreenState();
}

class _ParentBimbelScreenState extends State<ParentBimbelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = ParentService();

  List<Map<String, dynamic>> _programs  = [];
  List<Map<String, dynamic>> _sessions  = [];
  List<Map<String, dynamic>> _progress  = [];
  List<Map<String, dynamic>> _meetings  = [];
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  String? _selectedProgram;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final programs = await _service.getStudentBimbelDetail(widget.studentId);
      setState(() { _programs = programs; });

      if (programs.isNotEmpty) {
        _selectedProgram = programs[0]['program_id']?.toString();
        await _loadProgramDetail(_selectedProgram!);
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProgramDetail(String programId) async {
    try {
      final results = await Future.wait([
        _service.getBimbelSessions(programId),
        _service.getBimbelProgress(programId, widget.studentId),
        _service.getBimbelMeetings(programId),
        _service.getBimbelQuestions(programId),
      ]);
      setState(() {
        _sessions  = results[0] as List<Map<String, dynamic>>;
        _progress  = results[1] as List<Map<String, dynamic>>;
        _meetings  = results[2] as List<Map<String, dynamic>>;
        _questions = results[3] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      debugPrint('Error loadProgramDetail: $e');
    }
  }

  double get _avgScore {
    if (_progress.isEmpty) return 0;
    final scores = _progress.map((p) => (p['score'] as num?)?.toDouble() ?? 0).toList();
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  int get _hadirCount => _progress.where((p) =>
      p['is_present'] == 1 || p['is_present'] == true).length;

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Info Bimbel', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Progress'),
            Tab(text: 'Jadwal'),
            Tab(text: 'Pertemuan'),
            Tab(text: 'Latihan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _programs.isEmpty
              ? _notEnrolled()
              : Column(children: [
                  if (_programs.length > 1) _buildProgramSelector(),
                  _buildSummaryCard(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProgressTab(),
                        _buildJadwalTab(),
                        _buildMeetingsTab(),
                        _buildLatihanTab(),
                      ],
                    ),
                  ),
                ]),
    );
  }

  Widget _buildProgramSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedProgram,
        decoration: InputDecoration(
          labelText: 'Pilih Program',
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: _programs.map((p) => DropdownMenuItem(
          value: p['program_id']?.toString(),
          child: Text(p['program_name'] ?? '-', style: const TextStyle(fontSize: 13)),
        )).toList(),
        onChanged: (val) {
          setState(() => _selectedProgram = val);
          if (val != null) _loadProgramDetail(val);
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    final program = _programs.firstWhere(
      (p) => p['program_id']?.toString() == _selectedProgram,
      orElse: () => {});

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade800, Colors.teal.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.stars, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(program['program_name'] ?? 'Program Bimbel', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ]),
        const SizedBox(height: 4),
        Text('Guru: ${program['teacher_name'] ?? '-'}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _statItem('Sesi', '${_sessions.length}'),
          _divider(),
          _statItem('Kehadiran', '$_hadirCount'),
          _divider(),
          _statItem('Rata-rata', _avgScore.toStringAsFixed(1)),
        ]),
      ]),
    );
  }

  Widget _statItem(String label, String value) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
  ]);

  Widget _divider() => Container(width: 1, height: 30, color: Colors.white24);

  Widget _buildProgressTab() {
    if (_progress.isEmpty) return _emptyState('Belum ada data nilai', Icons.analytics_outlined);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _progress.length,
      itemBuilder: (_, i) {
        final p = _progress[i];
        final score = (p['score'] as num?)?.toDouble() ?? 0;
        final hadir = p['is_present'] == 1 || p['is_present'] == true;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: _scoreColor(score).withOpacity(0.1), child: Text(score.toStringAsFixed(0), style: TextStyle(color: _scoreColor(score), fontWeight: FontWeight.bold))),
            title: Text(p['topic'] ?? 'Sesi Bimbel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(p['session_date']?.toString().split(' ')[0] ?? '', style: const TextStyle(fontSize: 11)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: hadir ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
              child: Text(hadir ? 'Hadir' : 'Absen', style: TextStyle(color: hadir ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJadwalTab() {
    if (_sessions.isEmpty) return _emptyState('Belum ada jadwal', Icons.calendar_today);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (_, i) {
        final s = _sessions[i];
        final isPast = DateTime.parse(s['session_date']).isBefore(DateTime.now());
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(isPast ? Icons.check_circle : Icons.schedule, color: isPast ? Colors.green : Colors.orange),
            title: Text(s['topic'] ?? 'Sesi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(s['session_date']?.toString().split(' ')[0] ?? '', style: const TextStyle(fontSize: 11)),
            trailing: Text('${s['duration_minutes'] ?? 60}m', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildMeetingsTab() {
    if (_meetings.isEmpty) return _emptyState('Belum ada materi pertemuan', Icons.library_books);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meetings.length,
      itemBuilder: (_, i) {
        final m = _meetings[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            leading: CircleAvatar(backgroundColor: Colors.teal.shade50, child: Text(m['meeting_number'] ?? '?', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold))),
            title: Text(m['title'] ?? 'Materi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            children: [
              if (m['drive_url']?.isNotEmpty == true) _materiLink(Icons.cloud, 'Materi (Drive)', m['drive_url'], Colors.blue),
              if (m['zoom_url']?.isNotEmpty == true) _materiLink(Icons.video_camera_front, 'Zoom/Meet', m['zoom_url'], Colors.green),
              if (m['video_url']?.isNotEmpty == true) _materiLink(Icons.play_circle, 'Video YouTube', m['video_url'], Colors.red),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _materiLink(IconData icon, String label, String url, Color color) => ListTile(
    leading: Icon(icon, color: color, size: 20),
    title: Text(label, style: const TextStyle(fontSize: 12)),
    trailing: const Icon(Icons.open_in_new, size: 14),
    onTap: () => _openUrl(url),
    dense: true,
  );

  Widget _buildLatihanTab() {
    if (_questions.isEmpty) return _emptyState('Belum ada latihan CBT', Icons.quiz);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _questions.length,
      itemBuilder: (_, i) {
        final q = _questions[i];
        final type = q['type']?.toString().toUpperCase() ?? 'PG';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800))),
            title: Text(q['question_text'] ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text('Batas waktu: ${q['time_limit_seconds'] ?? 60} detik', style: const TextStyle(fontSize: 10)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          ),
        );
      },
    );
  }

  Color _scoreColor(double s) => s >= 80 ? Colors.green : (s >= 65 ? Colors.orange : Colors.red);

  Widget _emptyState(String msg, IconData icon) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 48, color: Colors.grey.shade300), const SizedBox(height: 8), Text(msg, style: TextStyle(color: Colors.grey.shade400))]));

  Widget _notEnrolled() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.school_outlined, size: 64, color: Colors.grey), const SizedBox(height: 16), const Text('Anak Anda belum terdaftar di program bimbel.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))]));
}
