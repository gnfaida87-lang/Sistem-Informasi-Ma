import 'package:flutter/material.dart';

// ==========================================
// 1. SCREEN ABSENSI BIMBEL
// ==========================================
class BimbelAbsensiScreen extends StatelessWidget {
  final bool isRiwayat;
  const BimbelAbsensiScreen({super.key, this.isRiwayat = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isRiwayat ? 'Riwayat Absensi Bimbel' : 'Input Absensi Bimbel', style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
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
                    child: Icon(Icons.person, color: Colors.deepPurple.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Siswa Bimbel ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(isRiwayat ? 'Hadir pada 15:00' : 'Pilih Kehadiran:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  isRiwayat 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusBtn('H', Colors.green),
                          const SizedBox(width: 8),
                          _buildStatusBtn('S', Colors.orange),
                          const SizedBox(width: 8),
                          _buildStatusBtn('I', Colors.blue),
                          const SizedBox(width: 8),
                          _buildStatusBtn('A', Colors.red),
                        ],
                      ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: !isRiwayat ? FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Absensi berhasil disimpan!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
          Navigator.pop(context);
        },
        backgroundColor: Colors.deepPurple.shade700,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Simpan Absensi', style: TextStyle(color: Colors.white)),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatusBtn(String label, MaterialColor color) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color.shade50, shape: BoxShape.circle, border: Border.all(color: color.shade200)),
        child: Text(label, style: TextStyle(color: color.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}

// ==========================================
// 2. SCREEN NILAI BIMBEL
// ==========================================
class BimbelNilaiScreen extends StatelessWidget {
  final bool isRekap;
  const BimbelNilaiScreen({super.key, this.isRekap = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isRekap ? 'Rekap Nilai Siswa' : 'Input Nilai Latihan/Try Out', style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (context, index) {
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
              title: Text('Siswa Bimbel ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(isRekap ? 'Rata-rata Try Out: 85' : 'Masukkan nilai (0-100)', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              trailing: isRekap 
                ? const Text('85', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.deepPurple))
                : SizedBox(
                    width: 60,
                    child: TextField(
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
      floatingActionButton: !isRekap ? FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai berhasil disimpan!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
          Navigator.pop(context);
        },
        backgroundColor: Colors.deepPurple.shade700,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('Simpan Daftar Nilai', style: TextStyle(color: Colors.white)),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ==========================================
// 3. SCREEN MATERI BIMBEL UMUM
// ==========================================
class BimbelMateriScreen extends StatelessWidget {
  final String title;
  const BimbelMateriScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.cloud_done, color: Colors.deepPurple.shade700),
              ),
              title: Text('$title - Sesi ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Diunggah pada 20 Feb 2026', style: TextStyle(fontSize: 12)),
              trailing: IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menambah data untuk $title...')));
        },
        backgroundColor: Colors.deepPurple.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
