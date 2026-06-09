import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/auth_providers.dart';
import 'package:exam_paper/app_constants.dart';

class AdminAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeading;

  const AdminAppBar({
    super.key,
    required this.title,
    this.showLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: showLeading,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        // On desktop (no back button), show the logo as the leading widget
        leading: !showLeading
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 18),
                ),
              )
            : null,
        // Title is just plain Text — never overflows
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Badge(
              backgroundColor: const Color(0xFFEF4444),
              smallSize: 8,
              child: const Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
            ),
            onPressed: () => context.push(RoutePaths.adminNotificationHistory),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 4),
          _AdminProfileMenu(),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AdminProfileMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 13,
              backgroundColor: Color(0xFF4F46E5),
              child: Icon(Icons.person, color: Colors.white, size: 15),
            ),
            if (isWide) ...[
              const SizedBox(width: 7),
              const Text(
                'Admin',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(Icons.expand_more, size: 15, color: Color(0xFF6B7280)),
            ],
          ],
        ),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          await ref.read(authRepositoryProvider).signOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin User',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const Text(
                'admin@examportal.com',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 18, color: Color(0xFF6B7280)),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
    );
  }
}
