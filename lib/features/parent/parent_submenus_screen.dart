import 'package:flutter/material.dart';
import 'services/parent_service.dart';
import '../../core/mixins/safe_async_mixin.dart';

// ==========================================
// 1. KELOMPOK AKADEMIK
// ==========================================

class ParentAkademikNilaiScreen extends StatefulWidget {
  final String studentId;
  const ParentAkademikNilaiScreen({super.key, required this.studentId});

  @override
  State<ParentAkademikNilaiScreen> createState() => _ParentAkademikNilaiScreenState();
}

class _ParentAkademikNilaiScreenState extends State<ParentAkademikNilaiScreen> with SafeAsync {
  final _parentService = ParentService();
  List<Map<String, dynamic>> _grades = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _parentService.getStudentGrades(widget.studentId);
        setState(() => _grades = data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nilai Tugas & Ujian', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _grades.isEmpty
              ? const Center(child: Text('Belum ada data nilai.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _grades.length,
                  itemBuilder: (context, index) {
                    final grade = _grades[index];
                    final mapel = grade['mapel']?['nama'] ?? 'Mata Pelajaran';
                    final score = grade['skor'].toString();
                    final category = grade['kategori'] ?? 'Tugas';
                    
                    return _buildNilaiCard(mapel, category, score, Colors.blue);
                  },
                ),
    );
  }

  Widget _buildNilaiCard(String mapel, String jenis, String nilai, MaterialColor color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.shade50, child: Icon(Icons.assignment, color: color.shade700)),
        title: Text(mapel, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(jenis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Text(nilai, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.shade700)),
      ),
    );
  }
}

// ==========================================
// 2. KELOMPOK BIMBEL
// ==========================================

class ParentBimbelProgramScreen extends StatefulWidget {
  final String studentId;
  const ParentBimbelProgramScreen({super.key, required this.studentId});

  @override
  State<ParentBimbelProgramScreen> createState() => _ParentBimbelProgramScreenState();
}

class _ParentBimbelProgramScreenState extends State<ParentBimbelProgramScreen> with SafeAsync {
  final _parentService = ParentService();
  List<Map<String, dynamic>> _programs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await safeCall(
      context: context,
      action: () async {
        final data = await _parentService.getStudentBimbelPrograms(widget.studentId);
        setState(() => _programs = data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bimbingan Belajar Terdaftar', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _programs.isEmpty
              ? const Center(child: Text('Anak Anda belum terdaftar di program bimbel.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _programs.length,
                  itemBuilder: (context, index) {
                    final prog = _programs[index]['program_bimbel'];
                    final tutor = prog['guru']?['nama'] ?? 'Tutor Eksternal';
                    
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade200)),
                      child: ListTile(
                        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.star, color: Colors.teal.shade700)),
                        title: Text(prog['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Tutor: $tutor\nStatus: Aktif'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}

// SCREEN LAIN TETAP PLACEHOLDER (AKAN DISESUAIKAN JIKA DIBUTUHKAN)
class ParentAkademikRaporScreen extends StatelessWidget {
  const ParentAkademikRaporScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('E-rapot Digital')), body: const Center(child: Text('Data rapor sedang diproses.')));
}

class ParentAkademikAbsensiScreen extends StatelessWidget {
  const ParentAkademikAbsensiScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Rekap Kehadiran')), body: const Center(child: Text('Fitur sedang dikembangkan.')));
}
