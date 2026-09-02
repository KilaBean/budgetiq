import '../../../../core/error/failure.dart';
import '../../../../core/validation/auth_validators.dart';
import '../repositories/auth_repository.dart';

/// Sends a password-reset email, validating the address first.
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) {
    final emailError = AuthValidators.email(email);
    if (emailError != null) throw ValidationFailure(emailError);
    return _repository.sendPasswordReset(email.trim());
  }
}
