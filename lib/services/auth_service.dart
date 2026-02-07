import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

/// Authentication Service - handles all auth operations
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user data from database
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', currentUser!.id)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user role
  Future<String?> getUserRole() async {
    try {
      if (currentUser == null) return null;

      final response = await _supabase
          .from('users')
          .select('role_id, roles(role_name)')
          .eq('id', currentUser!.id)
          .maybeSingle();

      if (response == null) return null;
      return response['roles']['role_name'] as String;
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
