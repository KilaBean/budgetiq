import 'package:budgetiq/core/error/failure.dart';
import 'package:budgetiq/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:budgetiq/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:budgetiq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

User _user() => User.fromJson({
  'id': 'g1',
  'app_metadata': <String, dynamic>{'provider': 'google'},
  'user_metadata': <String, dynamic>{'full_name': 'Sam Rivers'},
  'aud': 'authenticated',
  'created_at': DateTime(2026, 1, 1).toIso8601String(),
  'email': 'sam@gmail.com',
  'email_confirmed_at': DateTime(2026, 1, 1).toIso8601String(),
})!;

class _FakeAuthDataSource implements AuthRemoteDataSource {
  String? idToken;
  String? accessToken;
  bool signedOut = false;

  @override
  Future<User> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
  }) async {
    this.idToken = idToken;
    this.accessToken = accessToken;
    return _user();
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  User? get currentUser => null;
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async => _user();
  @override
  Future<User> signUp({
    required String email,
    required String password,
  }) async => _user();
  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> resendConfirmation(String email) async {}
}

class _FakeGoogle extends GoogleAuthDataSource {
  _FakeGoogle({this.credentials, this.error});

  final GoogleCredentials? credentials;
  final GoogleAuthException? error;
  bool signedOut = false;

  @override
  Future<GoogleCredentials> authenticate() async {
    final e = error;
    if (e != null) throw e;
    return credentials!;
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
  }
}

void main() {
  test('signInWithGoogle forwards Google tokens to Supabase', () async {
    final auth = _FakeAuthDataSource();
    final repo = AuthRepositoryImpl(
      auth,
      _FakeGoogle(
        credentials: const GoogleCredentials(
          idToken: 'id-token',
          accessToken: 'access-token',
        ),
      ),
    );

    final user = await repo.signInWithGoogle();

    expect(auth.idToken, 'id-token');
    expect(auth.accessToken, 'access-token');
    expect(user.id, 'g1');
    expect(user.email, 'sam@gmail.com');
    expect(user.emailConfirmed, isTrue);
  });

  test('signInWithGoogle works without an access token', () async {
    final auth = _FakeAuthDataSource();
    final repo = AuthRepositoryImpl(
      auth,
      _FakeGoogle(credentials: const GoogleCredentials(idToken: 'id-token')),
    );

    await repo.signInWithGoogle();

    expect(auth.accessToken, isNull);
  });

  test('a dismissed account picker becomes a CancelledFailure', () async {
    final repo = AuthRepositoryImpl(
      _FakeAuthDataSource(),
      _FakeGoogle(
        error: const GoogleAuthException('cancelled', cancelled: true),
      ),
    );

    expect(repo.signInWithGoogle(), throwsA(isA<CancelledFailure>()));
  });

  test('a genuine Google error becomes an AuthFailure', () async {
    final repo = AuthRepositoryImpl(
      _FakeAuthDataSource(),
      _FakeGoogle(error: const GoogleAuthException('No ID token.')),
    );

    expect(
      repo.signInWithGoogle(),
      throwsA(
        isA<AuthFailure>().having((f) => f.message, 'message', 'No ID token.'),
      ),
    );
  });

  test(
    'signOut clears the cached Google account as well as the session',
    () async {
      final auth = _FakeAuthDataSource();
      final google = _FakeGoogle();
      final repo = AuthRepositoryImpl(auth, google);

      await repo.signOut();

      expect(auth.signedOut, isTrue);
      expect(google.signedOut, isTrue);
    },
  );
}
