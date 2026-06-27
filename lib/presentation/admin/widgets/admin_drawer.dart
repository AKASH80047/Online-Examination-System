import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    Widget buildTile(String title, IconData icon, String path) {
      final isSelected = location == path || (path != RoutePaths.adminDashboard && location.startsWith(path));
      return ListTile(
        leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        selected: isSelected,
        onTap: () {
          Navigator.pop(context);
          if (location != path) {
            context.go(path);
          }
        },
      );
    }

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Admin Portal',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildTile('Dashboard', Icons.dashboard_outlined, RoutePaths.adminDashboard),
                buildTile('Manage Exams', Icons.quiz_outlined, RoutePaths.adminExamList),
                buildTile('Manage Users', Icons.people_outline, RoutePaths.adminUserList),
                buildTile('Exam Results', Icons.grade_outlined, RoutePaths.adminResults),
                buildTile('Push Notifications', Icons.notifications_none_outlined, RoutePaths.adminSendNotification),
                buildTile('Platform Analytics', Icons.analytics_outlined, RoutePaths.adminAnalytics),
                buildTile('System Settings', Icons.settings_outlined, RoutePaths.adminSettings),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('Back to Home', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              context.go(RoutePaths.login);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
