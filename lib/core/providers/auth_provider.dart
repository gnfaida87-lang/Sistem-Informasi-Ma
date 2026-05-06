import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_provider.dart';

class AuthState {
  final Session? session;
  final String? userRole;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.session,
    this.userRole,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    Session? session,
    String? userRole,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      session: session ?? this.session,
      userRole: userRole ?? this.userRole,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(AuthState(isLoading: true)) {
    listenAuthChanges();
  }

  void listenAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session != null) {
        String? role;
        try {
          // get user role from profile if your logic requires
          final res = await _supabase
              .from('profiles')
              .select('role')
              .eq('user_id', session.user.id)
              .maybeSingle();

          role = res?['role'] as String?;
        } catch (_) {
          // Fallback or handle error
          role = session.user.userMetadata?['role'] as String?;
        }
        
        state = state.copyWith(
          session: session,
          userRole: role,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          session: null,
          userRole: null,
          isLoading: false,
          errorMessage: null,
        );
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      String? role;
      try{
         final res = await _supabase
              .from('profiles')
              .select('role')
              .eq('user_id', response.session!.user.id)
              .maybeSingle();

          role = res?['role'] as String?;
      }catch(_) {
           role = response.session?.user.userMetadata?['role'] as String?;
      }

      state = state.copyWith(
        session: response.session,
        userRole: role,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _supabase.auth.signOut();
    state = state.copyWith(
      session: null,
      userRole: null,
      isLoading: false,
      errorMessage: null,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthNotifier(supabase);
});
