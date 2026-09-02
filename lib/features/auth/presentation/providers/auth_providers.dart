import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/google_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

part 'auth_providers.g.dart';

/// Single Google client for the process — it caches the initialization and the
/// selected account, so it must not be rebuilt per use.
@Riverpod(keepAlive: true)
GoogleAuthDataSource googleAuthDataSource(Ref ref) => GoogleAuthDataSource();

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(
    AuthRemoteDataSource(client),
    ref.watch(googleAuthDataSourceProvider),
  );
}

@Riverpod(keepAlive: true)
SignInUseCase signInUseCase(Ref ref) =>
    SignInUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignInWithGoogleUseCase signInWithGoogleUseCase(Ref ref) =>
    SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
SignUpUseCase signUpUseCase(Ref ref) =>
    SignUpUseCase(ref.watch(authRepositoryProvider));

@Riverpod(keepAlive: true)
ResetPasswordUseCase resetPasswordUseCase(Ref ref) =>
    ResetPasswordUseCase(ref.watch(authRepositoryProvider));

/// Reactive auth state: emits the signed-in [AppUser] or `null`.
///
/// Seeded with the synchronously-available restored session so the router
/// can make an immediate redirect decision on cold start.
@Riverpod(keepAlive: true)
Stream<AppUser?> authState(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
}

/// Raw Supabase auth events, used to detect password-recovery deep links so the
/// app can route the user to set a new password.
@Riverpod(keepAlive: true)
Stream<AuthChangeEvent> authEvents(Ref ref) {
  return ref
      .watch(supabaseClientProvider)
      .auth
      .onAuthStateChange
      .map((state) => state.event);
}
