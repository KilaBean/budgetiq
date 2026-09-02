import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts a [Stream] into a [Listenable] so GoRouter can re-run its redirect
/// logic whenever the stream emits (e.g. on auth state changes).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
