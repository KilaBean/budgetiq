/// Application-wide configuration values.
///
/// Secrets are injected at build/run time via `--dart-define` so that no
/// credentials are ever hard-coded into source control:
///
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJ...
/// ```
class AppConfig {
  const AppConfig._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  /// Whether the required Supabase credentials were provided at build time.
  static bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Deep-link redirect target for the password-recovery email. Must be
  /// registered in the Supabase dashboard (Authentication → URL Configuration →
  /// Redirect URLs) and handled by the platform (Android intent filter /
  /// iOS URL scheme).
  static const String passwordResetRedirect =
      'io.budgetiq.app://reset-callback';

  /// Google OAuth **Web** client ID (from Google Cloud Console → Credentials).
  ///
  /// Used as `serverClientId` for the native Google sign-in flow on both
  /// Android and iOS: it is the audience Supabase validates the returned Google
  /// ID token against, so it must also be registered in the Supabase dashboard
  /// (Authentication → Providers → Google → Client IDs).
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  /// Google OAuth **iOS** client ID. Required on iOS only; Android resolves its
  /// client from the package name + signing certificate fingerprint.
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  /// Whether Google sign-in was configured at build time. When false the app
  /// hides the Google button rather than failing at tap time.
  static bool get hasGoogleSignIn => googleWebClientId.isNotEmpty;

  /// Optional Sentry DSN, injected via `--dart-define=SENTRY_DSN=...`. When
  /// empty, crash reporting stays disabled (errors just log to the console).
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get hasSentry => sentryDsn.isNotEmpty;
}
