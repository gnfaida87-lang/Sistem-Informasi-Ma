import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/d1_service.dart';
import '../providers/d1_provider.dart';
import '../../shared/models/app_user.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final D1Service _d1Service;

  AuthNotifier(this._d1Service) : super(AuthState(isLoading: false));

  Future<void> signIn(String identifier, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _d1Service.login(identifier, password);
      
      if (response['success'] == true) {
        final user = AppUser.fromJson(response['user']);
        state = state.copyWith(
          user: user,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response['message'] ?? "Login gagal",
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  void signOut() {
    state = AuthState(user: null, isLoading: false, errorMessage: null);
  }

  /// Alias untuk signOut() — digunakan oleh dashboard screens
  void logout() => signOut();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final d1Service = ref.watch(d1ServiceProvider);
  return AuthNotifier(d1Service);
});
