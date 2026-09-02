import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/network/connectivity_provider.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/profile_local_data_source.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(
    remote: ProfileRemoteDataSource(ref.watch(supabaseClientProvider)),
    local: ProfileLocalDataSource(ref.watch(jsonListCacheProvider)),
    isOnline: () => ref.read(isOnlineProvider),
  );
}

/// The current user's profile.
@Riverpod(keepAlive: true)
class CurrentProfile extends _$CurrentProfile {
  @override
  Future<Profile> build() => ref.watch(profileRepositoryProvider).getProfile();

  Future<void> setCurrency(String currencyCode) async {
    await ref.read(profileRepositoryProvider).updateCurrency(currencyCode);
    ref.invalidateSelf();
    await future;
  }
}

/// The active currency code for money entry/formatting. Defaults to USD until
/// the profile resolves, so forms always have a sensible value.
@Riverpod(keepAlive: true)
String currencyCode(Ref ref) {
  return ref.watch(currentProfileProvider).value?.currencyCode ?? 'USD';
}
