import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  /// Register user and create client profile
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final authResponse = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Registration failed');
    }

    await _supabase.from('clients').insert({
      'id': user.id,
      'name': name,
      'email': email,
      'phone': phone,
    });
  }

  Future<void> login({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
