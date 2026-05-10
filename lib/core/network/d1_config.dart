class D1Config {
  static const String baseUrl = "https://sistem-informasi-ma-api.gn-faida87.workers.dev";
  static const String apiKey = "MADRASAH_KEY_2024";

  static bool get isConfigured => baseUrl.isNotEmpty && baseUrl.startsWith('http');
}
