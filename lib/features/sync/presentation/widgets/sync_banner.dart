import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_provider.dart';
import '../providers/sync_providers.dart';

/// Thin status strip shown when the device is offline or there are unsynced
/// changes. Animates in/out so it doesn't jar the layout.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityStatusProvider).value ?? true;
    final status = ref.watch(syncControllerProvider);
    final theme = Theme.of(context);

    final ({String text, IconData icon, Color bg, Color fg})? banner;
    // Rejected changes outrank everything else: the user thinks they saved
    // something that never reached the server.
    if (status.hasFailures) {
      banner = (
        text:
            '${status.failed} change${status.failed == 1 ? " couldn't" : "s couldn't"} '
            'be saved — tap to dismiss',
        icon: Icons.error_outline,
        bg: theme.colorScheme.errorContainer,
        fg: theme.colorScheme.onErrorContainer,
      );
    } else if (!online) {
      banner = (
        text: 'Offline — changes will sync when you reconnect',
        icon: Icons.cloud_off,
        bg: theme.colorScheme.secondaryContainer,
        fg: theme.colorScheme.onSecondaryContainer,
      );
    } else if (status.isSyncing) {
      banner = (
        text: 'Syncing…',
        icon: Icons.sync,
        bg: theme.colorScheme.primaryContainer,
        fg: theme.colorScheme.onPrimaryContainer,
      );
    } else if (status.hasPending) {
      banner = (
        text:
            '${status.pending} change${status.pending == 1 ? '' : 's'} pending — tap to sync',
        icon: Icons.cloud_queue,
        bg: theme.colorScheme.secondaryContainer,
        fg: theme.colorScheme.onSecondaryContainer,
      );
    } else {
      banner = null;
    }

    // Tapping retries the sync (useful if an auto-sync stalled on reconnect),
    // or acknowledges rejected changes.
    final canTapToSync = online && status.hasPending && !status.isSyncing;
    final controller = ref.read(syncControllerProvider.notifier);
    final VoidCallback? onTap = status.hasFailures
        ? () => unawaited(controller.dismissFailures())
        : canTapToSync
        ? () => unawaited(controller.sync())
        : null;
    final trailingIcon = status.hasFailures
        ? Icons.close
        : canTapToSync
        ? Icons.refresh
        : null;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: banner == null
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              container: true,
              button: onTap != null,
              label: banner.text,
              child: Material(
                color: banner.bg,
                child: InkWell(
                  onTap: onTap,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(banner.icon, size: 16, color: banner.fg),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              banner.text,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: banner.fg,
                              ),
                            ),
                          ),
                          if (trailingIcon != null)
                            Icon(trailingIcon, size: 16, color: banner.fg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
