import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signIn(String identifier, String password) async {
    String email = identifier;
    if (!identifier.contains('@')) {
      final user = await _supabase
          .from('users')
          .select('email')
          .eq('username', identifier)
          .maybeSingle();
      if (user != null) {
        email = user['email'];
      }
    }

    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final response = await _supabase
          .from('user_roles')
          .select('roles(code)')
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null && response['roles'] != null) {
        return response['roles']['code'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isWaliKelas(String userId) async {
    try {
      final response = await _supabase
          .from('guru')
          .select('is_wali_kelas')
          .eq('user_id', userId)
          .maybeSingle();
      
      return response?['is_wali_kelas'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
