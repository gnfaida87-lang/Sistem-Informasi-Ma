class SystemSettings {
  final String schoolName;
  final String appName;
  final String headmasterName;
  final String? logoUrl;
  final String? faviconUrl;
  final List<String> guruAiKeys;
  final String? guruAiEngine;
  final List<String> belajarAiKeys;
  final String? belajarAiEngine;
  final bool isMaintenance;
  final String? gdriveApiKey;
  final String? gdriveFolderId;
  
  // SPP Settings
  final double sppNominalX;
  final double sppNominalXI;
  final double sppNominalXII;
  final int academicStartMonth; // 1-12 (1=Januari, 7=Juli)

  SystemSettings({
    required this.schoolName,
    required this.appName,
    required this.headmasterName,
    this.logoUrl,
    this.faviconUrl,
    required this.guruAiKeys,
    this.guruAiEngine,
    required this.belajarAiKeys,
    this.belajarAiEngine,
    this.isMaintenance = false,
    this.gdriveApiKey,
    this.gdriveFolderId,
    this.sppNominalX = 250000,
    this.sppNominalXI = 275000,
    this.sppNominalXII = 300000,
    this.academicStartMonth = 7,
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
      appName: json['app_name'] ?? 'Selamat Datang di Informasi Akademik Sekolah',
      headmasterName: json['headmaster_name'] ?? 'H. Ahmad Syaifuddin, M.Pd',
      logoUrl: json['logo_url'],
      faviconUrl: json['favicon_url'],
      guruAiKeys: _parseList(json['guru_ai_keys']),
      guruAiEngine: json['guru_ai_engine'] ?? 'OpenAI (GPT-4o)',
      belajarAiKeys: _parseList(json['belajar_ai_keys']),
      belajarAiEngine: json['belajar_ai_engine'] ?? 'Gemini (1.5 Pro)',
      isMaintenance: json['is_maintenance'] == 1 || json['is_maintenance'] == true,
      gdriveApiKey: json['gdrive_api_key'],
      gdriveFolderId: json['gdrive_folder_id'],
      sppNominalX: (json['spp_nominal_x'] ?? 250000).toDouble(),
      sppNominalXI: (json['spp_nominal_xi'] ?? 275000).toDouble(),
      sppNominalXII: (json['spp_nominal_xii'] ?? 300000).toDouble(),
      academicStartMonth: json['academic_start_month'] ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'school_name': schoolName,
      'app_name': appName,
      'headmaster_name': headmasterName,
      'logo_url': logoUrl,
      'favicon_url': faviconUrl,
      'guru_ai_keys': guruAiKeys,
      'guru_ai_engine': guruAiEngine,
      'belajar_ai_keys': belajarAiKeys,
      'belajar_ai_engine': belajarAiEngine,
      'is_maintenance': isMaintenance ? 1 : 0,
      'gdrive_api_key': gdriveApiKey,
      'gdrive_folder_id': gdriveFolderId,
      'spp_nominal_x': sppNominalX,
      'spp_nominal_xi': sppNominalXI,
      'spp_nominal_xii': sppNominalXII,
      'academic_start_month': academicStartMonth,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  SystemSettings copyWith({
    String? schoolName,
    String? appName,
    String? headmasterName,
    String? logoUrl,
    String? faviconUrl,
    List<String>? guruAiKeys,
    String? guruAiEngine,
    List<String>? belajarAiKeys,
    String? belajarAiEngine,
    bool? isMaintenance,
    String? gdriveApiKey,
    String? gdriveFolderId,
    double? sppNominalX,
    double? sppNominalXI,
    double? sppNominalXII,
    int? academicStartMonth,
  }) {
    return SystemSettings(
      schoolName: schoolName ?? this.schoolName,
      appName: appName ?? this.appName,
      headmasterName: headmasterName ?? this.headmasterName,
      logoUrl: logoUrl ?? this.logoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      guruAiKeys: guruAiKeys ?? this.guruAiKeys,
      guruAiEngine: guruAiEngine ?? this.guruAiEngine,
      belajarAiKeys: belajarAiKeys ?? this.belajarAiKeys,
      belajarAiEngine: belajarAiEngine ?? this.belajarAiEngine,
      isMaintenance: isMaintenance ?? this.isMaintenance,
      gdriveApiKey: gdriveApiKey ?? this.gdriveApiKey,
      gdriveFolderId: gdriveFolderId ?? this.gdriveFolderId,
      sppNominalX: sppNominalX ?? this.sppNominalX,
      sppNominalXI: sppNominalXI ?? this.sppNominalXI,
      sppNominalXII: sppNominalXII ?? this.sppNominalXII,
      academicStartMonth: academicStartMonth ?? this.academicStartMonth,
    );
  }
}
