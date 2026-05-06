class SystemSettings {
  final String schoolName;
  final String headmasterName;
  final String? logoUrl;
  final String? faviconUrl;
  final List<String> guruAiKeys;
  final String? guruAiEngine;
  final List<String> belajarAiKeys;
  final String? belajarAiEngine;

  SystemSettings({
    required this.schoolName,
    required this.headmasterName,
    this.logoUrl,
    this.faviconUrl,
    required this.guruAiKeys,
    this.guruAiEngine,
    required this.belajarAiKeys,
    this.belajarAiEngine,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    List<String> _parseList(dynamic data) {
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return [];
    }

    return SystemSettings(
      schoolName: json['school_name'] ?? 'SI Madrasah',
      headmasterName: json['headmaster_name'] ?? 'H. Ahmad Syaifuddin, M.Pd',
      logoUrl: json['logo_url'],
      faviconUrl: json['favicon_url'],
      guruAiKeys: _parseList(json['guru_ai_keys']),
      guruAiEngine: json['guru_ai_engine'] ?? 'OpenAI (GPT-4o)',
      belajarAiKeys: _parseList(json['belajar_ai_keys']),
      belajarAiEngine: json['belajar_ai_engine'] ?? 'Gemini (1.5 Pro)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_name': schoolName,
      'headmaster_name': headmasterName,
      'logo_url': logoUrl,
      'favicon_url': faviconUrl,
      'guru_ai_keys': guruAiKeys,
      'guru_ai_engine': guruAiEngine,
      'belajar_ai_keys': belajarAiKeys,
      'belajar_ai_engine': belajarAiEngine,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
