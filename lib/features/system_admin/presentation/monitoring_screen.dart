import 'package:flutter/material.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.red.shade800,
              child: const Text('Monitoring Sistem', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader('Log Aktivitas & Audit Trail', Icons.history),
            const SizedBox(height: 12),
            _buildLogCard(
              context,
              'Perubahan Data Siswa',
              'OPERATOR_DATA (Budi)',
              'Berhasil mengedit NISN siswa Ahmad',
              '2 Menit yang lalu',
              Icons.edit_note,
              Colors.blue,
            ),
            _buildLogCard(
              context,
              'Kenaikan Kelas Master',
              'WAKIL_KURIKULUM (Siti)',
              'Menjalankan pipeline kenaikan kelas ke Semester Ganjil 2025/2026',
              '1 Jam yang lalu',
              Icons.trending_up,
              Colors.green,
            ),
            _buildLogCard(
              context,
              'Penghapusan User',
              'SUPERADMIN (Anda)',
              'Menghapus user id=xx-yy-zz secara permanen',
              '1 Hari yang lalu',
              Icons.delete_forever,
              Colors.red,
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('Pemantauan Keamanan', Icons.security),
            const SizedBox(height: 12),
            _buildLogCard(
              context,
              'Gagal Login (IP: 103.45.2.1)',
              'SYSTEM_GUARD',
              'Percobaan login gagal 5 kali berturut-turut pada akun Kepsek.',
              '3 Hari yang lalu',
              Icons.warning_amber_rounded,
              Colors.orange,
            ),
          ],
        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLogCard(BuildContext context, String title, String user, String detail, String time, IconData icon, MaterialColor color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.shade50,
              radius: 18,
              child: Icon(icon, color: color.shade600, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Oleh: $user',
                    style: TextStyle(fontSize: 12, color: color.shade700, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
