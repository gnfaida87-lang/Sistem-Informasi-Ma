class D1Config {
  // URL Worker Cloudflare Anda
  static const String baseUrl = "https://sistem-informasi-ma-api.gn-faida87.workers.dev";

  // Isi dengan API key yang Anda set saat menjalankan: npm run secret:set
  // Contoh: "SiMadrasah_2025_xK9mNpQr7vWzA3bD"
  static const String apiKey = "GANTI_DENGAN_API_KEY_ANDA";

  static bool get isConfigured =>
      baseUrl.isNotEmpty &&
      baseUrl.startsWith('http') &&
      apiKey.isNotEmpty &&
      apiKey != "GANTI_DENGAN_API_KEY_ANDA";
}
