import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client provider
final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// AuthService for login/register/logout
class AuthService {
  final SupabaseClient supabase;

  AuthService(this.supabase);

  Future<User?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await supabase.auth.signUp(email: email, password: password);

    final user = res.user;

    // If user created, insert into clients table
    if (user != null) {
      await supabase.from('clients').insert({
        'id': user.id,
        'name': name,
        'email': email,
      });
    }

    return user;
  }

  Future<User?> login({required String email, required String password}) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
}

/// AuthService provider
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AuthService(supabase);
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<User?> {
  final SupabaseClient supabase;

  AuthNotifier(this.supabase) : super(supabase.auth.currentUser) {
    supabase.auth.onAuthStateChange.listen((event) {
      state = event.session?.user;
    });
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    state = null;
  }
}

/// AuthNotifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AuthNotifier(supabase);
});

/// Current user provider
final authStateProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider);
});
