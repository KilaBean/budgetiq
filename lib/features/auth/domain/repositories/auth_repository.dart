import '../entities/app_user.dart';

/// Contract for authentication operations.
///
/// Implementations live in the data layer. All methods throw a
/// [Failure](../../../core/error/failure.dart) on error; callers (controllers)
/// translate those into UI state.
abstract interface class AuthRepository {
  /// Emits the current [AppUser] on auth changes, or `null` when signed out.
  /// Emits the restored session immediately on subscription.
  Stream<AppUser?> authStateChanges();

  /// The currently authenticated user, or `null` if none.
  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({required String email, required String password});

  /// Signs in — or registers, on first use — via the native Google account
  /// picker. Throws a `CancelledFailure` if the user dismisses the picker.
  Future<AppUser> signInWithGoogle();

  Future<void> signOut();

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordReset(String email);

  /// Sets a new password for the user in the active recovery session.
  Future<void> updatePassword(String newPassword);

  /// Re-sends the sign-up confirmation email to [email].
  Future<void> resendConfirmation(String email);
}
