import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';

/// Thin wrapper over Supabase GoTrue auth.
///
/// Returns raw Supabase types; mapping to domain entities and [Failure]
/// translation happens in the repository implementation.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  User? get currentUser => _auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  Future<User> signIn({required String email, required String password}) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign in failed. Please try again.');
    }
    return user;
  }

  Future<User> signUp({required String email, required String password}) async {
    final response = await _auth.signUp(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign up failed. Please try again.');
    }
    return user;
  }

  /// Exchanges a Google OIDC ID token for a Supabase session.
  ///
  /// This is both sign-in and sign-up: Supabase creates the user on first use
  /// of a given Google identity, and the `on_auth_user_created` trigger seeds
  /// their profile and starter categories.
  Future<User> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
  }) async {
    final response = await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Google sign in failed. Please try again.');
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) => _auth.resetPasswordForEmail(
    email,
    redirectTo: AppConfig.passwordResetRedirect,
  );

  /// Sets a new password for the user in the active (recovery) session.
  Future<void> updatePassword(String newPassword) =>
      _auth.updateUser(UserAttributes(password: newPassword));

  /// Re-sends the sign-up confirmation email.
  Future<void> resendConfirmation(String email) =>
      _auth.resend(type: OtpType.signup, email: email);
}
