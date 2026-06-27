import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/auth_providers.dart';

class AdminAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeading;
  final List<Widget>? extraActions;

  const AdminAppBar({
    super.key,
    required this.title,
    this.showLeading = true,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      leading: showLeading
          ? Builder(
              builder: (context) {
                final isDrawer = Scaffold.of(context).hasDrawer;
                if (isDrawer) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          : null,
      actions: [
        if (extraActions != null) ...extraActions!,
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined),
          onPressed: () => context.push(RoutePaths.adminNotificationHistory),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          offset: const Offset(0, 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'A',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          onSelected: (val) {
            if (val == 'settings') {
              context.go(RoutePaths.adminSettings);
            } else if (val == 'logout') {
              ref.read(authRepositoryProvider).signOut();
              context.go(RoutePaths.login);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Admin User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'admin@exampaper.com',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
