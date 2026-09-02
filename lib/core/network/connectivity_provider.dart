import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Emits `true` when the device has a network connection, `false` otherwise.
///
/// Used by repositories to decide between network and cached data, and by the
/// sync layer to know when it can reach Supabase.
@Riverpod(keepAlive: true)
Stream<bool> connectivityStatus(Ref ref) async* {
  final connectivity = Connectivity();
  bool isOnline(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);

  yield isOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(isOnline);
}

/// Synchronous best-effort online flag (defaults to online until the stream
/// resolves) for use inside repositories.
@Riverpod(keepAlive: true)
bool isOnline(Ref ref) => ref.watch(connectivityStatusProvider).value ?? true;
