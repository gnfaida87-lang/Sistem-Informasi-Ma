import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/announcement.dart';
import 'package:flutter/foundation.dart';

class AnnouncementService {
  final _d1Service = D1Service();

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final sql = "SELECT * FROM announcements ORDER BY created_at DESC";
      final results = await _d1Service.query(sql);
      return results.map((json) => Announcement.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
      return [];
    }
  }

  Future<bool> createAnnouncement(Announcement announcement) async {
    try {
      final sql = "INSERT INTO announcements (id, title, content, target_role, created_at) VALUES (?, ?, ?, ?, ?)";
      await _d1Service.query(sql, params: [
        announcement.id,
        announcement.title,
        announcement.content,
        announcement.targetRole,
        DateTime.now().toIso8601String()
      ]);
      return true;
    } catch (e) {
      debugPrint('Error creating announcement: $e');
      return false;
    }
  }

  Stream<List<Announcement>> streamAnnouncements() {
    return Stream.fromFuture(getAnnouncements());
  }
}
