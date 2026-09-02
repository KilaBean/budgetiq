import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cache/cache_box.dart';
import '../../../../core/notifications/notification_service.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) =>
    NotificationService.instance;

/// User notification preferences, persisted locally (device-level).
class NotificationSettings {
  const NotificationSettings({
    required this.alertsEnabled,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });

  final bool alertsEnabled;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  NotificationSettings copyWith({
    bool? alertsEnabled,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) => NotificationSettings(
    alertsEnabled: alertsEnabled ?? this.alertsEnabled,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
  );
}

@Riverpod(keepAlive: true)
class NotificationSettingsController extends _$NotificationSettingsController {
  static const _alerts = 'notif_alerts';
  static const _reminder = 'notif_reminder';
  static const _hour = 'notif_reminder_hour';
  static const _minute = 'notif_reminder_minute';

  @override
  NotificationSettings build() {
    final box = ref.read(cacheBoxProvider);
    return NotificationSettings(
      alertsEnabled: box.get(_alerts, defaultValue: true) as bool,
      reminderEnabled: box.get(_reminder, defaultValue: false) as bool,
      reminderHour: box.get(_hour, defaultValue: 20) as int,
      reminderMinute: box.get(_minute, defaultValue: 0) as int,
    );
  }

  Future<void> setAlertsEnabled(bool value) async {
    if (value) await ref.read(notificationServiceProvider).requestPermission();
    await ref.read(cacheBoxProvider).put(_alerts, value);
    state = state.copyWith(alertsEnabled: value);
  }

  Future<void> setReminder(bool enabled, {TimeOfDay? time}) async {
    final t = time ?? state.reminderTime;
    final service = ref.read(notificationServiceProvider);
    if (enabled) {
      await service.requestPermission();
      await service.scheduleDailyReminder(t.hour, t.minute);
    } else {
      await service.cancelDailyReminder();
    }
    final box = ref.read(cacheBoxProvider);
    await box.put(_reminder, enabled);
    await box.put(_hour, t.hour);
    await box.put(_minute, t.minute);
    state = state.copyWith(
      reminderEnabled: enabled,
      reminderHour: t.hour,
      reminderMinute: t.minute,
    );
  }
}

/// Durable log of already-fired alert keys so each alert notifies once.
@Riverpod(keepAlive: true)
class NotificationLog extends _$NotificationLog {
  static const _key = 'notif_fired';

  @override
  Set<String> build() {
    final raw = ref.read(cacheBoxProvider).get(_key);
    return raw is List ? raw.cast<String>().toSet() : <String>{};
  }

  bool has(String key) => state.contains(key);

  Future<void> add(String key) async {
    final next = {...state, key};
    state = next;
    await ref.read(cacheBoxProvider).put(_key, next.toList());
  }
}
