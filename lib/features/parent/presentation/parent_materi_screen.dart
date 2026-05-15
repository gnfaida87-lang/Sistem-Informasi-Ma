import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/parent_service.dart';

class ParentMateriScreen extends StatefulWidget {
  final String studentId;
  const ParentMateriScreen({super.key, required this.studentId});

  @override
  State<ParentMateriScreen> createState() => _ParentMateriScreenState();
}

class _ParentMateriScreenState extends State<ParentMateriScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = ParentService();

  List<Map<String, dynamic>> _materi   = [];
  List<Map<String, dynamic>> _tugas    = [];
  List<Map<String, dynamic>> _subjects = [];
  String? _selectedSubject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final results = await Future.wait([
        _service.getChildMateri(widget.studentId),
        _service.getChildTugas(widget.studentId),
        _service.getChildSubjects(widget.studentId),
      ]);
      setState(() {
        _materi   = results[0] as List<Map<String, dynamic>>;
        _tugas    = results[1] as List<Map<String, dynamic>>;
        _subjects = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredMateri => _selectedSubject == null
      ? _materi
      : _materi.where((m) => m['subject_id'] == _selectedSubject).toList();

  List<Map<String, dynamic>> get _filteredTugas => _selectedSubject == null
      ? _tugas
      : _tugas.where((t) => t['subject_id'] == _selectedSubject).toList();

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka link'),
            backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Materi & Tugas',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Materi (${_filteredMateri.length})'),
            Tab(text: 'Tugas (${_filteredTugas.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Column(children: [
              // Filter mapel
              if (_subjects.isNotEmpty) _buildFilter(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMateriList(),
                    _buildTugasList(),
                  ],
                ),
              ),
            ]),
    );
  }

  Widget _buildFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('Semua', null),
            ..._subjects.map((s) => _filterChip(
                s['nama'] ?? s['name'] ?? '-', s['id']?.toString())),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String? id) {
    final isSelected = _selectedSubject == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubject = id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.shade700 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.purple.shade700 : Colors.grey.shade300),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700)),
        ),
      ),
    );
  }

  Widget _buildMateriList() {
    if (_filteredMateri.isEmpty) return _emptyState('Belum ada materi', Icons.library_books_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMateri.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _buildMateriCard(_filteredMateri[i]),
    );
  }

  Widget _buildMateriCard(Map<String, dynamic> item) {
    final type    = item['type'] ?? 'link';
    final typeInfo = _typeInfo(type);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeInfo['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(typeInfo['icon'] as IconData, color: typeInfo['color'] as Color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['judul'] ?? item['title'] ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(item['subject_name'] ?? '-',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: typeInfo['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(6)),
            child: Text(typeInfo['label'] as String,
                style: TextStyle(fontSize: 10, color: typeInfo['color'] as Color, fontWeight: FontWeight.bold)),
          ),
        ]),
        if (item['url'] != null && (item['url'] as String).isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _openUrl(item['url']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(Icons.open_in_new, size: 14, color: Colors.purple.shade700),
                    const SizedBox(width: 6),
                    Text('Buka Materi',
                        style: TextStyle(color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: item['url']));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Link disalin!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.copy, size: 16, color: Colors.grey.shade600),
              ),
            ),
          ]),
        ],
        if (item['created_at'] != null) ...[
          const SizedBox(height: 6),
          Text('Diunggah: ${(item['created_at'] as String).split('T')[0]}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        ],
      ]),
    );
  }

  Widget _buildTugasList() {
    if (_filteredTugas.isEmpty) return _emptyState('Belum ada tugas', Icons.assignment_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTugas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _buildTugasCard(_filteredTugas[i]),
    );
  }

  Widget _buildTugasCard(Map<String, dynamic> item) {
    final deadline  = item['deadline'] as String?;
    final isExpired = deadline != null && DateTime.tryParse(deadline)?.isBefore(DateTime.now()) == true;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired ? Colors.red.shade200 : Colors.orange.shade200,
          width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isExpired ? Colors.red.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.assignment, color: isExpired ? Colors.red : Colors.orange.shade700, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item['judul'] ?? item['title'] ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(item['subject_name'] ?? '-',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
          if (isExpired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
              child: const Text('Lewat Batas',
                  style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
            ),
        ]),
        if (item['deskripsi'] != null && (item['deskripsi'] as String).isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(item['deskripsi'], style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.calendar_today, size: 12, color: isExpired ? Colors.red : Colors.orange.shade700),
          const SizedBox(width: 4),
          Text('Deadline: ${deadline?.split('T')[0] ?? '-'}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isExpired ? Colors.red : Colors.orange.shade700)),
        ]),
        if (item['url'] != null && (item['url'] as String).isNotEmpty) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _openUrl(item['url']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.open_in_new, size: 14, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Text('Lihat Detail Tugas',
                    style: TextStyle(color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ]),
            ),
          ),
        ],
      ]),
    );
  }

  Map<String, dynamic> _typeInfo(String type) {
    switch (type) {
      case 'youtube': return {'icon': Icons.play_circle, 'color': Colors.red.shade700, 'label': 'Video'};
      case 'zoom':    return {'icon': Icons.video_call, 'color': Colors.blue.shade700, 'label': 'Meeting'};
      case 'drive':   return {'icon': Icons.cloud, 'color': Colors.green.shade700, 'label': 'Drive'};
      case 'cbt':     return {'icon': Icons.quiz, 'color': Colors.orange.shade700, 'label': 'Latihan'};
      default:        return {'icon': Icons.link, 'color': Colors.purple.shade700, 'label': 'Materi'};
    }
  }

  Widget _emptyState(String msg, IconData icon) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 56, color: Colors.grey.shade300),
      const SizedBox(height: 8),
      Text(msg, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
    ]),
  );
}
