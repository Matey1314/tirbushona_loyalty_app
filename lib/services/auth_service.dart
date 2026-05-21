import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Sends an SMS with a one-time password to the specified phone number
  /// This initiates the phone authentication flow
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verifies the OTP code sent to the phone number
  /// Returns the AuthResponse from Supabase containing the session
  Future<AuthResponse> verifyPhoneOtp(
    String phoneNumber,
    String token,
  ) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
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
