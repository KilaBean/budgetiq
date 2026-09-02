import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Exposes the initialized [SupabaseClient].
///
/// [Supabase.initialize] must have completed in `main()` before this provider
/// is read. The data layer depends on this provider rather than referencing
/// the global singleton directly, keeping it injectable for tests.
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

/// Id of the signed-in user, or `null` when signed out.
///
/// Seeded synchronously from the restored session (Supabase populates
/// `currentUser` before emitting the auth event) and kept current from the auth
/// stream, so cache scoping switches the moment the session does.
@Riverpod(keepAlive: true)
class CurrentUserId extends _$CurrentUserId {
  @override
  String? build() {
    final client = ref.watch(supabaseClientProvider);
    final subscription = client.auth.onAuthStateChange.listen((_) {
      final next = client.auth.currentUser?.id;
      if (next != state) state = next;
    });
    ref.onDispose(subscription.cancel);
    return client.auth.currentUser?.id;
  }
}
