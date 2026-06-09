import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_constants.dart';

class UserMainLayout extends StatelessWidget {
  final Widget child;

  const UserMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _UserNavigationBar(
        currentRoute: GoRouterState.of(context).matchedLocation,
      ),
    );
  }
}

class _UserNavigationBar extends StatelessWidget {
  final String currentRoute;

  const _UserNavigationBar({required this.currentRoute});

  int _calculateSelectedIndex(BuildContext context) {
    if (currentRoute.startsWith(RoutePaths.userHistory)) {
      return 1;
    }
    if (currentRoute.startsWith('/profile')) { // Assume we'll add this route
      return 2;
    }
    return 0; // Default to Dashboard
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RoutePaths.userDashboard);
        break;
      case 1:
        context.go(RoutePaths.userHistory);
        break;
      case 2:
        context.go('/profile'); // Will add this route
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _calculateSelectedIndex(context),
      onDestinationSelected: (index) => _onItemTapped(index, context),
      elevation: 3,
      backgroundColor: Colors.white,
      indicatorColor: Theme.of(context).colorScheme.primaryContainer,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
