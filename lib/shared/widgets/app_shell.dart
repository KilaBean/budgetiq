import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/presentation/widgets/notification_watcher.dart';
import '../../features/sync/presentation/widgets/sync_banner.dart';

/// Bottom-navigation shell hosting the primary app sections.
///
/// Uses [StatefulNavigationShell] so each branch keeps its own navigation
/// stack and state across tab switches.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.trending_up_outlined),
      selectedIcon: Icon(Icons.trending_up),
      label: 'Income',
    ),
    NavigationDestination(
      icon: Icon(Icons.trending_down_outlined),
      selectedIcon: Icon(Icons.trending_down),
      label: 'Expenses',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet),
      label: 'Budgets',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag),
      label: 'Goals',
    ),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops to that branch's root.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const NotificationWatcher(),
          const SyncBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: _destinations,
      ),
    );
  }
}
