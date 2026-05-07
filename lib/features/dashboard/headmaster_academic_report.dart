import 'package:flutter/material.dart';
import '../../core/network/d1_service.dart';

class HeadmasterAcademicReport extends StatefulWidget {
  const HeadmasterAcademicReport({super.key});

  @override
  State<HeadmasterAcademicReport> createState() => _HeadmasterAcademicReportState();
}

class _HeadmasterAcademicReportState extends State<HeadmasterAcademicReport> {
  final _d1Service = D1Service();
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
      final data = await _d1Service.query(
        """
        SELECT k.*, g.nama as guru_nama 
        FROM kelas k
        LEFT JOIN guru g ON k.wali_id = g.id
        ORDER BY k.nama ASC
        """
      );
      
      setState(() {
        _classStats = List<Map<String, dynamic>>.from(data as List);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data akademik dari D1.";
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
          const Text(
            'Laporan Akademik',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
          ),
          const SizedBox(height: 24),
          _buildClassTable(),
        ],
      ),
    );
  }

  Widget _buildClassTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rekapitulasi per Kelas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(child: Text(_errorMessage!))
          else if (_classStats.isEmpty)
            const Center(child: Text('Belum ada data kelas.'))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nama Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Wali Kelas', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _classStats.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['nama'] ?? '-')),
                      DataCell(Text(item['guru_nama'] ?? 'Belum ditentukan')),
                      DataCell(TextButton(onPressed: () {}, child: const Text('Detail'))),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
