import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_error_mapper.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/google_auth_datasource.dart';

/// [AuthRepository] backed by Supabase.
///
/// Translates Supabase [AuthException]s and unexpected errors into domain
/// [Failure]s, and maps Supabase `User` into [AppUser].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, [GoogleAuthDataSource? googleDataSource])
    : _googleDataSource = googleDataSource ?? _lazyGoogle();

  final AuthRemoteDataSource _dataSource;
  final GoogleAuthDataSource _googleDataSource;

  /// Constructing the wrapper touches no platform channels, so the default is
  /// safe even in builds where Google sign-in is never used.
  static GoogleAuthDataSource _lazyGoogle() => GoogleAuthDataSource();

  @override
  AppUser? get currentUser => _mapNullable(_dataSource.currentUser);

  @override
  Stream<AppUser?> authStateChanges() {
    return _dataSource.onAuthStateChange.map(
      (state) => _mapNullable(state.session?.user),
    );
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return _guard(() async {
      final user = await _dataSource.signIn(email: email, password: password);
      return _map(user);
    });
  }

  @override
  Future<AppUser> signUp({required String email, required String password}) {
    return _guard(() async {
      final user = await _dataSource.signUp(email: email, password: password);
      return _map(user);
    });
  }

  @override
  Future<AppUser> signInWithGoogle() {
    return _guard(() async {
      final credentials = await _googleDataSource.authenticate();
      final user = await _dataSource.signInWithGoogleIdToken(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
      return _map(user);
    });
  }

  @override
  Future<void> signOut() => _guard(() async {
    // Clear the cached Google account too, otherwise the next sign-in
    // silently reuses it instead of showing the picker.
    await _googleDataSource.signOut();
    await _dataSource.signOut();
  });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _dataSource.sendPasswordReset(email));

  @override
  Future<void> updatePassword(String newPassword) =>
      _guard(() => _dataSource.updatePassword(newPassword));

  @override
  Future<void> resendConfirmation(String email) =>
      _guard(() => _dataSource.resendConfirmation(email));

  // --- helpers -------------------------------------------------------------

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on GoogleAuthException catch (e) {
      throw e.cancelled ? const CancelledFailure() : AuthFailure(e.message);
    } on AuthException catch (e) {
      throw AuthFailure(mapAuthError(e));
    } on PostgrestException catch (e) {
      throw NetworkFailure(e.message);
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }

  AppUser _map(User user) => AppUser(
    id: user.id,
    email: user.email ?? '',
    emailConfirmed: user.emailConfirmedAt != null,
  );

  AppUser? _mapNullable(User? user) => user == null ? null : _map(user);
}
