import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../services/announcement_service.dart';
import 'package:intl/intl.dart';

class AnnouncementListWidget extends StatelessWidget {
  final String targetRoleFilter;
  final AnnouncementService _announcementService = AnnouncementService();

  AnnouncementListWidget({super.key, required this.targetRoleFilter});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Announcement>>(
      stream: _announcementService.streamAnnouncements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final allAnnouncements = snapshot.data ?? [];
        // Filter based on targetRoleFilter and 'ALL'
        final filteredAnnouncements = allAnnouncements.where((a) => 
          a.targetRole == 'ALL' || a.targetRole == targetRoleFilter
        ).toList();

        if (filteredAnnouncements.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada pengumuman untuk Anda.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredAnnouncements.length,
          itemBuilder: (context, index) {
            final announcement = filteredAnnouncements[index];
            return _buildInfoCard(announcement);
          },
        );
      },
    );
  }

  Widget _buildInfoCard(Announcement announcement) {
    final dateStr = DateFormat('dd MMM yyyy').format(announcement.createdAt);
    
    IconData icon;
    MaterialColor color;
    
    switch (announcement.targetRole) {
      case 'ALL':
        icon = Icons.campaign;
        color = Colors.orange;
        break;
      case 'GM':
        icon = Icons.school;
        color = Colors.blue;
        break;
      case 'OT':
        icon = Icons.family_restroom;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey as MaterialColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2B3674),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.content,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color.shade700,
                      ),
                    ),
                    if (announcement.targetRole != 'ALL')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          announcement.targetRole,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: color.shade900,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
