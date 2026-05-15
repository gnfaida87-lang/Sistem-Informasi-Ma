import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/bimbel_service.dart';
import '../../../core/mixins/safe_async_mixin.dart';

class BimbelLatihanUnifiedScreen extends StatefulWidget {
  final String programId;
  final String programName;

  const BimbelLatihanUnifiedScreen({super.key, required this.programId, required this.programName});

  @override
  State<BimbelLatihanUnifiedScreen> createState() => _BimbelLatihanUnifiedScreenState();
}

class _BimbelLatihanUnifiedScreenState extends State<BimbelLatihanUnifiedScreen> with SafeAsync {
  int _activeTab = 0; // 0: Tambah Pertemuan, 1: Tambah Soal, 2: Hasil Belajar, 3: Daftar Pertemuan
  final _service = BimbelService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Materi & Latihan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.programName, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTopMenu(),
          Expanded(
            child: _buildActiveView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuItem(0, 'Pertemuan', Icons.add_to_photos, Colors.blue),
          _buildMenuItem(1, 'Tambah Soal', Icons.quiz, Colors.orange),
          _buildMenuItem(2, 'Hasil', Icons.bar_chart, Colors.green),
          _buildMenuItem(3, 'Daftar', Icons.list_alt, Colors.purple),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Icon(icon, color: isActive ? Colors.white : color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? color : Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildActiveView() {
    switch (_activeTab) {
      case 0: return _TambahPertemuanForm(programId: widget.programId);
      case 1: return _TambahSoalCBT(programId: widget.programId);
      case 2: return _HasilBelajarView(programId: widget.programId);
      case 3: return _DaftarPertemuanList(programId: widget.programId);
      default: return const Center(child: Text('Select a menu'));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// 1. TAMBAH PERTEMUAN FORM
// ─────────────────────────────────────────────────────────────
class _TambahPertemuanForm extends StatefulWidget {
  final String programId;
  const _TambahPertemuanForm({required this.programId});

  @override
  State<_TambahPertemuanForm> createState() => _TambahPertemuanFormState();
}

class _TambahPertemuanFormState extends State<_TambahPertemuanForm> with SafeAsync {
  final _service = BimbelService();
  final _meetNumCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _driveCtrl = TextEditingController();
  final _zoomCtrl = TextEditingController();
  final _videoCtrl = TextEditingController();

  bool get _isZoomActive => _zoomCtrl.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Input Pertemuan Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildField('Pertemuan Ke-', 'Contoh: 1', _meetNumCtrl, icon: Icons.numbers),
          _buildField('Judul Materi', 'Contoh: Pembahasan Al-Fatihah', _titleCtrl, icon: Icons.title),
          _buildField('Link Google Drive', 'Upload materi berupa link', _driveCtrl, icon: Icons.cloud_circle),
          _buildField(
            'Link Zoom / Meet', 
            'Pertemuan Virtual', 
            _zoomCtrl, 
            icon: Icons.video_call,
            onChanged: (_) => setState(() {}),
            suffix: _isZoomActive ? const Icon(Icons.check_circle, color: Colors.green) : null,
          ),
          _buildField('Link Video YouTube', 'Materi Video', _videoCtrl, icon: Icons.play_circle_fill),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Simpan Pertemuan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController ctrl, {IconData? icon, Widget? suffix, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_meetNumCtrl.text.isEmpty || _titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nomor pertemuan dan judul wajib diisi')));
      return;
    }
    await safeCall(
      context: context,
      successMessage: 'Pertemuan berhasil ditambahkan!',
      action: () async {
        await _service.saveMeeting(
          programId: widget.programId,
          meetingNumber: _meetNumCtrl.text,
          title: _titleCtrl.text,
          driveUrl: _driveCtrl.text,
          zoomUrl: _zoomCtrl.text,
          videoUrl: _videoCtrl.text,
        );
        _meetNumCtrl.clear(); _titleCtrl.clear(); _driveCtrl.clear(); _zoomCtrl.clear(); _videoCtrl.clear();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 2. TAMBAH SOAL CBT
// ─────────────────────────────────────────────────────────────
class _TambahSoalCBT extends StatefulWidget {
  final String programId;
  const _TambahSoalCBT({required this.programId});

  @override
  State<_TambahSoalCBT> createState() => _TambahSoalCBTState();
}

class _TambahSoalCBTState extends State<_TambahSoalCBT> with SafeAsync {
  final _service = BimbelService();
  String _type = 'pg'; // pg, essai, listening
  String _format = 'A-D'; // A-D, A-E, A-F
  final _questionCtrl = TextEditingController();
  final _audioCtrl = TextEditingController();
  final _timeLimitCtrl = TextEditingController(text: '60');
  
  Map<String, TextEditingController> _optionCtrls = {};
  String _correctAnswer = 'A';

  @override
  void initState() {
    super.initState();
    _initOptions();
  }

  void _initOptions() {
    _optionCtrls.forEach((k, v) => v.dispose());
    _optionCtrls = {};
    int count = _format == 'A-D' ? 4 : (_format == 'A-E' ? 5 : 6);
    for (int i = 0; i < count; i++) {
      String letter = String.fromCharCode(65 + i);
      _optionCtrls[letter] = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Buat Soal CBT Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // Type Selector
          Row(
            children: [
              _typeBtn('PG', 'pg'),
              const SizedBox(width: 8),
              _typeBtn('Essai', 'essai'),
              const SizedBox(width: 8),
              _typeBtn('Listening', 'listening'),
            ],
          ),
          const SizedBox(height: 24),

          if (_type != 'essai') ...[
             const Text('Format Opsi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
             DropdownButtonFormField<String>(
               value: _format,
               items: ['A-D', 'A-E', 'A-F'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
               onChanged: (v) {
                 if (v != null) {
                   setState(() { _format = v; _initOptions(); });
                 }
               },
               decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
             ),
             const SizedBox(height: 16),
          ],

          if (_type == 'listening') ...[
            _buildField('Link YouTube (Audio)', 'Link video untuk materi listening', _audioCtrl, icon: Icons.audiotrack),
            const SizedBox(height: 16),
          ],

          _buildField('Pertanyaan / Soal', 'Masukkan teks soal di sini', _questionCtrl, icon: Icons.help_outline, maxLines: 3),
          
          if (_type != 'essai') ...[
            const Text('Pilihan Jawaban:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._optionCtrls.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Radio<String>(
                    value: e.key,
                    groupValue: _correctAnswer,
                    onChanged: (v) => setState(() => _correctAnswer = v!),
                  ),
                  Expanded(
                    child: TextField(
                      controller: e.value,
                      decoration: InputDecoration(
                        labelText: 'Opsi ${e.key}',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],

          const SizedBox(height: 16),
          _buildField('Batas Waktu (Detik)', 'Contoh: 60', _timeLimitCtrl, icon: Icons.timer, keyboardType: TextInputType.number),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Simpan Soal', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeBtn(String label, String t) {
    bool isSelected = _type == t;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() { _type = t; _initOptions(); }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade700 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade700),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.orange.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController ctrl, {IconData? icon, int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_questionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soal wajib diisi')));
      return;
    }
    
    Map<String, String> options = {};
    _optionCtrls.forEach((k, v) => options[k] = v.text);

    await safeCall(
      context: context,
      successMessage: 'Soal berhasil disimpan!',
      action: () async {
        await _service.saveQuestion(
          programId: widget.programId,
          type: _type,
          questionText: _questionCtrl.text,
          optionsFormat: _type != 'essai' ? _format : null,
          optionsJson: _type != 'essai' ? jsonEncode(options) : null,
          correctAnswer: _type != 'essai' ? _correctAnswer : null,
          audioUrl: _type == 'listening' ? _audioCtrl.text : null,
          timeLimit: int.tryParse(_timeLimitCtrl.text) ?? 60,
        );
        _questionCtrl.clear();
        for (var c in _optionCtrls.values) { c.clear(); }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 3. HASIL BELAJAR VIEW
// ─────────────────────────────────────────────────────────────
class _HasilBelajarView extends StatefulWidget {
  final String programId;
  const _HasilBelajarView({required this.programId});

  @override
  State<_HasilBelajarView> createState() => _HasilBelajarViewState();
}

class _HasilBelajarViewState extends State<_HasilBelajarView> with SafeAsync {
  final _service = BimbelService();
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await safeCall(
      context: context,
      action: () async {
        final res = await _service.fetchProgramPerformance(widget.programId);
        setState(() => _data = res);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _data.isEmpty 
      ? const Center(child: Text('Belum ada data hasil belajar'))
      : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _data.length,
          itemBuilder: (context, index) {
            final item = _data[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
                title: Text(item['topic'] ?? 'Sesi ${index+1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Kehadiran: ${item['attendance_count']} • Rata-rata: ${item['avg_score']?.toStringAsFixed(1) ?? "0"}'),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
  }
}

// ─────────────────────────────────────────────────────────────
// 4. DAFTAR PERTEMUAN LIST
// ─────────────────────────────────────────────────────────────
class _DaftarPertemuanList extends StatefulWidget {
  final String programId;
  const _DaftarPertemuanList({required this.programId});

  @override
  State<_DaftarPertemuanList> createState() => _DaftarPertemuanListState();
}

class _DaftarPertemuanListState extends State<_DaftarPertemuanList> with SafeAsync {
  final _service = BimbelService();
  List<Map<String, dynamic>> _meetings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await safeCall(
      context: context,
      action: () async {
        final res = await _service.fetchMeetings(widget.programId);
        setState(() => _meetings = res);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _meetings.isEmpty
      ? const Center(child: Text('Belum ada daftar pertemuan'))
      : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _meetings.length,
          itemBuilder: (context, index) {
            final m = _meetings[index];
            bool hasZoom = m['zoom_url'] != null && m['zoom_url'].toString().isNotEmpty;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text(m['meeting_number'] ?? '?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple.shade700)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pertemuan ${m['meeting_number']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        Text(m['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (m['drive_url']?.isNotEmpty == true) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.cloud_done, size: 14, color: Colors.blue)),
                            if (m['video_url']?.isNotEmpty == true) const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.play_circle, size: 14, color: Colors.red)),
                            if (hasZoom) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                              child: const Text('ZOOM AKTIF', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            );
          },
        );
  }
}
