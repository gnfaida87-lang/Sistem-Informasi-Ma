import 'package:flutter/material.dart';
import '../../core/constants/app_settings.dart';

class WakakurRapor extends StatefulWidget {
  const WakakurRapor({super.key});

  @override
  State<WakakurRapor> createState() => _WakakurRaporState();
}

class _WakakurRaporState extends State<WakakurRapor> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        _buildClassGenerateCard('X IPA 1', 32, 100, true),
        _buildClassGenerateCard('X IPA 2', 30, 95, false),
        _buildClassGenerateCard('XI IPS 1', 35, 100, true),
        _buildClassGenerateCard('XII IPA 1', 28, 80, false),
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
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final names = ['Ahmad Rizal Fachry', 'Nadia Safira', 'Fauzan Adzima', 'Siti Aminah', 'Budi Santoso'];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Kelas X IPA 1 • Rapor Semester Ganjil'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(onPressed: () => _showPreviewRapor(names[index]), child: const Text('Preview')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: null, child: const Text('Sahkan')),
                  ],
                ),
              );
            },
          ),
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
              DropdownButton<String>(
                value: 'X IPA 1',
                items: ['X IPA 1', 'X IPA 2', 'XI IPA 1'].map((e) => DropdownMenuItem(value: e, child: Text('Pilih Kelas: $e'))).toList(),
                onChanged: (val) {},
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.download),
                label: const Text('Export Excel'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                border: TableBorder.all(color: Colors.grey.shade300),
                columns: const [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Nama Siswa')),
                  DataColumn(label: Text('MTK')),
                  DataColumn(label: Text('BIN')),
                  DataColumn(label: Text('BIG')),
                  DataColumn(label: Text('FIS')),
                  DataColumn(label: Text('KIM')),
                  DataColumn(label: Text('BIO')),
                  DataColumn(label: Text('RATA2')),
                  DataColumn(label: Text('Ranking')),
                ],
                rows: List.generate(10, (index) => DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text('Siswa Ke-${index + 1}')),
                    const DataCell(Text('85')),
                    const DataCell(Text('88')),
                    const DataCell(Text('90')),
                    const DataCell(Text('82')),
                    const DataCell(Text('84')),
                    const DataCell(Text('89')),
                    const DataCell(Text('86.3', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text('${index + 1}')),
                  ],
                )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
