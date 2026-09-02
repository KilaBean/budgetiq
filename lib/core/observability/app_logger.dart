import 'package:flutter/foundation.dart';

/// Lightweight error/event logger with a single seam for plugging in a crash
/// reporter (e.g. Sentry/Crashlytics) later without touching call sites.
///
/// For now it logs to the debug console. To add a real reporter, implement
/// [AppLogger.report] to forward to the SDK.
class AppLogger {
  const AppLogger._();

  /// Optional sink for a crash reporter (e.g. Sentry). Wired in `main()` when a
  /// DSN is configured; left null otherwise. Keeps this class free of any
  /// reporter dependency.
  static Future<void> Function(Object error, StackTrace? stackTrace)? reporter;

  /// Records a handled or unhandled error with an optional stack trace.
  static void error(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    bool fatal = false,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[BudgetIQ${fatal ? ' FATAL' : ''}]'
        '${context == null ? '' : ' ($context)'}: $error',
      );
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
    // Forward to the crash reporter if one is configured.
    reporter?.call(error, stackTrace);
  }

  /// Records a non-error breadcrumb/event.
  static void event(String message) {
    if (kDebugMode) debugPrint('[BudgetIQ] $message');
  }
}
