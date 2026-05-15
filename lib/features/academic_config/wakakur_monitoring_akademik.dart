import 'package:flutter/material.dart';
import '../../../core/network/d1_service.dart';

class WakakurMonitoringAkademik extends StatefulWidget {
  const WakakurMonitoringAkademik({super.key});

  @override
  State<WakakurMonitoringAkademik> createState() => _WakakurMonitoringAkademikState();
}

class _WakakurMonitoringAkademikState extends State<WakakurMonitoringAkademik> {
  final _d1Service = D1Service();
  String _selectedSemester = 'Ganjil 2025/2026';
  bool _isLoading = true;

  List<Map<String, dynamic>> _gradeProgress = [];
  List<Map<String, dynamic>> _pendingTeachers = [];
  List<Map<String, dynamic>> _pendingAttendance = [];

  @override
  void initState() {
    super.initState();
    _fetchMonitoringData();
  }

  Future<void> _fetchMonitoringData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final progressSql = """
        SELECT 
          sub.nama as mapel, 
          cls.nama as kelas,
          COUNT(DISTINCT sg.student_id) as graded_count,
          (SELECT COUNT(*) FROM students st WHERE st.kelas_id = cls.id AND st.is_active = 1) as total_students,
          sg.type as tipe_nilai
        FROM teaching_schedules ts
        JOIN subjects sub ON ts.subject_id = sub.id
        JOIN classes cls ON ts.class_id = cls.id
        LEFT JOIN student_grades sg ON sg.subject_id = sub.id 
             AND sg.student_id IN (SELECT id FROM students WHERE kelas_id = cls.id)
        GROUP BY sub.id, cls.id, sg.type
        ORDER BY cls.nama, sub.nama
      """;
      final progress = await _d1Service.query(progressSql);

      final progressMap = <String, Map<String, dynamic>>{};
      for (var row in progress) {
        final key = "${row['mapel']}_${row['kelas']}";
        if (!progressMap.containsKey(key)) {
          progressMap[key] = {
            'mapel': row['mapel'],
            'kelas': row['kelas'],
            'total_students': row['total_students'],
            'uh': 0.0,
            'pts': 0.0,
            'pas': 0.0,
          };
        }
        final count = (row['graded_count'] as num).toDouble();
        final total = (row['total_students'] as num).toDouble();
        final pct = total > 0 ? (count / total * 100) : 0.0;
        
        final tipe = row['tipe_nilai']?.toString().toUpperCase() ?? '';
        if (tipe == 'UH') progressMap[key]!['uh'] = pct;
        else if (tipe == 'PTS') progressMap[key]!['pts'] = pct;
        else if (tipe == 'PAS') progressMap[key]!['pas'] = pct;
      }

      final pendingSql = """
        SELECT t.nama as guru, s.nama as mapel, c.nama as kelas
        FROM teaching_schedules ts
        JOIN teachers t ON ts.teacher_id = t.id
        JOIN subjects s ON ts.subject_id = s.id
        JOIN classes c ON ts.class_id = c.id
        WHERE NOT EXISTS (
          SELECT 1 FROM student_grades sg 
          WHERE sg.subject_id = s.id 
          AND sg.student_id IN (SELECT id FROM students WHERE kelas_id = c.id)
        )
      """;
      final pendingTeachers = await _d1Service.query(pendingSql);

      final today = DateTime.now().toIso8601String().split('T').first;
      final attendanceSql = """
        SELECT c.nama as kelas, t.nama as wali_kelas
        FROM classes c
        JOIN teachers t ON c.wali_kelas_id = t.id
        WHERE NOT EXISTS (
          SELECT 1 FROM attendance a 
          WHERE a.class_id = c.id AND a.date = ?
        )
      """;
      final pendingAttendance = await _d1Service.query(attendanceSql, params: [today]);

      if (mounted) {
        setState(() {
          _gradeProgress = progressMap.values.toList();
          _pendingTeachers = List<Map<String, dynamic>>.from(pendingTeachers);
          _pendingAttendance = List<Map<String, dynamic>>.from(pendingAttendance);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error monitoring: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring Akademik',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
                  ),
                  SizedBox(height: 8),
                  Text('Pantau kepatuhan input data guru & progres akademik secara real-time.', 
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
                child: Row(
                  children: [
                    const Icon(Icons.history_edu, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _selectedSemester,
                      underline: const SizedBox(),
                      items: ['Ganjil 2025/2026', 'Genap 2025/2026', 'Ganjil 2024/2025'].map((e) => 
                        DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) => setState(() => _selectedSemester = val!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(50.0),
              child: CircularProgressIndicator(),
            ))
          else ...[
            _buildSectionHeader('Progress Input Nilai & Ketuntasan per Kategori', Icons.analytics_outlined, Colors.blue),
            _buildProgressPenilaianTable(),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Guru Belum Input Nilai', Icons.pending_actions, Colors.red),
                      _buildGuruBelumInputTable(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Kelas Belum Absensi Hari Ini', Icons.event_busy, Colors.orange),
                      _buildKelasBelumAbsensiTable(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2559))),
        ],
      ),
    );
  }

  Widget _buildProgressPenilaianTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
          columns: const [
            DataColumn(label: Text('Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Absensi', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Sikap/Siswa', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('UH (Harian)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('PTS', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('PAS / UAS', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status Akhir', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _gradeProgress.map((p) {
            double avg = ((p['uh'] ?? 0) + (p['pts'] ?? 0) + (p['pas'] ?? 0)) / 3;
            Color color = avg > 80 ? Colors.green : (avg > 50 ? Colors.orange : Colors.red);
            return DataRow(cells: [
              DataCell(Text(p['mapel'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(p['kelas'] ?? '-')),
              const DataCell(Text('100%', style: TextStyle(color: Colors.green))),
              const DataCell(Text('Lengkap', style: TextStyle(color: Colors.blue))),
              DataCell(Text('${(p['uh'] ?? 0).toInt()}%')),
              DataCell(Text('${(p['pts'] ?? 0).toInt()}%')),
              DataCell(Text('${(p['pas'] ?? 0).toInt()}%')),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(avg > 50 ? 'Berjalan' : 'Kritis', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGuruBelumInputTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSimpleRow('Nama Guru', 'Mata Pelajaran', 'Ket.', isHeader: true),
          const Divider(),
          if (_pendingTeachers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Belum ada guru yang perlu dipantau.', style: TextStyle(fontSize: 12, color: Colors.grey))),
            )
          else
            ..._pendingTeachers.map((t) => _buildSimpleRow(t['guru'] ?? '-', t['mapel'] ?? '-', t['kelas'] ?? '-', color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildKelasBelumAbsensiTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSimpleRow('Kelas', 'Wali Kelas', 'Status', isHeader: true),
          const Divider(),
          if (_pendingAttendance.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Seluruh kelas sudah melakukan absensi.', style: TextStyle(fontSize: 12, color: Colors.grey))),
            )
          else
            ..._pendingAttendance.map((a) => _buildSimpleRow(a['kelas'] ?? '-', a['wali_kelas'] ?? '-', 'BELUM', color: Colors.orange)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.notifications_active_outlined, size: 16),
            label: const Text('Ingatkan Semua Wali Kelas', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSimpleRow(String col1, String col2, String col3, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(col1, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.w600, fontSize: 13))),
          Expanded(flex: 3, child: Text(col2, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
          Expanded(flex: 2, child: Text(col3, textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color ?? (isHeader ? Colors.black : Colors.grey.shade800)))),
        ],
      ),
    );
  }
}
