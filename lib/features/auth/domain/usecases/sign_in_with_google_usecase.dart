import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Signs the user in with Google, registering them on first use.
///
/// No local validation applies — Google owns the credential — so this exists to
/// keep the presentation layer talking to use cases rather than repositories.
class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() => _repository.signInWithGoogle();
}
