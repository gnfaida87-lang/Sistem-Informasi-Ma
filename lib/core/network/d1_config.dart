class D1Config {
  // Ganti URL ini dengan URL Worker yang Anda dapatkan setelah mendeploy Worker di Cloudflare
  static const String baseUrl = "https://sistem-informasi-ma-api.gn-faida87.workers.dev";
  
  // Jika Anda menambahkan API Key di Worker untuk keamanan
  static const String apiKey = "";

  static bool get isConfigured => baseUrl.isNotEmpty && baseUrl.startsWith('http');
}
