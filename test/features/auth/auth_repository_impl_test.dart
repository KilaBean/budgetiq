import 'package:budgetiq/core/error/failure.dart';
import 'package:budgetiq/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:budgetiq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

User _user({String? confirmedAt}) => User.fromJson({
  'id': 'u1',
  'app_metadata': <String, dynamic>{},
  'user_metadata': <String, dynamic>{},
  'aud': 'authenticated',
  'created_at': DateTime(2026, 1, 1).toIso8601String(),
  'email': 'sam@example.com',
  'email_confirmed_at': confirmedAt,
})!;

class _FakeDataSource implements AuthRemoteDataSource {
  _FakeDataSource({this.onSignIn});

  User Function()? onSignIn;

  String? lastIdToken;
  String? lastAccessToken;
  bool signedOut = false;

  @override
  Future<User> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
  }) async {
    lastIdToken = idToken;
    lastAccessToken = accessToken;
    return _user(confirmedAt: DateTime(2026, 1, 2).toIso8601String());
  }

  @override
  Future<User> signIn({required String email, required String password}) async {
    final f = onSignIn;
    if (f != null) return f();
    return _user();
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
  }) async => _user();

  @override
  User? get currentUser => null;
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> resendConfirmation(String email) async {}
}

void main() {
  test('signIn maps Supabase User to AppUser', () async {
    final repo = AuthRepositoryImpl(
      _FakeDataSource(
        onSignIn: () =>
            _user(confirmedAt: DateTime(2026, 1, 2).toIso8601String()),
      ),
    );

    final user = await repo.signIn(email: 'sam@example.com', password: 'pw');
    expect(user.id, 'u1');
    expect(user.email, 'sam@example.com');
    expect(user.emailConfirmed, isTrue);
  });

  test('signUp surfaces unconfirmed users', () async {
    final repo = AuthRepositoryImpl(_FakeDataSource());
    final user = await repo.signUp(email: 'sam@example.com', password: 'pw');
    expect(user.emailConfirmed, isFalse);
  });

  test('AuthException is translated to a friendly AuthFailure', () async {
    final repo = AuthRepositoryImpl(
      _FakeDataSource(
        onSignIn: () => throw const AuthException('Invalid login credentials'),
      ),
    );

    expect(
      () => repo.signIn(email: 'x', password: 'y'),
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.message,
          'message',
          'Email or password is incorrect.',
        ),
      ),
    );
  });
}
