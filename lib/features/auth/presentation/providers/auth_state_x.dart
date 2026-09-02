import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_providers.dart';

part 'auth_state_x.g.dart';

/// The signed-in user's email, or `null` if unavailable.
///
/// Convenience selector derived from [authStateProvider] so widgets can read a
/// single value without unpacking the full [AsyncValue].
@riverpod
String? currentUserEmail(Ref ref) {
  return ref.watch(authStateProvider).value?.email;
}
