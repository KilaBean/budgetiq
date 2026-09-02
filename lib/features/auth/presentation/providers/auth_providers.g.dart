// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single Google client for the process — it caches the initialization and the
/// selected account, so it must not be rebuilt per use.

@ProviderFor(googleAuthDataSource)
final googleAuthDataSourceProvider = GoogleAuthDataSourceProvider._();

/// Single Google client for the process — it caches the initialization and the
/// selected account, so it must not be rebuilt per use.

final class GoogleAuthDataSourceProvider
    extends
        $FunctionalProvider<
          GoogleAuthDataSource,
          GoogleAuthDataSource,
          GoogleAuthDataSource
        >
    with $Provider<GoogleAuthDataSource> {
  /// Single Google client for the process — it caches the initialization and the
  /// selected account, so it must not be rebuilt per use.
  GoogleAuthDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleAuthDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleAuthDataSourceHash();

  @$internal
  @override
  $ProviderElement<GoogleAuthDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoogleAuthDataSource create(Ref ref) {
    return googleAuthDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleAuthDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleAuthDataSource>(value),
    );
  }
}

String _$googleAuthDataSourceHash() =>
    r'9ba03463742468aa32f2c339743af33b466bd3ee';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'd7a1845ab6bc9deb4f60ff639a1aec825d472383';

@ProviderFor(signInUseCase)
final signInUseCaseProvider = SignInUseCaseProvider._();

final class SignInUseCaseProvider
    extends $FunctionalProvider<SignInUseCase, SignInUseCase, SignInUseCase>
    with $Provider<SignInUseCase> {
  SignInUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInUseCase create(Ref ref) {
    return signInUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInUseCase>(value),
    );
  }
}

String _$signInUseCaseHash() => r'27c9353707dc0ba7c68faf82a9c8f7b6d1212801';

@ProviderFor(signInWithGoogleUseCase)
final signInWithGoogleUseCaseProvider = SignInWithGoogleUseCaseProvider._();

final class SignInWithGoogleUseCaseProvider
    extends
        $FunctionalProvider<
          SignInWithGoogleUseCase,
          SignInWithGoogleUseCase,
          SignInWithGoogleUseCase
        >
    with $Provider<SignInWithGoogleUseCase> {
  SignInWithGoogleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithGoogleUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithGoogleUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignInWithGoogleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SignInWithGoogleUseCase create(Ref ref) {
    return signInWithGoogleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithGoogleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithGoogleUseCase>(value),
    );
  }
}

String _$signInWithGoogleUseCaseHash() =>
    r'990a66810ccae1d1ded7bded76694e63b0e659c9';

@ProviderFor(signUpUseCase)
final signUpUseCaseProvider = SignUpUseCaseProvider._();

final class SignUpUseCaseProvider
    extends $FunctionalProvider<SignUpUseCase, SignUpUseCase, SignUpUseCase>
    with $Provider<SignUpUseCase> {
  SignUpUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignUpUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignUpUseCase create(Ref ref) {
    return signUpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpUseCase>(value),
    );
  }
}

String _$signUpUseCaseHash() => r'252a923348273f4b6c15d15db40946366359a16a';

@ProviderFor(resetPasswordUseCase)
final resetPasswordUseCaseProvider = ResetPasswordUseCaseProvider._();

final class ResetPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ResetPasswordUseCase,
          ResetPasswordUseCase,
          ResetPasswordUseCase
        >
    with $Provider<ResetPasswordUseCase> {
  ResetPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetPasswordUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResetPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResetPasswordUseCase create(Ref ref) {
    return resetPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetPasswordUseCase>(value),
    );
  }
}

String _$resetPasswordUseCaseHash() =>
    r'be0faeedfe83b966031bcde9d535f5b93e5e8d1f';

/// Reactive auth state: emits the signed-in [AppUser] or `null`.
///
/// Seeded with the synchronously-available restored session so the router
/// can make an immediate redirect decision on cold start.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Reactive auth state: emits the signed-in [AppUser] or `null`.
///
/// Seeded with the synchronously-available restored session so the router
/// can make an immediate redirect decision on cold start.

final class AuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  /// Reactive auth state: emits the signed-in [AppUser] or `null`.
  ///
  /// Seeded with the synchronously-available restored session so the router
  /// can make an immediate redirect decision on cold start.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'9fd9e29cc984d8407bb25b6f7d66366c0c758da2';

/// Raw Supabase auth events, used to detect password-recovery deep links so the
/// app can route the user to set a new password.

@ProviderFor(authEvents)
final authEventsProvider = AuthEventsProvider._();

/// Raw Supabase auth events, used to detect password-recovery deep links so the
/// app can route the user to set a new password.

final class AuthEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthChangeEvent>,
          AuthChangeEvent,
          Stream<AuthChangeEvent>
        >
    with $FutureModifier<AuthChangeEvent>, $StreamProvider<AuthChangeEvent> {
  /// Raw Supabase auth events, used to detect password-recovery deep links so the
  /// app can route the user to set a new password.
  AuthEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authEventsHash();

  @$internal
  @override
  $StreamProviderElement<AuthChangeEvent> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AuthChangeEvent> create(Ref ref) {
    return authEvents(ref);
  }
}

String _$authEventsHash() => r'3ba737dcd8468f8cffe5105ac5dcf194b0e0ce2b';
