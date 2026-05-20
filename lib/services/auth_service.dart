import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Signs up a new user with email and password, and creates a profile
  /// Returns the AuthResponse from Supabase
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Register user with Supabase Auth
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      // If signup was successful, create a profile in the public.profiles table
      if (response.user != null) {
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Signs in a user with email and password
  /// Returns the AuthResponse from Supabase
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Gets the current user session
  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  /// Gets the current authenticated user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}
