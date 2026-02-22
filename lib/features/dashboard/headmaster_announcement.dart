import 'package:flutter/material.dart';

class HeadmasterAnnouncement extends StatelessWidget {
  const HeadmasterAnnouncement({super.key});

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
                'Pusat Pengumuman',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_alert),
                label: const Text('Buat Pengumuman Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAnnouncementCard(
                'Libur Awal Ramadhan 1447H',
                'Seluruh kegiatan belajar mengajar diliburkan selama 3 hari awal r...',
                'Dikirim ke: Semua User',
                '1 Hari lalu',
                Colors.orange,
              ),
              _buildAnnouncementCard(
                'Rapat Koordinasi Ujian',
                'Diharapkan seluruh Guru Mapel dan Wakakur hadir di Ruang Rapat ut...',
                'Dikirim ke: Guru',
                '3 Hari lalu',
                Colors.blue,
              ),
              _buildAnnouncementCard(
                'Tenggat Pembayaran SPP',
                'Mengingatkan kepada wali murid untuk melunasi tanggungan se...',
                'Dikirim ke: Orang Tua',
                '1 Minggu lalu',
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String content, String target, String time, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(target, style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2B3674))),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              content,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
