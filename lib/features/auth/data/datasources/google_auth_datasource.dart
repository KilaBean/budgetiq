import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_config.dart';

/// Tokens obtained from the native Google account picker.
@immutable
class GoogleCredentials {
  const GoogleCredentials({required this.idToken, this.accessToken});

  /// OIDC ID token, signed for [AppConfig.googleWebClientId]. This is what
  /// Supabase verifies to establish the session.
  final String idToken;

  /// OAuth access token, when the requested scopes are already granted.
  /// Optional — Supabase only needs it to call Google APIs on the user's
  /// behalf, which BudgetIQ does not do.
  final String? accessToken;
}

/// Raised when the Google flow cannot produce credentials.
///
/// [cancelled] distinguishes "the user backed out of the picker" (not an
/// error worth surfacing) from a genuine failure.
class GoogleAuthException implements Exception {
  const GoogleAuthException(this.message, {this.cancelled = false});

  final String message;
  final bool cancelled;

  @override
  String toString() => 'GoogleAuthException($message)';
}

/// Thin wrapper over `google_sign_in` that yields the ID token Supabase needs.
///
/// Uses the native account picker (Credential Manager on Android, the Google
/// SDK on iOS) rather than a browser round-trip, which is both faster and the
/// flow users expect from a commercial finance app.
class GoogleAuthDataSource {
  GoogleAuthDataSource({GoogleSignIn? signIn}) : _injectedSignIn = signIn;

  /// Scopes needed purely to populate the user's profile on the Supabase side.
  static const List<String> scopes = ['email', 'profile'];

  final GoogleSignIn? _injectedSignIn;

  /// Resolved lazily so that merely constructing this data source never reaches
  /// for the plugin singleton — important for unit tests and for builds that
  /// never offer Google sign-in.
  GoogleSignIn get _signIn => _injectedSignIn ?? GoogleSignIn.instance;

  Future<void>? _initialization;

  /// Initializes the plugin exactly once per process; concurrent callers await
  /// the same future.
  Future<void> _ensureInitialized() {
    return _initialization ??= _signIn.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? _nullIfEmpty(AppConfig.googleIosClientId)
          : null,
      serverClientId: _nullIfEmpty(AppConfig.googleWebClientId),
    );
  }

  /// Prompts the user to pick a Google account and returns their tokens.
  ///
  /// Throws [GoogleAuthException] when unconfigured, unsupported, cancelled,
  /// or when Google declines to issue an ID token.
  Future<GoogleCredentials> authenticate() async {
    if (!AppConfig.hasGoogleSignIn) {
      throw const GoogleAuthException(
        'Google sign-in is not configured for this build.',
      );
    }

    await _ensureInitialized();

    if (!_signIn.supportsAuthenticate()) {
      throw const GoogleAuthException(
        'Google sign-in is not available on this device.',
      );
    }

    final GoogleSignInAccount account;
    try {
      account = await _signIn.authenticate(scopeHint: scopes);
    } on GoogleSignInException catch (e) {
      throw GoogleAuthException(
        e.description ?? 'Google sign-in failed.',
        cancelled: e.code == GoogleSignInExceptionCode.canceled,
      );
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const GoogleAuthException(
        'Google did not return an ID token. Check that the web client ID is '
        'configured correctly.',
      );
    }

    // Non-interactive: returns a token only if the scopes are already granted,
    // so this never adds a second prompt.
    String? accessToken;
    try {
      final authorization = await account.authorizationClient
          .authorizationForScopes(scopes);
      accessToken = authorization?.accessToken;
    } on GoogleSignInException {
      accessToken = null;
    }

    return GoogleCredentials(idToken: idToken, accessToken: accessToken);
  }

  /// Clears the cached Google account so the next sign-in shows the picker.
  Future<void> signOut() async {
    if (_initialization == null) return;
    try {
      await _signIn.signOut();
    } on GoogleSignInException {
      // Nothing actionable — the Supabase session is what gates the app.
    }
  }

  static String? _nullIfEmpty(String value) => value.isEmpty ? null : value;
}
