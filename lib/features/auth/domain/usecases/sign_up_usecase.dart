import '../../../../core/error/failure.dart';
import '../../../../core/validation/auth_validators.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Registers a new user with email + password, validating input first.
class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({required String email, required String password}) {
    final emailError = AuthValidators.email(email);
    if (emailError != null) throw ValidationFailure(emailError);
    final passwordError = AuthValidators.password(password);
    if (passwordError != null) throw ValidationFailure(passwordError);
    return _repository.signUp(email: email.trim(), password: password);
  }
}
