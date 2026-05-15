import 'package:flutter/material.dart';
import '../../core/constants/app_settings.dart';
import '../../core/network/d1_service.dart';
import '../../core/providers/academic_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WakakurRapor extends ConsumerStatefulWidget {
  const WakakurRapor({super.key});

  @override
  ConsumerState<WakakurRapor> createState() => _WakakurRaporState();
}

class _WakakurRaporState extends ConsumerState<WakakurRapor> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _d1Service = D1Service();
  
  String? _selectedLegerClassId;
  List<Map<String, dynamic>> _availableClasses = [];
  List<String> _legerSubjects = [];
  List<Map<String, dynamic>> _legerData = [];
  bool _isLegerLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAvailableClasses();
  }

  Future<void> _loadAvailableClasses() async {
    try {
      final results = await _d1Service.query("SELECT id, nama FROM classes ORDER BY nama ASC");
      setState(() {
        _availableClasses = results.cast<Map<String, dynamic>>();
        if (_availableClasses.isNotEmpty) {
          _selectedLegerClassId = _availableClasses.first['id'];
          _fetchLegerData();
        }
      });
    } catch (e) {
      debugPrint("Error loading classes: $e");
    }
  }

  Future<void> _fetchLegerData() async {
    if (_selectedLegerClassId == null) return;
    setState(() => _isLegerLoading = true);
    
    try {
      // 1. Ambil Mapel yang diajarkan di kelas ini
      final subjectResults = await _d1Service.query(
        "SELECT DISTINCT s.nama FROM teaching_schedules ts JOIN subjects s ON ts.subject_id = s.id WHERE ts.class_id = ?",
        params: [_selectedLegerClassId]
      );
      final subjects = subjectResults.map((e) => e['nama'].toString()).toList();

      // 2. Ambil Siswa dan Nilai Rata-rata per Mapel
      // Logika: Ambil rata-rata nilai UH, PTS, PAS untuk setiap mapel
      final legerSql = """
        SELECT 
          st.nama as nama_siswa,
          sub.nama as nama_mapel,
          AVG(sg.nilai) as nilai_rata
        FROM students st
        JOIN teaching_schedules ts ON ts.class_id = st.kelas_id
        JOIN subjects sub ON ts.subject_id = sub.id
        LEFT JOIN student_grades sg ON sg.student_id = st.id AND sg.subject_id = sub.id
        WHERE st.kelas_id = ?
        GROUP BY st.id, sub.id
        ORDER BY st.nama ASC
      """;
      
      final results = await _d1Service.query(legerSql, params: [_selectedLegerClassId]);
      
      // Transform data ke format Leger (Satu baris per siswa)
      final Map<String, Map<String, dynamic>> pivotData = {};
      for (var row in results) {
        final studentName = row['nama_siswa'];
        if (!pivotData.containsKey(studentName)) {
          pivotData[studentName] = {'nama': studentName};
        }
        pivotData[studentName]![row['nama_mapel']] = (row['nilai_rata'] ?? 0.0);
      }

      setState(() {
        _legerSubjects = subjects;
        _legerData = pivotData.values.toList();
        _isLegerLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching leger: $e");
      setState(() => _isLegerLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER & TABBAR
        Container(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manajemen E-rapot',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.teal.shade700,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.teal.shade700,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Generate Rapor'),
                        Tab(text: 'Validasi Rapor'),
                        Tab(text: 'Leger Nilai'),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _syncData(),
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Sinkronkan Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal.shade700,
                      side: BorderSide(color: Colors.teal.shade200),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGenerateTab(),
              _buildValidasiTab(),
              _buildLegerTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: GENERATE RAPOR
  // ==========================================
  Widget _buildGenerateTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pastikan seluruh nilai harian, PTS, dan PAS sudah ter-input 100% pada Monitoring sebelum melakukan Generate.',
                  style: TextStyle(fontSize: 13, color: Colors.brown),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Text('Belum ada kelas yang siap generate rapor.', style: TextStyle(color: Colors.grey))),
        ),
      ],
    );
  }

  Widget _buildClassGenerateCard(String className, int totalSiswa, int progress, bool isReady) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isReady ? Colors.teal.shade50 : Colors.grey.shade100,
            child: Icon(Icons.class_outlined, color: isReady ? Colors.teal : Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kelas $className', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$totalSiswa Siswa • Ketuntasan Nilai: $progress%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: isReady ? () => _generateRapor(className) : null,
            icon: const Icon(Icons.auto_fix_high, size: 16),
            label: const Text('Generate Rapor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  void _generateRapor(String className) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Generating Rapor for $className...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil Generate Rapor untuk Kelas $className'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _syncData() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync, size: 50, color: Colors.teal),
            const SizedBox(height: 20),
            const Text('Mensinkronkan data dengan Guru & Wali Kelas...'),
            const SizedBox(height: 10),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sinkronisasi Data Berhasil! Sesuai Dokumen SINKRONISASI DATA & ROLE.'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  // ==========================================
  // TAB 2: VALIDASI RAPOR
  // ==========================================
  Widget _buildValidasiTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Text('Menunggu Tanda Tangan Digital:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                child: const Text('Validasi Semua yang Siap'),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Center(child: Text('Tidak ada rapor yang menunggu validasi.', style: TextStyle(color: Colors.grey))),
        ),
      ],
    );
  }

  void _showPreviewRapor(String name) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(40),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('LAPORAN HASIL BELAJAR (RAPOR)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                const Divider(height: 40),
                _raporInfoRow('Nama Peserta Didik', name),
                _raporInfoRow('NISN', '10103982'),
                _raporInfoRow('Sekolah', 'Madrasah Aliyah Negeri 1'),
                _raporInfoRow('Kelas', 'X IPA 1'),
                const SizedBox(height: 32),
                const Text('A. Nilai Akademik', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F5)),
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('Mata Pelajaran', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Nilai Akhir', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Capaian Kompetensi', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    _raporDataRow('Matematika', '92', 'Menunjukkan penguasaan yang sangat baik dalam memahami konsep kalkulus dasar.'),
                    _raporDataRow('B. Indonesia', '88', 'Menunjukkan penguasaan yang baik dalam menyusun teks laporan hasil observasi.'),
                  ],
                ),
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    children: [
                      const Text('Kepala Madrasah,'),
                      const SizedBox(height: 60),
                      Text(appConfig.headmasterName, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(onPressed: null, icon: const Icon(Icons.print), label: const Text('Cetak')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _raporInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label)),
          const Text(': '),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  TableRow _raporDataRow(String mapel, String nilai, String desc) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(mapel)),
        Padding(padding: const EdgeInsets.all(8), child: Text(nilai, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.all(8), child: Text(desc, style: const TextStyle(fontSize: 11))),
      ],
    );
  }

  // ==========================================
  // TAB 3: LEGER NILAI
  // ==========================================
  Widget _buildLegerTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLegerClassId,
                    items: _availableClasses.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text('Kelas: ${e['nama']}'))).toList(),
                    onChanged: (val) {
                      setState(() => _selectedLegerClassId = val);
                      _fetchLegerData();
                    },
                    style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (_isLegerLoading) const CircularProgressIndicator(strokeWidth: 2),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _legerData.isEmpty ? null : () {}, // Implement Excel Export later
                icon: const Icon(Icons.download),
                label: const Text('Export Excel'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _legerData.isEmpty && !_isLegerLoading
            ? const Center(child: Text('Tidak ada data nilai untuk kelas ini.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                    border: TableBorder.all(color: Colors.grey.shade200),
                    columns: [
                      const DataColumn(label: Text('No', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataColumn(label: Text('Nama Siswa', style: TextStyle(fontWeight: FontWeight.bold))),
                      ..._legerSubjects.map((s) => DataColumn(label: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)))),
                      const DataColumn(label: Text('RATA2', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List.generate(_legerData.length, (index) {
                      final student = _legerData[index];
                      double total = 0;
                      int count = 0;
                      
                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(student['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                          ..._legerSubjects.map((s) {
                            final score = (student[s] ?? 0.0) as double;
                            if (score > 0) {
                              total += score;
                              count++;
                            }
                            return DataCell(Text(score > 0 ? score.toStringAsFixed(1) : '-'));
                          }),
                          DataCell(Text(count > 0 ? (total / count).toStringAsFixed(1) : '0.0', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                        ],
                      );
                    }),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}
