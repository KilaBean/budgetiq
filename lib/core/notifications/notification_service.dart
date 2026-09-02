import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../observability/app_logger.dart';

/// Wraps [FlutterLocalNotificationsPlugin] for budget/goal alerts and the daily
/// reminder. Initialized once in `main()`; safe to call before permission is
/// granted (the OS simply drops notifications until allowed).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const String _alertsChannelId = 'budget_alerts';
  static const String _reminderChannelId = 'daily_reminder';
  static const int _reminderId = 1001;

  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e, st) {
      AppLogger.error(e, stackTrace: st, context: 'tz-init');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    final android_ = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android_?.createNotificationChannel(
      const AndroidNotificationChannel(
        _alertsChannelId,
        'Budget & goal alerts',
        description: 'Over-budget warnings and goal milestones',
        importance: Importance.high,
      ),
    );
    await android_?.createNotificationChannel(
      const AndroidNotificationChannel(
        _reminderChannelId,
        'Daily reminder',
        description: 'Reminder to log your spending',
      ),
    );
    _ready = true;
  }

  /// Requests OS notification permission (Android 13+, iOS). Returns whether
  /// granted.
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final granted =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? true;
  }

  Future<void> showAlert({
    required int id,
    required String title,
    required String body,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _alertsChannelId,
          'Budget & goal alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await cancelDailyReminder();
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'BudgetIQ',
      body: "Don't forget to log today's spending.",
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          'Daily reminder',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    );
  }

  Future<void> cancelDailyReminder() => _plugin.cancel(id: _reminderId);

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
