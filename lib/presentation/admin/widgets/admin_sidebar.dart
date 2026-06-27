import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    Widget buildTile(String title, IconData icon, String path) {
      final isSelected = location == path || (path != RoutePaths.adminDashboard && location.startsWith(path));
      return Card(
        elevation: 0,
        color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4) : Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          dense: true,
          leading: Icon(
            icon,
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          selected: isSelected,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onTap: () {
            if (location != path) {
              context.go(path);
            }
          },
        ),
      );
    }

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ExamPaper',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Admin Dashboard',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                dense: true,
                leading: Icon(Icons.exit_to_app, color: Theme.of(context).colorScheme.error),
                title: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => context.go(RoutePaths.login),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
