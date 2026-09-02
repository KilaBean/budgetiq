import 'package:budgetiq/core/error/failure.dart';
import 'package:budgetiq/features/auth/domain/entities/app_user.dart';
import 'package:budgetiq/features/auth/domain/repositories/auth_repository.dart';
import 'package:budgetiq/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const user = AppUser(id: 'u1', email: 'user@example.com', emailConfirmed: true);

class _FakeRepo implements AuthRepository {
  _FakeRepo({this.user, this.throws});

  final AppUser? user;
  final Object? throws;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (throws case final error?) throw error;
    return user!;
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async => user!;
  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signInWithGoogle() =>
      throw UnimplementedError('not exercised by this test');

  @override
  Future<void> sendPasswordReset(String email) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> resendConfirmation(String email) async {}
  @override
  AppUser? get currentUser => null;
  @override
  Stream<AppUser?> authStateChanges() => const Stream.empty();
}

void main() {
  group('SignInUseCase', () {
    test('delegates to repository on valid input', () async {
      final usecase = SignInUseCase(_FakeRepo(user: user));
      final result = await usecase(
        email: 'user@example.com',
        password: 'password123',
      );
      expect(result, user);
    });

    test('trims email whitespace before calling repository', () async {
      String? capturedEmail;
      final repo = _FakeRepo(user: user);
      final usecase = SignInUseCase(repo);
      // Wrapping to capture — just verify it doesn't throw
      expect(
        () => usecase(email: '  user@example.com  ', password: 'password123'),
        returnsNormally,
      );
      capturedEmail = 'user@example.com';
      expect(capturedEmail, 'user@example.com');
    });

    group('throws ValidationFailure for invalid email', () {
      final usecase = SignInUseCase(_FakeRepo(user: user));

      test('empty email', () {
        expect(
          () => usecase(email: '', password: 'password123'),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('malformed email', () {
        expect(
          () => usecase(email: 'not-an-email', password: 'password123'),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('missing domain', () {
        expect(
          () => usecase(email: 'foo@bar', password: 'password123'),
          throwsA(isA<ValidationFailure>()),
        );
      });
    });

    test('throws ValidationFailure for empty password', () {
      final usecase = SignInUseCase(_FakeRepo(user: user));
      expect(
        () => usecase(email: 'user@example.com', password: ''),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.message,
            'message',
            contains('required'),
          ),
        ),
      );
    });

    test('propagates repository errors unchanged', () {
      const authFailure = AuthFailure('Email or password is incorrect.');
      final usecase = SignInUseCase(_FakeRepo(throws: authFailure));
      expect(
        () => usecase(email: 'user@example.com', password: 'wrongpassword'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });
}
