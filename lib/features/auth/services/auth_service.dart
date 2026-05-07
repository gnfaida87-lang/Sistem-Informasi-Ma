import '../../../core/network/d1_service.dart';

class AuthService {
  final _d1Service = D1Service();

  Future<Map<String, dynamic>> signIn(String identifier, String password) async {
    return await _d1Service.login(identifier, password);
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
