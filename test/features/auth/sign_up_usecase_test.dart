import 'package:budgetiq/core/error/failure.dart';
import 'package:budgetiq/features/auth/domain/entities/app_user.dart';
import 'package:budgetiq/features/auth/domain/repositories/auth_repository.dart';
import 'package:budgetiq/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

const _defaultUser = AppUser(id: 'u1', email: 'user@example.com');

class _FakeRepo implements AuthRepository {
  _FakeRepo({AppUser? user, this.throws}) : user = user ?? _defaultUser;

  final AppUser user;
  final Object? throws;

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    if (throws case final error?) throw error;
    return user;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async => user;
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
  group('SignUpUseCase', () {
    test('delegates to repository on valid input', () async {
      final usecase = SignUpUseCase(_FakeRepo());
      final result = await usecase(
        email: 'user@example.com',
        password: 'strongpass1',
      );
      expect(result, _defaultUser);
    });

    group('throws ValidationFailure for invalid email', () {
      final usecase = SignUpUseCase(_FakeRepo());

      test('empty email', () {
        expect(
          () => usecase(email: '', password: 'strongpass1'),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('malformed email', () {
        expect(
          () => usecase(email: 'notanemail', password: 'strongpass1'),
          throwsA(isA<ValidationFailure>()),
        );
      });
    });

    group('throws ValidationFailure for weak password', () {
      final usecase = SignUpUseCase(_FakeRepo());

      test('too short', () {
        expect(
          () => usecase(email: 'user@example.com', password: 'abc'),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('empty password', () {
        expect(
          () => usecase(email: 'user@example.com', password: ''),
          throwsA(isA<ValidationFailure>()),
        );
      });
    });

    test('trims email whitespace before calling repository', () {
      final usecase = SignUpUseCase(_FakeRepo());
      expect(
        () => usecase(email: '  user@example.com  ', password: 'strongpass1'),
        returnsNormally,
      );
    });

    test('propagates repository errors unchanged', () {
      const authFailure = AuthFailure('Email already registered.');
      final usecase = SignUpUseCase(_FakeRepo(throws: authFailure));
      expect(
        () => usecase(email: 'user@example.com', password: 'strongpass1'),
        throwsA(isA<AuthFailure>()),
      );
    });
  });
}
