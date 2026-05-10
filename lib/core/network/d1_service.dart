import 'dart:convert';
import 'package:http/http.dart' as http;
import 'd1_config.dart';

class D1Service {
  static final D1Service _instance = D1Service._internal();
  factory D1Service() => _instance;
  D1Service._internal();

  /// Menjalankan query SQL umum ke Cloudflare D1 via Worker Bridge
  Future<List<dynamic>> query(String sql, {List<dynamic>? params}) async {
    try {
      final response = await http.post(
        Uri.parse("${D1Config.baseUrl}/query"),
        headers: {
          "Content-Type": "application/json",
          if (D1Config.apiKey.isNotEmpty) "X-API-Key": D1Config.apiKey,
        },
        body: jsonEncode({
          "sql": sql,
          "params": params ?? [],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cloudflare D1 mengembalikan object dengan key 'results'
        return data['results'] ?? [];
      } else {
        throw Exception("Gagal menjalankan query: ${response.body}");
      }
    } catch (e) {
      throw Exception("Kesalahan koneksi D1: $e");
    }
  }

  /// Khusus untuk proses Login
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    print("DEBUG: Memulai login ke ${D1Config.baseUrl}/login");
    try {
      final response = await http.post(
        Uri.parse("${D1Config.baseUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 15));

      print("DEBUG: Response Status: ${response.statusCode}");
      print("DEBUG: Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Login gagal (Status ${response.statusCode})"
        };
      }
    } catch (e) {
      print("DEBUG: Error Login: $e");
      return {
        "success": false,
        "message": "Kesalahan koneksi: $e"
      };
    }
  }
}
