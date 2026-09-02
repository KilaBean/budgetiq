import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/providers/supabase_provider.dart';

part 'onboarding_providers.g.dart';

/// Tracks whether the current user has completed first-run onboarding.
///
/// Stored locally (per user id) in the Hive cache — onboarding is a one-time UX
/// step, so it doesn't need to round-trip the backend.
@Riverpod(keepAlive: true)
class OnboardingState extends _$OnboardingState {
  static const _key = 'onboarding_done';

  String? get _userId => ref.read(supabaseClientProvider).auth.currentUser?.id;

  @override
  bool build() {
    final id = _userId;
    if (id == null) return false;
    final done = ref.read(cacheBoxProvider).get('$_key:$id');
    return done == true;
  }

  Future<void> complete() async {
    final id = _userId;
    if (id != null) {
      await ref.read(cacheBoxProvider).put('$_key:$id', true);
    }
    state = true;
  }
}
