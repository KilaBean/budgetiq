import 'package:budgetiq/core/error/failure.dart';
import 'package:budgetiq/features/auth/domain/entities/app_user.dart';
import 'package:budgetiq/features/auth/domain/repositories/auth_repository.dart';
import 'package:budgetiq/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements AuthRepository {
  _FakeRepo({this.throws});

  final Object? throws;
  String? lastResetEmail;

  @override
  Future<void> sendPasswordReset(String email) async {
    if (throws case final error?) throw error;
    lastResetEmail = email;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async => throw UnimplementedError();
  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async => throw UnimplementedError();
  @override
  Future<void> signOut() async {}

  @override
  Future<AppUser> signInWithGoogle() =>
      throw UnimplementedError('not exercised by this test');

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
  group('ResetPasswordUseCase', () {
    test('calls repository with trimmed email on valid input', () async {
      final repo = _FakeRepo();
      final usecase = ResetPasswordUseCase(repo);
      await usecase('  user@example.com  ');
      expect(repo.lastResetEmail, 'user@example.com');
    });

    test('throws ValidationFailure for empty email', () {
      final usecase = ResetPasswordUseCase(_FakeRepo());
      expect(() => usecase(''), throwsA(isA<ValidationFailure>()));
    });

    test('throws ValidationFailure for malformed email', () {
      final usecase = ResetPasswordUseCase(_FakeRepo());
      expect(() => usecase('not-valid'), throwsA(isA<ValidationFailure>()));
    });

    test('propagates repository errors unchanged', () {
      const networkFailure = NetworkFailure('No internet connection.');
      final usecase = ResetPasswordUseCase(_FakeRepo(throws: networkFailure));
      expect(() => usecase('user@example.com'), throwsA(isA<NetworkFailure>()));
    });

    test('completes without error on valid email when repository succeeds', () {
      final usecase = ResetPasswordUseCase(_FakeRepo());
      expect(() => usecase('user@example.com'), returnsNormally);
    });
  });
}
