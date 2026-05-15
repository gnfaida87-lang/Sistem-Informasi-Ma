import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/network/d1_service.dart';
import 'package:flutter/foundation.dart';
import '../models/system_settings_model.dart';
import 'package:flutter/foundation.dart';

class SystemService {
  final _d1Service = D1Service();

  // Simple obfuscation for keys
  String _obfuscate(String key) => base64.encode(utf8.encode(key));
  String _deobfuscate(String obfuscated) {
    try {
      return utf8.decode(base64.decode(obfuscated));
    } catch (_) {
      return obfuscated;
    }
  }

  Future<SystemSettings> fetchSettings() async {
    try {
      // Pastikan kolom baru ada
      await _ensureSppColumns();

      final sql = "SELECT * FROM system_settings WHERE id = 1 LIMIT 1";
      final results = await _d1Service.query(sql);

      if (results.isEmpty) {
        return SystemSettings(
          schoolName: 'SI Madrasah',
          appName: 'Selamat Datang di Informasi Akademik Sekolah',
          headmasterName: 'H. Ahmad Syaifuddin, M.Pd',
          guruAiKeys: [],
          guruAiEngine: 'OpenAI (GPT-4o)',
          belajarAiKeys: [],
          belajarAiEngine: 'Gemini (1.5 Pro)',
        );
      }
      
      final row = results.first;
      
      List<String> guruKeys = [];
      List<String> belajarKeys = [];
      
      try {
        if (row['guru_ai_keys'] != null) {
          final decoded = jsonDecode(row['guru_ai_keys']) as List;
          guruKeys = decoded.map((e) => _deobfuscate(e.toString())).toList();
        }
        if (row['belajar_ai_keys'] != null) {
          final decoded = jsonDecode(row['belajar_ai_keys']) as List;
          belajarKeys = decoded.map((e) => _deobfuscate(e.toString())).toList();
        }
      } catch (e) {
        debugPrint("Error decoding keys: $e");
      }

      return SystemSettings(
        schoolName: row['school_name'] ?? 'SI Madrasah',
        appName: row['app_name'] ?? 'Selamat Datang di Informasi Akademik Sekolah',
        headmasterName: row['headmaster_name'] ?? 'H. Ahmad Syaifuddin, M.Pd',
        logoUrl: row['logo_url'],
        faviconUrl: row['favicon_url'],
        guruAiKeys: guruKeys,
        guruAiEngine: row['guru_ai_engine'] ?? 'OpenAI (GPT-4o)',
        belajarAiKeys: belajarKeys,
        belajarAiEngine: row['belajar_ai_engine'] ?? 'Gemini (1.5 Pro)',
        isMaintenance: row['is_maintenance'] == 1,
        gdriveApiKey: row['gdrive_api_key'],
        gdriveFolderId: row['gdrive_folder_id'],
        sppNominalX: (row['spp_nominal_x'] ?? 250000).toDouble(),
        sppNominalXI: (row['spp_nominal_xi'] ?? 275000).toDouble(),
        sppNominalXII: (row['spp_nominal_xii'] ?? 300000).toDouble(),
        academicStartMonth: row['academic_start_month'] ?? 7,
      );
    } catch (e) {
      debugPrint("Error fetchSettings: $e");
      return SystemSettings(
        schoolName: 'SI Madrasah',
        appName: 'Selamat Datang di Informasi Akademik Sekolah',
        headmasterName: 'H. Ahmad Syaifuddin, M.Pd',
        guruAiKeys: [],
        belajarAiKeys: [],
      );
    }
  }

  Future<void> _ensureSppColumns() async {
    try {
      await _d1Service.query("ALTER TABLE system_settings ADD COLUMN spp_nominal_x REAL DEFAULT 250000");
      await _d1Service.query("ALTER TABLE system_settings ADD COLUMN spp_nominal_xi REAL DEFAULT 275000");
      await _d1Service.query("ALTER TABLE system_settings ADD COLUMN spp_nominal_xii REAL DEFAULT 300000");
      await _d1Service.query("ALTER TABLE system_settings ADD COLUMN academic_start_month INTEGER DEFAULT 7");
    } catch (_) {}
  }

  Future<void> updateSettings(SystemSettings settings) async {
    try {
      final guruKeysJson = jsonEncode(settings.guruAiKeys.map(_obfuscate).toList());
      final belajarKeysJson = jsonEncode(settings.belajarAiKeys.map(_obfuscate).toList());

      final sql = """
        INSERT INTO system_settings (
          id, school_name, app_name, headmaster_name, logo_url, favicon_url, 
          guru_ai_keys, guru_ai_engine, belajar_ai_keys, belajar_ai_engine,
          is_maintenance, gdrive_api_key, gdrive_folder_id,
          spp_nominal_x, spp_nominal_xi, spp_nominal_xii, academic_start_month
        )
        VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
        school_name = excluded.school_name,
        app_name = excluded.app_name,
        headmaster_name = excluded.headmaster_name,
        logo_url = excluded.logo_url,
        favicon_url = excluded.favicon_url,
        guru_ai_keys = excluded.guru_ai_keys,
        guru_ai_engine = excluded.guru_ai_engine,
        belajar_ai_keys = excluded.belajar_ai_keys,
        belajar_ai_engine = excluded.belajar_ai_engine,
        is_maintenance = excluded.is_maintenance,
        gdrive_api_key = excluded.gdrive_api_key,
        gdrive_folder_id = excluded.gdrive_folder_id,
        spp_nominal_x = excluded.spp_nominal_x,
        spp_nominal_xi = excluded.spp_nominal_xi,
        spp_nominal_xii = excluded.spp_nominal_xii,
        academic_start_month = excluded.academic_start_month,
        updated_at = CURRENT_TIMESTAMP
      """;
      
      await _d1Service.query(sql, params: [
        settings.schoolName,
        settings.appName,
        settings.headmasterName,
        settings.logoUrl,
        settings.faviconUrl,
        guruKeysJson,
        settings.guruAiEngine,
        belajarKeysJson,
        settings.belajarAiEngine,
        settings.isMaintenance ? 1 : 0,
        settings.gdriveApiKey,
        settings.gdriveFolderId,
        settings.sppNominalX,
        settings.sppNominalXI,
        settings.sppNominalXII,
        settings.academicStartMonth,
      ]);
    } catch (e) {
      debugPrint("Error updateSettings: $e");
      rethrow;
    }
  }

  Future<void> downloadBackup() async {
    await _d1Service.downloadBackup();
  }

  Future<String?> uploadBrandingFile({
    required String fileName, 
    required List<int> fileBytes, 
    required String apiKey, 
    required String folderId,
  }) async {
    final result = await _d1Service.uploadFile(fileBytes, fileName);

    if (result['success'] == true) {
      return result['fileUrl'];
    }
    return null;
  }
}
