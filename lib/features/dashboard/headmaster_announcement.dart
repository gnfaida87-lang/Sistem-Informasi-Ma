import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../announcement/models/announcement.dart';
import '../announcement/services/announcement_service.dart';
import '../../core/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class HeadmasterAnnouncement extends ConsumerStatefulWidget {
  const HeadmasterAnnouncement({super.key});

  @override
  ConsumerState<HeadmasterAnnouncement> createState() => _HeadmasterAnnouncementState();
}

class _HeadmasterAnnouncementState extends ConsumerState<HeadmasterAnnouncement> {
  final AnnouncementService _announcementService = AnnouncementService();
  List<Announcement> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final data = await _announcementService.getAnnouncements();
      setState(() {
        _announcements = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
                label: const Text('Buat Pengumuman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B3674),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_announcements.isEmpty)
            const Center(child: Text('Belum ada pengumuman.'))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : (MediaQuery.of(context).size.width > 500 ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final announcement = _announcements[index];
                return _buildAnnouncementCard(announcement);
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
        targetText = 'Semua';
        break;
      case 'GM':
        themeColor = Colors.blue;
        targetText = 'Guru';
        break;
      case 'OT':
        themeColor = Colors.red;
        targetText = 'Wali Murid';
        break;
      default:
        themeColor = Colors.grey;
        targetText = announcement.targetRole;
    }

    final dateStr = DateFormat('dd MMM yyyy').format(announcement.createdAt);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
              Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
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
                    decoration: const InputDecoration(labelText: 'Judul'),
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
                    decoration: const InputDecoration(labelText: 'Target'),
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
                    if (titleController.text.isEmpty || contentController.text.isEmpty) return;

                    final user = ref.read(authProvider).user;
                    if (user == null) return;

                    final newAnnouncement = Announcement(
                      id: '', 
                      title: titleController.text,
                      content: contentController.text,
                      targetRole: selectedTarget,
                      createdBy: user.id,
                      createdAt: DateTime.now(),
                    );

                    final success = await _announcementService.createAnnouncement(newAnnouncement);

                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                      _loadAnnouncements();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengumuman berhasil dibuat')));
                    }
                  },
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
