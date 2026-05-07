import '../../../core/network/d1_service.dart';
import '../models/system_settings_model.dart';

class SystemService {
  final _d1Service = D1Service();

  Future<SystemSettings> fetchSettings() async {
    try {
      final sql = "SELECT * FROM system_settings WHERE id = 1 LIMIT 1";
      final results = await _d1Service.query(sql);

      if (results.isEmpty) {
        return SystemSettings(
          schoolName: 'SI Madrasah',
          headmasterName: 'H. Ahmad Syaifuddin, M.Pd',
          guruAiKeys: [],
          guruAiEngine: 'OpenAI (GPT-4o)',
          belajarAiKeys: [],
          belajarAiEngine: 'Gemini (1.5 Pro)',
        );
      }
      return SystemSettings.fromJson(results.first);
    } catch (e) {
      print("Error fetchSettings: $e");
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
      final sql = """
        INSERT INTO system_settings (id, school_name, headmaster_name, guru_ai_engine, belajar_ai_engine)
        VALUES (1, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
        school_name = excluded.school_name,
        headmaster_name = excluded.headmaster_name,
        guru_ai_engine = excluded.guru_ai_engine,
        belajar_ai_engine = excluded.belajar_ai_engine
      """;
      await _d1Service.query(sql, params: [
        settings.schoolName,
        settings.headmasterName,
        settings.guruAiEngine,
        settings.belajarAiEngine
      ]);
    } catch (e) {
      print("Error updateSettings: $e");
      rethrow;
    }
  }

  /// Catatan: Cloudflare D1 tidak punya Storage. 
  /// Disarankan menggunakan Cloudflare R2 untuk upload logo/file.
  Future<String?> uploadBrandingFile(String fileName, dynamic fileBytes, String bucket) async {
    // Placeholder untuk integrasi R2 nantinya
    print("Upload file $fileName ke $bucket belum dikonfigurasi untuk R2.");
    return null;
  }
}
