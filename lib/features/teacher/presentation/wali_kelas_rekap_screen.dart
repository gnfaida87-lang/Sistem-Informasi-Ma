import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/wali_kelas_service.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import '../../../core/providers/auth_provider.dart';

class WaliKelasRekapScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const WaliKelasRekapScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  ConsumerState<WaliKelasRekapScreen> createState() => _WaliKelasRekapScreenState();
}

class _WaliKelasRekapScreenState extends ConsumerState<WaliKelasRekapScreen> with SafeAsync {
  final _waliKelasService = WaliKelasService();
  List<Map<String, dynamic>> _grades = [];
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    await safeCall(
      context: context,
      action: () async {
        final results = await Future.wait([
          _waliKelasService.fetchClassGradesRecap(widget.classId),
          _waliKelasService.fetchClassAttendanceRecap(widget.classId),
          _waliKelasService.fetchClassNotes(widget.classId),
        ]);

        setState(() {
          _grades = List<Map<String, dynamic>>.from(results[0]);
          _attendance = List<Map<String, dynamic>>.from(results[1]);
          _notes = List<Map<String, dynamic>>.from(results[2]);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Rekap Kelas ${widget.className}', style: const TextStyle(fontSize: 16)),
          backgroundColor: const Color(0xFF2B3674),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Akademik'),
              Tab(text: 'Absensi'),
              Tab(text: 'Catatan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAkademikTab(),
            _buildAbsensiTab(),
            _buildCatatanTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAkademikTab() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (_grades.isEmpty) return const Center(child: Text('Belum ada data nilai.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _grades.length,
      itemBuilder: (context, index) {
        final item = _grades[index];
        return Card(
          child: ListTile(
            title: Text(item['mapel_nama'] ?? 'Mata Pelajaran'),
            trailing: Text(item['skor']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        );
      },
    );
  }

  Widget _buildAbsensiTab() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (_attendance.isEmpty) return const Center(child: Text('Belum ada data absensi.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _attendance.length,
      itemBuilder: (context, index) {
        final item = _attendance[index];
        return ListTile(
          title: Text(item['siswa_nama'] ?? 'Siswa'),
          trailing: _buildStatusBadge(item['status'] ?? '-'),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'H') color = Colors.green;
    if (status == 'S') color = Colors.orange;
    if (status == 'I') color = Colors.blue;
    if (status == 'A') color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCatatanTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showAddNoteDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Catatan'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3674), foregroundColor: Colors.white),
          ),
        ),
        Expanded(
          child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note['kategori'] ?? 'Umum', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            const SizedBox(height: 4),
                            Text(note['catatan'] ?? ''),
                            const Divider(),
                            Text('Oleh: ${note['guru_nama'] ?? 'Guru'}', style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddNoteDialog() {
    final noteController = TextEditingController();
    String selectedCategory = 'Perilaku';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Tambah Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: ['Perilaku', 'Akademik', 'Kesehatan', 'Lainnya'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setModalState(() => selectedCategory = v!),
              ),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Isi catatan...'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final user = ref.read(authProvider).user;
                if (user == null) return;
                
                final teacherId = await _waliKelasService.getTeacherIdByUserId(user.id);
                if (teacherId == null) return;

                await _waliKelasService.addClassNote(widget.classId, teacherId, selectedCategory, noteController.text);
                if (mounted) {
                  Navigator.pop(context);
                  _loadAllData();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
