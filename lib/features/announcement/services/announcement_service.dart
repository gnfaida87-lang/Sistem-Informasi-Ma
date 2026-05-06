import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';

class AnnouncementService {
  final _supabase = Supabase.instance.client;

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _supabase
          .from('announcements')
          .select()
          .order('created_at', ascending: false);
      
      if (response == null) return [];
      return (response as List).map((json) => Announcement.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  Future<bool> createAnnouncement(Announcement announcement) async {
    try {
      await _supabase.from('announcements').insert(announcement.toJson());
      return true;
    } catch (e) {
      print('Error creating announcement: $e');
      return false;
    }
  }

  Stream<List<Announcement>> streamAnnouncements() {
    return _supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          if (data == null) return [];
          return data.map((json) => Announcement.fromJson(json)).toList();
        });
  }

}
