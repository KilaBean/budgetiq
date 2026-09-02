import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sentry/sentry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/cache/cache_box.dart';
import 'core/cache/cache_encryption.dart';
import 'core/cache/cache_migration.dart';
import 'core/config/app_config.dart';
import 'core/error/app_error_view.dart';
import 'core/notifications/notification_service.dart';
import 'core/observability/app_logger.dart';

/// Narrowly matches the debug-only flutter_riverpod ticker-mode re-entrancy so
/// it can be ignored without masking real build errors.
bool _isBenignRiverpodTickerAssertion(FlutterErrorDetails details) {
  final message = details.exceptionAsString();
  final stack = details.stack?.toString() ?? '';
  return message.contains('called during build') &&
      stack.contains('_updateTickerMode') &&
      stack.contains('scheduleRefresh');
}

/// Opens the encrypted cache box and migrates the pre-encryption box into it.
///
/// If the box cannot be decrypted — the only realistic cause is the keystore
/// entry being lost (device restore, secure-storage reset) — it is recreated
/// empty rather than leaving the app unable to start. The box is a cache, so
/// the cost is a refetch.
Future<void> _openCacheBox() async {
  final cipher = await CacheEncryption.platform().cipher();
  Box<dynamic> box;
  try {
    box = await Hive.openBox<dynamic>(kCacheBoxName, encryptionCipher: cipher);
  } catch (e, st) {
    AppLogger.error(e, stackTrace: st, context: 'cache-open');
    await Hive.deleteBoxFromDisk(kCacheBoxName);
    box = await Hive.openBox<dynamic>(kCacheBoxName, encryptionCipher: cipher);
  }
  await migrateLegacyCache(box);
}

Future<void> main() async {
  // Render a friendly fallback instead of the red error screen on build errors.
  ErrorWidget.builder = (details) {
    AppLogger.error(
      details.exception,
      stackTrace: details.stack,
      context: 'widget',
    );
    return const AppErrorView();
  };

  // Route framework errors through the logger (seam for a crash reporter).
  FlutterError.onError = (details) {
    // Known-benign flutter_riverpod 3.x re-entrancy: when a route transition
    // toggles TickerMode, ConsumerStatefulElement resumes provider
    // subscriptions during build and a watched provider self-invalidates,
    // tripping a debug-only assertion. It does not occur in release builds, so
    // swallow this specific case rather than spamming the reporter / red screen.
    if (_isBenignRiverpodTickerAssertion(details)) return;
    FlutterError.presentError(details);
    AppLogger.error(
      details.exception,
      stackTrace: details.stack,
      context: 'flutter',
    );
  };

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Hive.initFlutter();
      await _openCacheBox();

      await NotificationService.instance.init();

      if (!AppConfig.hasSupabaseCredentials) {
        throw StateError(
          'Missing Supabase credentials. Run with:\n'
          '  flutter run --dart-define=SUPABASE_URL=... '
          '--dart-define=SUPABASE_ANON_KEY=...',
        );
      }

      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: AppConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      const app = ProviderScope(child: BudgetIqApp());

      // Crash reporting runs in release/profile only — in debug you have the
      // console, and debug-only framework assertions (e.g. Flutter's
      // markNeedsBuild-during-build checks) would otherwise flood the dashboard.
      if (AppConfig.hasSentry && !kDebugMode) {
        await Sentry.init((options) {
          options.dsn = AppConfig.sentryDsn;
          options.environment = kReleaseMode ? 'production' : 'profile';
          options.tracesSampleRate = 0.2;
        });
        AppLogger.reporter = (error, stack) =>
            Sentry.captureException(error, stackTrace: stack);
      }
      runApp(app);
    },
    (error, stack) {
      // Catches uncaught async errors outside the Flutter framework.
      AppLogger.error(error, stackTrace: stack, context: 'zone', fatal: true);
    },
  );
}
