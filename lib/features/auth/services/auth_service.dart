import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/d1_service.dart';

class AuthService {
  final _d1Service = D1Service();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> signIn(String identifier, String password) async {
    String? deviceId;
    String? deviceName;

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        deviceId = webInfo.userAgent; // Sederhana untuk web, bisa dikembangkan ke local storage UUID
        deviceName = "${webInfo.browserName.name} (Web)";
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        final winInfo = await deviceInfo.windowsInfo;
        deviceId = winInfo.deviceId;
        deviceName = winInfo.computerName;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.model;
      }
    } catch (e) {
      debugPrint("Error getting device info: $e");
    }

    final hashedPassword = _hashPassword(password);
    return await _d1Service.login(
      identifier, 
      hashedPassword, 
      deviceId: deviceId, 
      deviceName: deviceName,
    );
  }

  Future<void> signOut() async {
    // Untuk D1, kita cukup hapus session di provider lokal
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final sql = """
        SELECT r.code 
        FROM user_roles ur 
        JOIN roles r ON ur.role_id = r.id 
        WHERE ur.user_id = ? 
        LIMIT 1
      """;
      final results = await _d1Service.query(sql, params: [userId]);
      if (results.isNotEmpty) {
        return results.first['code'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isWaliKelas(String userId) async {
    try {
      final sql = "SELECT is_wali_kelas FROM teachers WHERE user_id = ? LIMIT 1";
      final results = await _d1Service.query(sql, params: [userId]);
      if (results.isNotEmpty) {
        return (results.first['is_wali_kelas'] == 1);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
