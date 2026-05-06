import 'package:flutter/material.dart';
import '../announcement/models/announcement.dart';
import '../announcement/services/announcement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HeadmasterAnnouncement extends StatefulWidget {
  const HeadmasterAnnouncement({super.key});

  @override
  State<HeadmasterAnnouncement> createState() => _HeadmasterAnnouncementState();
}

class _HeadmasterAnnouncementState extends State<HeadmasterAnnouncement> {
  final AnnouncementService _announcementService = AnnouncementService();

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
                onPressed: () => _showCreateAnnouncementDialog(context),
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
          
          StreamBuilder<List<Announcement>>(
            stream: _announcementService.streamAnnouncements(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final announcements = snapshot.data ?? [];
              if (announcements.isEmpty) {
                return const Center(child: Text('Belum ada pengumuman.'));
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final announcement = announcements[index];
                  return _buildAnnouncementCard(announcement);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    Color themeColor;
    String targetText;
    
    switch (announcement.targetRole) {
      case 'ALL':
        themeColor = Colors.orange;
        targetText = 'Dikirim ke: Semua User';
        break;
      case 'GM':
        themeColor = Colors.blue;
        targetText = 'Dikirim ke: Guru';
        break;
      case 'OT':
        themeColor = Colors.red;
        targetText = 'Dikirim ke: Orang Tua';
        break;
      default:
        themeColor = Colors.grey;
        targetText = 'Dikirim ke: ${announcement.targetRole}';
    }

    final timeAgo = DateFormat('dd MMM yyyy').format(announcement.createdAt);

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
                child: Text(targetText, style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Text(timeAgo, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2B3674))),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              announcement.content,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedTarget = 'ALL';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Buat Pengumuman Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Judul Pengumuman'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(labelText: 'Isi Pengumuman'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTarget,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('Semua User')),
                      DropdownMenuItem(value: 'GM', child: Text('Guru')),
                      DropdownMenuItem(value: 'OT', child: Text('Orang Tua')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedTarget = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Target User'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty || contentController.text.isEmpty) {
                      return;
                    }

                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) return;

                    final newAnnouncement = Announcement(
                      id: '', // Will be generated by Supabase
                      title: titleController.text,
                      content: contentController.text,
                      targetRole: selectedTarget,
                      createdBy: user.id,
                      createdAt: DateTime.now(),
                    );

                    final success = await _announcementService.createAnnouncement(newAnnouncement);

                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pengumuman berhasil dibuat')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal membuat pengumuman')),
                      );
                    }
                  },
                  child: const Text('Simpan & Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

