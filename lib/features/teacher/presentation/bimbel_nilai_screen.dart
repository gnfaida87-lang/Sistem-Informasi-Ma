import 'package:flutter/material.dart';
import '../services/bimbel_service.dart';

class BimbelNilaiScreen extends StatefulWidget {
  final bool isRekap;
  final String sessionId;
  final String programId;

  const BimbelNilaiScreen({
    super.key,
    required this.isRekap,
    required this.sessionId,
    required this.programId,
  });

  @override
  State<BimbelNilaiScreen> createState() => _BimbelNilaiScreenState();
}

class _BimbelNilaiScreenState extends State<BimbelNilaiScreen> {
  final _service = BimbelService();
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _progress     = [];
  bool _isLoading = true;
  bool _isSaving  = false;

  // Map studentId → TextEditingController nilai
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    for (final c in _noteControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final participants = await _service.fetchParticipantsByProgram(widget.programId);
      final progress     = await _service.fetchSessionProgress(widget.sessionId);

      for (final p in participants) {
        final sid = p['student_id'] as String;
        final existing = progress.firstWhere(
          (pr) => pr['student_id'] == sid,
          orElse: () => {},
        );
        _controllers[sid]     = TextEditingController(
            text: existing.isNotEmpty ? '${existing['score'] ?? 0}' : '');
        _noteControllers[sid] = TextEditingController(
            text: existing.isNotEmpty ? (existing['notes'] ?? '') : '');
      }

      setState(() {
        _participants = participants;
        _progress     = progress;
        _isLoading    = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Gagal memuat data: $e');
    }
  }

  Future<void> _saveNilai() async {
    setState(() => _isSaving = true);
    try {
      for (final p in _participants) {
        final sid   = p['student_id'] as String;
        final score = double.tryParse(_controllers[sid]?.text ?? '0') ?? 0;
        final notes = _noteControllers[sid]?.text ?? '';

        await _service.saveBimbelProgress(
          sessionId: widget.sessionId,
          studentId: sid,
          isPresent: true,
          score: score,
          notes: notes,
        );
      }
      _showSnack('Nilai berhasil disimpan!', success: true);
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

  Color _scoreColor(double score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 65) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isRekap ? 'Rekap Nilai Siswa' : 'Input Nilai Latihan';

    // Hitung rata-rata untuk rekap
    double avg = 0;
    if (_progress.isNotEmpty) {
      final scores = _progress.map((p) => (p['score'] as num?)?.toDouble() ?? 0).toList();
      avg = scores.reduce((a, b) => a + b) / scores.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!widget.isRekap)
            TextButton(
              onPressed: _isSaving ? null : _saveNilai,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Column(
              children: [
                // Rekap: tampilkan rata-rata
                if (widget.isRekap && _progress.isNotEmpty)
                  Container(
                    color: Colors.orange.shade700,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        _statCard('Rata-rata', avg.toStringAsFixed(1), Colors.white),
                        const SizedBox(width: 12),
                        _statCard('Tertinggi',
                            _progress.map((p) => (p['score'] as num?)?.toDouble() ?? 0)
                                .reduce((a, b) => a > b ? a : b).toStringAsFixed(0),
                            Colors.green.shade200),
                        const SizedBox(width: 12),
                        _statCard('Terendah',
                            _progress.map((p) => (p['score'] as num?)?.toDouble() ?? 0)
                                .reduce((a, b) => a < b ? a : b).toStringAsFixed(0),
                            Colors.red.shade200),
                      ],
                    ),
                  ),

                if (_participants.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Tidak ada peserta', style: TextStyle(color: Colors.grey)),
                      ]),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _participants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p   = _participants[index];
                        final sid = p['student_id'] as String;

                        if (widget.isRekap) {
                          final prog = _progress.firstWhere(
                              (pr) => pr['student_id'] == sid, orElse: () => {});
                          final score = prog.isNotEmpty
                              ? (prog['score'] as num?)?.toDouble() ?? 0
                              : 0.0;
                          return _buildRekapTile(p, score, prog['notes'] ?? '');
                        }
                        return _buildInputTile(p, sid);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildInputTile(Map<String, dynamic> p, String sid) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orange.shade50,
              child: Text(
                (p['student_name'] as String? ?? 'S')[0].toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['student_name'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('NIS: ${p['nis'] ?? '-'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            )),
            SizedBox(
              width: 70,
              child: TextField(
                controller: _controllers[sid],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Nilai',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.orange.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          TextField(
            controller: _noteControllers[sid],
            decoration: InputDecoration(
              hintText: 'Catatan (opsional)',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekapTile(Map<String, dynamic> p, double score, String notes) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _scoreColor(score).withOpacity(0.1),
          child: Text(
            score.toStringAsFixed(0),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _scoreColor(score)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p['student_name'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('NIS: ${p['nis'] ?? '-'}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          if (notes.isNotEmpty)
            Text('Ket: $notes', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
        ])),
        // Progress bar mini
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(score.toStringAsFixed(0),
              style: TextStyle(fontWeight: FontWeight.bold, color: _scoreColor(score), fontSize: 16)),
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey.shade200,
              color: _scoreColor(score),
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)),
        ]),
      ),
    );
  }
}
