import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/sync/sync_queue.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../domain/entities/app_user.dart';
import 'auth_providers.dart';

part 'auth_controller.g.dart';

/// Drives auth mutations (sign in / up / out / reset) and exposes their
/// progress as an [AsyncValue].
///
/// The UI watches this controller for loading/error feedback, while reactive
/// session state (who is logged in) comes from [authStateProvider]. Errors are
/// normalized to a user-facing message via [Failure].
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Idle until the user triggers an action.
  }

  Future<bool> signIn({required String email, required String password}) =>
      _run(
        () => ref
            .read(signInUseCaseProvider)
            .call(email: email, password: password),
      );

  /// Registers a user. Returns the created [AppUser] on success (whose
  /// [AppUser.emailConfirmed] indicates whether confirmation is still needed),
  /// or `null` on failure (with the error reflected in [state]).
  Future<AppUser?> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(signUpUseCaseProvider)
          .call(email: email, password: password),
    );
    state = result.hasError
        ? AsyncError(result.error!, result.stackTrace ?? StackTrace.current)
        : const AsyncData(null);
    return result.value;
  }

  /// Signs in (or registers) with Google.
  ///
  /// Returns `true` when a session was established. Dismissing the account
  /// picker is not a failure: state returns to idle so no error banner shows.
  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(signInWithGoogleUseCaseProvider).call(),
    );
    if (result.error is CancelledFailure) {
      state = const AsyncData(null);
      return false;
    }
    state = result.hasError
        ? AsyncError(result.error!, result.stackTrace ?? StackTrace.current)
        : const AsyncData(null);
    return !result.hasError;
  }

  Future<bool> sendPasswordReset(String email) =>
      _run(() => ref.read(resetPasswordUseCaseProvider).call(email));

  Future<bool> updatePassword(String newPassword) =>
      _run(() => ref.read(authRepositoryProvider).updatePassword(newPassword));

  Future<bool> resendConfirmation(String email) =>
      _run(() => ref.read(authRepositoryProvider).resendConfirmation(email));

  /// Signs out and purges this user's cached financial data from the device.
  ///
  /// Cache entries are namespaced per user, so a purge failure cannot expose
  /// them to the next account — but leaving them on disk after an explicit sign
  /// out would still be wrong, so the purge runs on the way out.
  ///
  /// Writes that never reached the server are the one exception: destroying
  /// them would silently lose the user's data, so the outbox is preserved and
  /// drains when they sign back in.
  Future<bool> signOut() async {
    final userId = ref.read(authRepositoryProvider).currentUser?.id;
    final queue = ref.read(syncQueueProvider);
    final unsent = queue.isNotEmpty || queue.deadLetterCount > 0;

    final ok = await _run(() => ref.read(authRepositoryProvider).signOut());
    if (ok) {
      await ref
          .read(cacheMaintenanceProvider)
          .clearUserScope(
            userId,
            preserve: unsent
                ? const {SyncQueue.queueKey, SyncQueue.deadLetterKey}
                : const {},
          );
    }
    return ok;
  }

  /// Runs [action], reflecting progress in [state]. Returns `true` on success.
  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    state = result;
    return !result.hasError;
  }
}
