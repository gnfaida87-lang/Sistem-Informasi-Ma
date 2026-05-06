import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/system_settings_model.dart';
import '../../../core/utils/error_handler.dart';

class SystemService {
  final _supabase = Supabase.instance.client;

  Future<SystemSettings> fetchSettings() async {
    try {
      final response = await _supabase
          .from('system_settings')
          .select()
          .eq('id', 1)
          .maybeSingle();

      if (response == null) {
        // Return default if not found
        return SystemSettings(
          schoolName: 'SI Madrasah',
          headmasterName: 'H. Ahmad Syaifuddin, M.Pd',
          guruAiKeys: [],
          guruAiEngine: 'OpenAI (GPT-4o)',
          belajarAiKeys: [],
          belajarAiEngine: 'Gemini (1.5 Pro)',
        );
      }
      return SystemSettings.fromJson(response);
    } catch (e) {
      final appError = handleSupabaseError(e);
      logError(appError, context: 'fetchSettings');
      return SystemSettings(
        schoolName: 'SI Madrasah',
        headmasterName: 'H. Ahmad Syaifuddin, M.Pd',
        guruAiKeys: [],
        guruAiEngine: 'OpenAI (GPT-4o)',
        belajarAiKeys: [],
        belajarAiEngine: 'Gemini (1.5 Pro)',
      );
    }
  }

  Future<void> updateSettings(SystemSettings settings) async {
    try {
      await _supabase.from('system_settings').upsert({
        'id': 1,
        ...settings.toJson(),
      });
    } catch (e) {
      final appError = handleSupabaseError(e);
      logError(appError, context: 'updateSettings');
      throw appError;
    }
  }

  Future<String?> uploadBrandingFile(String fileName, Uint8List fileBytes, String bucket) async {
    try {
      final path = 'branding/$fileName';
      
      await _supabase.storage.from(bucket).uploadBinary(
        path,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final String publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      final appError = handleSupabaseError(e);
      logError(appError, context: 'uploadBrandingFile');
      return null;
    }
  }
}
