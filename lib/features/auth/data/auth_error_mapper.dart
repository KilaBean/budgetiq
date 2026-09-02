import 'package:supabase_flutter/supabase_flutter.dart';

/// Translates raw Supabase auth errors into clear, friendly messages.
///
/// Matches on the stable error [AuthException.code] where available and falls
/// back to message keywords, so users see "Email or password is incorrect"
/// rather than low-level provider text.
String mapAuthError(AuthException e) {
  final code = e.code?.toLowerCase();
  final message = e.message.toLowerCase();

  bool has(String s) => code == s || message.contains(s);

  if (has('invalid_credentials') || message.contains('invalid login')) {
    return 'Email or password is incorrect.';
  }
  if (has('email_not_confirmed') || message.contains('not confirmed')) {
    return 'Please confirm your email before signing in.';
  }
  if (has('user_already_exists') ||
      has('email_exists') ||
      message.contains('already registered')) {
    return 'An account with this email already exists.';
  }
  if (has('weak_password') || message.contains('password should be')) {
    return 'Please choose a stronger password (at least 8 characters).';
  }
  if (has('over_email_send_rate_limit') ||
      has('over_request_rate_limit') ||
      message.contains('rate limit')) {
    return 'Too many attempts. Please wait a moment and try again.';
  }
  if (has('identity_already_exists')) {
    return 'This Google account is already linked to another user.';
  }
  if (has('provider_disabled') || message.contains('provider is not enabled')) {
    return 'Google sign-in is not enabled for this app yet.';
  }
  if (has('bad_oauth_state') ||
      has('bad_jwt') ||
      message.contains('invalid token')) {
    return 'Google sign-in could not be verified. Please try again.';
  }
  if (has('validation_failed') ||
      message.contains('unable to validate email')) {
    return 'Please enter a valid email address.';
  }
  // Reasonable default that's still user-safe.
  return 'Something went wrong. Please try again.';
}
