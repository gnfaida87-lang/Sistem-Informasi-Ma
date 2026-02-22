import 'package:flutter/material.dart';

// ==========================================
// 1. KELOMPOK AKADEMIK
// ==========================================

class ParentAkademikNilaiScreen extends StatelessWidget {
  const ParentAkademikNilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nilai Tugas & Ujian', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNilaiCard('Matematika', 'Tugas Harian 1', '85', Colors.green),
          _buildNilaiCard('Fisika', 'Ujian Tengah Semester', '70', Colors.orange),
          _buildNilaiCard('Bahasa Inggris', 'Tugas Essay', '90', Colors.blue),
        ],
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

class ParentAkademikRaporScreen extends StatelessWidget {
  const ParentAkademikRaporScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Rapor Digital', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.deepOrange.shade200),
            const SizedBox(height: 16),
            const Text('E-Rapor Semester Ganjil 2025/2026', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Status: Lulus / Naik Kelas', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('Unduh Rapor PDF'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade700, foregroundColor: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class ParentAkademikAbsensiScreen extends StatelessWidget {
  const ParentAkademikAbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Kehadiran/Absensi', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatBox('Hadir', '45', Colors.green),
                _buildStatBox('Sakit', '2', Colors.orange),
                _buildStatBox('Izin', '1', Colors.blue),
                _buildStatBox('Alpa', '0', Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            const Expanded(
              child: Center(child: Text('Tidak ada riwayat ketidakhadiran bulan ini.', style: TextStyle(color: Colors.grey))),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String count, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.shade200)),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.shade700)),
          Text(label, style: TextStyle(fontSize: 12, color: color.shade700)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. KELOMPOK MATERI & TUGAS
// ==========================================

class ParentMateriTugasScreen extends StatelessWidget {
  final bool isTugas;
  const ParentMateriTugasScreen({super.key, required this.isTugas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTugas ? 'Tugas Belum Dikerjakan' : 'Materi Pelajaran', style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildItem('Matematika', isTugas ? 'Latihan Soal Aljabar' : 'Materi Bab 3: Aljabar', 'Tenggat: 22 Feb 2026'),
          _buildItem('Bahasa Indonesia', isTugas ? 'Tugas Membuat Puisi' : 'Materi Bab 4: Sastra', 'Tenggat: 25 Feb 2026'),
        ],
      ),
    );
  }

  Widget _buildItem(String mapel, String judul, String info) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(Icons.book, color: Colors.deepOrange.shade400),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$mapel • $info', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class ParentStatusTugasScreen extends StatelessWidget {
  const ParentStatusTugasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pengumpulan Tugas', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatus('Sejarah', 'Tugas Rangkuman Orde Baru', true),
          _buildStatus('Fisika', 'Laporan Praktikum Lensa', false),
        ],
      ),
    );
  }

  Widget _buildStatus(String mapel, String judul, bool isSelesai) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: Icon(isSelesai ? Icons.check_circle : Icons.pending, color: isSelesai ? Colors.green : Colors.orange),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(mapel, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: isSelesai ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(4)),
          child: Text(isSelesai ? 'Selesai & Dinilai' : 'Menunggu Penilaian', style: TextStyle(color: isSelesai ? Colors.green.shade700 : Colors.orange.shade700, fontSize: 11)),
        ),
      ),
    );
  }
}

// ==========================================
// 3. KELOMPOK BIMBEL
// ==========================================

class ParentBimbelProgramScreen extends StatelessWidget {
  const ParentBimbelProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bimbingan Belajar Terdaftar', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade200)),
            child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.star, color: Colors.teal.shade700)),
              title: const Text('Persiapan UTBK & Mandiri', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Tutor: Dr. Ilham Ramadhani\nJadwal: Selasa & Kamis (15:00)'),
              isThreeLine: true,
            ),
          )
        ],
      ),
    );
  }
}

class ParentBimbelNilaiScreen extends StatelessWidget {
  const ParentBimbelNilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Try Out Bimbel', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepOrange.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
            child: ListTile(
              leading: Icon(Icons.score, color: Colors.orange.shade700),
              title: const Text('Try Out Akbar 1 - Skolastik', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('18 Feb 2026'),
              trailing: const Text('680', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ),
          )
        ],
      ),
    );
  }
}
