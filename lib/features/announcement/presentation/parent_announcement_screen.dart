import 'package:flutter/material.dart';
import 'announcement_list_widget.dart';

class ParentAnnouncementScreen extends StatelessWidget {
  const ParentAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pusat Pengumuman', style: TextStyle(color: Color(0xFF2B3674), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2B3674)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Terbaru dari Madrasah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2B3674)),
            ),
            const SizedBox(height: 8),
            Text(
              'Pantau terus pengumuman agar tidak ketinggalan info penting sekolah.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            AnnouncementListWidget(targetRoleFilter: 'OT'),
          ],
        ),
      ),
    );
  }
}
