import 'package:flutter/material.dart';
import '../services/teacher_service.dart';
import '../models/teacher_models.dart';
import '../../../core/mixins/safe_async_mixin.dart';
import 'bimbel_materi_screen.dart'; // Reuse for the detail forms

class TeacherMateriUnifiedScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  final List<TeachingSchedule> schedules; // Added to get real classes
  const TeacherMateriUnifiedScreen({super.key, required this.profile, required this.schedules});

  @override
  State<TeacherMateriUnifiedScreen> createState() => _TeacherMateriUnifiedScreenState();
}

class _TeacherMateriUnifiedScreenState extends State<TeacherMateriUnifiedScreen> with SafeAsync {
  int _activeTab = 0; // 0: Video, 1: Materi, 2: Arsip

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Materi Pembelajaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildTopMenu(),
          Expanded(
            child: _buildActiveView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuItem(0, 'Video', Icons.play_circle_filled, Colors.red),
          _buildMenuItem(1, 'Materi', Icons.description, Colors.blue),
          _buildMenuItem(2, 'Arsip', Icons.inventory_2, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, String label, IconData icon, Color color) {
    bool isActive = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))] : [],
            ),
            child: Icon(icon, color: isActive ? Colors.white : color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? color : Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildActiveView() {
    switch (_activeTab) {
      case 0:
        return _buildActionCard(
          title: 'Unggah Video Pembelajaran',
          subtitle: 'Gunakan link YouTube untuk berbagi video ke siswa.',
          buttonText: 'Mulai Upload Video',
          icon: Icons.video_library,
          color: Colors.red,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BimbelMateriScreen(title: 'Video Pembelajaran (YouTube)'))),
        );
      case 1:
        return _buildActionCard(
          title: 'Bagikan Materi (Drive)',
          subtitle: 'Bagikan dokumen atau modul dari Google Drive Anda.',
          buttonText: 'Pilih Materi Drive',
          icon: Icons.cloud_upload,
          color: Colors.blue,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BimbelMateriScreen(title: 'Upload Materi (Google Drive)'))),
        );
      case 2:
        return _buildArsipList();
      default:
        return const SizedBox();
    }
  }

  Widget _buildActionCard({required String title, required String subtitle, required String buttonText, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArsipList() {
    // Simulasi data arsip per pertemuan
    final dummyArsip = [
      {'pertemuan': 1, 'judul': 'Pengantar Materi Dasar', 'tipe': 'Video', 'tgl': '10 Mei 2026'},
      {'pertemuan': 2, 'judul': 'Latihan Pemahaman Teks', 'tipe': 'Dokumen', 'tgl': '12 Mei 2026'},
      {'pertemuan': 3, 'judul': 'Pembahasan Modul Bab 2', 'tipe': 'Video', 'tgl': '15 Mei 2026'},
    ];

    if (dummyArsip.isEmpty) return _emptyState('Belum ada arsip materi', Icons.inventory_2_outlined);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text('Arsip Materi Tersimpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade700)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: dummyArsip.length,
            itemBuilder: (context, index) {
              final m = dummyArsip[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    child: Text('${m['pertemuan']}', style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(m['judul'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('${m['tipe']} • ${m['tgl']}', style: const TextStyle(fontSize: 11)),
                  trailing: ElevatedButton.icon(
                    onPressed: () => _showShareDialog(m),
                    icon: const Icon(Icons.share, size: 14),
                    label: const Text('Bagikan', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade50,
                      foregroundColor: Colors.teal.shade700,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showShareDialog(Map<String, dynamic> materi) {
    // Get unique class names from schedules
    final classes = widget.schedules
        .map((s) => '${s.className} - ${s.subjectName}')
        .toSet()
        .toList();
    
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Anda belum memiliki jadwal kelas yang terdaftar'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    String? selectedClass;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bagikan Materi ke Kelas Lain', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Materi: ${materi['judul']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 24),
                  const Text('Pilih Kelas Tujuan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedClass,
                        isExpanded: true,
                        hint: const Text('Pilih Kelas...'),
                        items: classes.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
                        onChanged: (val) => setModalState(() => selectedClass = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: selectedClass == null ? null : () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Materi berhasil dipublikasikan ke $selectedClass'),
                          backgroundColor: Colors.teal.shade700,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Publikasi Materi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _emptyState(String msg, IconData icon) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 48, color: Colors.grey.shade300), const SizedBox(height: 8), Text(msg, style: TextStyle(color: Colors.grey.shade400))]));
}
