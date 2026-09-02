import '../../../../core/error/failure.dart';
import '../../../../core/validation/auth_validators.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Signs a user in with email + password, validating input first.
class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({required String email, required String password}) {
    final emailError = AuthValidators.email(email);
    if (emailError != null) throw ValidationFailure(emailError);
    if ((password).isEmpty) {
      throw const ValidationFailure('Password is required.');
    }
    return _repository.signIn(email: email.trim(), password: password);
  }
}
