import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/month.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../domain/alert_event.dart';
import '../providers/notification_providers.dart';

/// Invisible widget that listens for budget/goal changes and fires local
/// notifications for new alert events (once each). Mounted inside the
/// authenticated app shell.
class NotificationWatcher extends ConsumerWidget {
  const NotificationWatcher({super.key});

  void _check(WidgetRef ref) {
    if (!ref.read(notificationSettingsControllerProvider).alertsEnabled) return;

    final month = Month.current();
    final periodKey = '${month.year}-${month.month}';
    final events = buildAlertEvents(
      periodKey: periodKey,
      budget: ref.read(currentBudgetSummaryProvider),
      goals: ref.read(goalListProvider).value ?? const [],
    );

    final log = ref.read(notificationLogProvider.notifier);
    final service = ref.read(notificationServiceProvider);
    var id = 2000;
    for (final event in events) {
      if (log.has(event.key)) continue;
      service.showAlert(id: id++, title: event.title, body: event.body);
      log.add(event.key);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentBudgetSummaryProvider, (_, _) => _check(ref));
    ref.listen(goalListProvider, (_, _) => _check(ref));
    return const SizedBox.shrink();
  }
}
