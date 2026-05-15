import 'package:flutter/material.dart';
import '../services/bimbel_service.dart';

class BimbelAbsensiScreen extends StatefulWidget {
  final bool isRiwayat;
  final String sessionId;
  final String programId;

  const BimbelAbsensiScreen({
    super.key,
    required this.isRiwayat,
    required this.sessionId,
    required this.programId,
  });

  @override
  State<BimbelAbsensiScreen> createState() => _BimbelAbsensiScreenState();
}

class _BimbelAbsensiScreenState extends State<BimbelAbsensiScreen> {
  final _service = BimbelService();
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _progress = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Map studentId → hadir (true/false)
  final Map<String, bool> _attendance = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final participants = await _service.fetchParticipantsByProgram(widget.programId);
      final progress   = await _service.fetchSessionProgress(widget.sessionId);

      // Inisialisasi attendance dari data yang sudah ada
      final Map<String, bool> att = {};
      for (final p in participants) {
        final existing = progress.firstWhere(
          (pr) => pr['student_id'] == p['student_id'],
          orElse: () => {},
        );
        att[p['student_id']] = existing.isNotEmpty
            ? (existing['is_present'] == 1 || existing['is_present'] == true)
            : true; // default hadir
      }

      setState(() {
        _participants = participants;
        _progress     = progress;
        _attendance.addAll(att);
        _isLoading    = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Gagal memuat data: $e');
    }
  }

  Future<void> _saveAbsensi() async {
    setState(() => _isSaving = true);
    try {
      for (final p in _participants) {
        final sid = p['student_id'] as String;
        await _service.saveBimbelProgress(
          sessionId: widget.sessionId,
          studentId: sid,
          isPresent: _attendance[sid] ?? true,
          score: 0,
        );
      }
      _showSnack('Absensi berhasil disimpan!', success: true);
    } catch (e) {
      _showSnack('Gagal menyimpan: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isRiwayat ? 'Riwayat Absensi' : 'Input Absensi';
    final hadir  = _attendance.values.where((v) => v).length;
    final absen  = _attendance.values.where((v) => !v).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!widget.isRiwayat)
            TextButton(
              onPressed: _isSaving ? null : _saveAbsensi,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : Column(
              children: [
                // Summary bar
                Container(
                  color: Colors.deepPurple.shade700,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      _summaryChip('Hadir', hadir, Colors.green.shade300),
                      const SizedBox(width: 12),
                      _summaryChip('Tidak Hadir', absen, Colors.red.shade300),
                      const Spacer(),
                      Text('${_participants.length} Peserta',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),

                if (_participants.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tidak ada peserta terdaftar', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _participants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p  = _participants[index];
                        final sid = p['student_id'] as String;
                        final isHadir = _attendance[sid] ?? true;

                        // Riwayat: tampilkan status dari progress
                        if (widget.isRiwayat) {
                          final prog = _progress.firstWhere(
                            (pr) => pr['student_id'] == sid,
                            orElse: () => {},
                          );
                          final present = prog.isNotEmpty &&
                              (prog['is_present'] == 1 || prog['is_present'] == true);
                          return _buildRiwayatTile(p, present, prog['notes'] ?? '');
                        }

                        return _buildAbsensiTile(p, sid, isHadir);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildAbsensiTile(Map<String, dynamic> p, String sid, bool isHadir) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHadir ? Colors.green.shade200 : Colors.red.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isHadir ? Colors.green.shade50 : Colors.red.shade50,
            child: Text(
              (p['student_name'] as String? ?? 'S')[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHadir ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['student_name'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('NIS: ${p['nis'] ?? '-'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          // Toggle hadir/tidak hadir
          Row(
            children: [
              _attendanceButton('Hadir', true, sid, isHadir),
              const SizedBox(width: 8),
              _attendanceButton('Absen', false, sid, isHadir),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceButton(String label, bool value, String sid, bool currentValue) {
    final isSelected = value == currentValue;
    final color = value ? Colors.green : Colors.red;
    return GestureDetector(
      onTap: () => setState(() => _attendance[sid] = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildRiwayatTile(Map<String, dynamic> p, bool present, String notes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: present ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(
              present ? Icons.check : Icons.close,
              color: present ? Colors.green.shade700 : Colors.red.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['student_name'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('NIS: ${p['nis'] ?? '-'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                if (notes.isNotEmpty)
                  Text('Ket: $notes',
                      style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: present ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              present ? 'Hadir' : 'Tidak Hadir',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: present ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
