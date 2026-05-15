import 'package:flutter/material.dart';
import 'services/bimbel_service.dart';
import '../../core/mixins/safe_async_mixin.dart';

// ==========================================
// 1. SCREEN ABSENSI BIMBEL
// ==========================================
class BimbelAbsensiScreen extends StatefulWidget {
  final bool isRiwayat;
  final String sessionId;
  final String programId;

  const BimbelAbsensiScreen({
    super.key, 
    this.isRiwayat = false, 
    required this.sessionId,
    required this.programId,
  });

  @override
  State<BimbelAbsensiScreen> createState() => _BimbelAbsensiScreenState();
}

class _BimbelAbsensiScreenState extends State<BimbelAbsensiScreen> with SafeAsync {
  final _bimbelService = BimbelService();
  List<Map<String, dynamic>> _participants = [];
  final Map<String, String> _attendanceStatus = {}; // studentId -> status (H, S, I, A)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _bimbelService.fetchParticipantsByProgram(widget.programId);
        setState(() => _participants = data);

        // Jika riwayat, ambil data yang sudah ada
        if (widget.isRiwayat) {
          final progress = await _bimbelService.fetchSessionProgress(widget.sessionId);
          for (var p in progress) {
            final status = p['is_present'] == true ? 'H' : (p['notes'] ?? 'A');
            _attendanceStatus[p['student_id']] = status;
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRiwayat ? 'Riwayat Absensi' : 'Input Absensi', style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _participants.isEmpty
              ? const Center(child: Text('Tidak ada peserta terdaftar'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _participants.length,
                  itemBuilder: (context, index) {
                    final student = _participants[index]['siswa'];
                    final studentId = student['id'];
                    final currentStatus = _attendanceStatus[studentId] ?? 'H';

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.deepPurple.shade50,
                              child: Text(student['nama'][0], style: TextStyle(color: Colors.deepPurple.shade700)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('NIS: ${student['nis']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                            if (!widget.isRiwayat)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStatusBtn('H', Colors.green, studentId),
                                  const SizedBox(width: 4),
                                  _buildStatusBtn('S', Colors.orange, studentId),
                                  const SizedBox(width: 4),
                                  _buildStatusBtn('I', Colors.blue, studentId),
                                  const SizedBox(width: 4),
                                  _buildStatusBtn('A', Colors.red, studentId),
                                ],
                              )
                            else
                              _buildStatusBadge(currentStatus),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: (!widget.isRiwayat && !isLoading && _participants.isNotEmpty) 
        ? FloatingActionButton.extended(
            onPressed: _saveAttendance,
            backgroundColor: Colors.deepPurple.shade700,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Simpan Absensi', style: TextStyle(color: Colors.white)),
          ) 
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatusBtn(String label, MaterialColor color, String studentId) {
    bool isSelected = (_attendanceStatus[studentId] ?? 'H') == label;
    return InkWell(
      onTap: () => setState(() => _attendanceStatus[studentId] = label),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.shade700 : color.shade50,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? color.shade700 : color.shade200),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : color.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
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
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Future<void> _saveAttendance() async {
    await safeCall(
      context: context,
      successMessage: 'Absensi berhasil disimpan!',
      action: () async {
        for (var p in _participants) {
          final studentId = p['siswa']['id'];
          final status = _attendanceStatus[studentId] ?? 'H';
          await _bimbelService.saveBimbelProgress(
            sessionId: widget.sessionId,
            studentId: studentId,
            isPresent: status == 'H',
            score: 0, // Skor default untuk absensi
            notes: status != 'H' ? status : null,
          );
        }
        if (mounted) Navigator.pop(context);
      },
    );
  }
}

// ==========================================
// 2. SCREEN NILAI BIMBEL
// ==========================================
class BimbelNilaiScreen extends StatefulWidget {
  final bool isRekap;
  final String sessionId;
  final String programId;

  const BimbelNilaiScreen({
    super.key, 
    this.isRekap = false,
    required this.sessionId,
    required this.programId,
  });

  @override
  State<BimbelNilaiScreen> createState() => _BimbelNilaiScreenState();
}

class _BimbelNilaiScreenState extends State<BimbelNilaiScreen> with SafeAsync {
  final _bimbelService = BimbelService();
  List<Map<String, dynamic>> _participants = [];
  final Map<String, TextEditingController> _scoreControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _bimbelService.fetchParticipantsByProgram(widget.programId);
        setState(() => _participants = data);

        final progress = await _bimbelService.fetchSessionProgress(widget.sessionId);
        for (var p in progress) {
          final studentId = p['student_id'];
          _scoreControllers[studentId] = TextEditingController(text: p['score'].toString());
        }

        // Inisialisasi controller yang belum ada
        for (var p in _participants) {
          final id = p['siswa']['id'];
          if (!_scoreControllers.containsKey(id)) {
            _scoreControllers[id] = TextEditingController(text: '0');
          }
        }
      },
    );
  }

  @override
  void dispose() {
    for (var ctrl in _scoreControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRekap ? 'Rekap Nilai' : 'Input Nilai Latihan', style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final student = _participants[index]['siswa'];
                final studentId = student['id'];

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade50,
                      child: Icon(Icons.score, color: Colors.orange.shade700),
                    ),
                    title: Text(student['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('NIS: ${student['nis']}', style: const TextStyle(fontSize: 11)),
                    trailing: widget.isRekap 
                      ? Text(_scoreControllers[studentId]?.text ?? '0', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple))
                      : SizedBox(
                          width: 60,
                          child: TextField(
                            controller: _scoreControllers[studentId],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                  ),
                );
              },
            ),
      floatingActionButton: (!widget.isRekap && !isLoading && _participants.isNotEmpty)
        ? FloatingActionButton.extended(
            onPressed: _saveScores,
            backgroundColor: Colors.deepPurple.shade700,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Simpan Nilai', style: TextStyle(color: Colors.white)),
          ) 
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _saveScores() async {
    await safeCall(
      context: context,
      successMessage: 'Nilai berhasil disimpan!',
      action: () async {
        for (var p in _participants) {
          final studentId = p['siswa']['id'];
          final scoreStr = _scoreControllers[studentId]?.text ?? '0';
          final score = double.tryParse(scoreStr) ?? 0;

          await _bimbelService.saveBimbelProgress(
            sessionId: widget.sessionId,
            studentId: studentId,
            isPresent: true, // Default true jika input nilai
            score: score,
          );
        }
        if (mounted) Navigator.pop(context);
      },
    );
  }
}

