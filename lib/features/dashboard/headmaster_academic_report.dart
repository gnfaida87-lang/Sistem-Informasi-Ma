import 'package:flutter/material.dart';
import '../../core/network/supabase_service.dart';

class HeadmasterAcademicReport extends StatefulWidget {
  const HeadmasterAcademicReport({super.key});

  @override
  State<HeadmasterAcademicReport> createState() => _HeadmasterAcademicReportState();
}

class _HeadmasterAcademicReportState extends State<HeadmasterAcademicReport> {
  List<Map<String, dynamic>> _classStats = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAcademicStats();
  }

  Future<void> _fetchAcademicStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetching classes joined with gurus (wali kelas)
      // Note: This relies on 'kelas' and 'guru' tables
      final response = await SupabaseService().client
          .from('kelas')
          .select('*, guru(nama)');
      
      final List<dynamic> data = response;
      setState(() {
        _classStats = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data akademik. Pastikan tabel 'kelas' sudah disetup.";
        _isLoading = false;
      });
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
              const Text(
                'Laporan Akademik Terpadu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _fetchAcademicStats,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // TABEL REKAP KELAS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rekapitulasi Kinerja per Kelas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3674))),
                const SizedBox(height: 16),
                _isLoading 
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ))
                  : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _classStats.isEmpty
                      ? const Center(child: Text('Belum ada data rombel tersedia.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                            columns: const [
                              DataColumn(label: Text('Nama Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Wali Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Jumlah Siswa', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Rata-rata Nilai', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Ketuntasan', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _classStats.map((item) {
                              final teacherName = (item['guru'] != null && item['guru']['nama'] != null)
                                  ? item['guru']['nama'].toString()
                                  : 'Belum diisi';
                              return _buildDataRow(
                                item['nama']?.toString() ?? '-',
                                teacherName,
                                '0', // Placeholder
                                '0.0', // Placeholder
                                '0%', // Placeholder
                              );
                            }).toList(),
                          ),
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String kelas, String wali, String jumlah, String nilai, String lulus) {
    return DataRow(
      cells: [
        DataCell(Text(kelas, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(wali)),
        DataCell(Text(jumlah)),
        DataCell(Text(nilai, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
        DataCell(Text(lulus, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold))),
        DataCell(
          TextButton(
            onPressed: null,
            child: const Text('Lihat Detail Rapor'),
          ),
        ),
      ],
    );
  }
}
