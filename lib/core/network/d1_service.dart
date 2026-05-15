import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'd1_config.dart';
import 'package:flutter/foundation.dart';

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
  Future<Map<String, dynamic>> login(String identifier, String password, {String? deviceId, String? deviceName}) async {
    debugPrint("DEBUG: Memulai login ke ${D1Config.baseUrl}/login");
    try {
      final response = await http.post(
        Uri.parse("${D1Config.baseUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier,
          "password": password,
          "deviceId": deviceId,
          "deviceName": deviceName,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint("DEBUG: Response Status: ${response.statusCode}");
      debugPrint("DEBUG: Response Body: ${response.body}");

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
      debugPrint("DEBUG: Error Login: $e");
      return {
        "success": false,
        "message": "Kesalahan koneksi: $e"
      };
    }
  }

  /// Mengunduh backup database (SQLite file)
  Future<void> downloadBackup() async {
    try {
      final String url = "${D1Config.baseUrl}/backup?api_key=${D1Config.apiKey}";
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw "Tidak bisa membuka tautan backup.";
      }
    } catch (e) {
      debugPrint("Error downloadBackup: $e");
      rethrow;
    }
  }

  /// Mengunggah file ke Google Drive via Worker Bridge
  Future<Map<String, dynamic>> uploadFile(List<int> bytes, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${D1Config.baseUrl}/upload"),
      );

      request.headers.addAll({
        if (D1Config.apiKey.isNotEmpty) "X-API-Key": D1Config.apiKey,
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data['message'] ?? "Gagal upload (Status ${response.statusCode})"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Kesalahan upload: $e"
      };
    }
  }
}
