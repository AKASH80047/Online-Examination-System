import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    Widget buildBody() {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          // Header
          const Text(
            'System Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage application configuration, roles, and preferences.',
            style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 32),

          _SettingsSection(
            title: 'Application',
            icon: Icons.settings_applications_rounded,
            iconColor: const Color(0xFF4F46E5),
            items: [
              _SettingsTile(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF4F46E5),
                iconBg: const Color(0xFFEEF2FF),
                title: 'Application Configuration',
                subtitle: 'Global variables, firebase flags, maintenance mode',
                onTap: () => context.push(RoutePaths.adminAppConfig),
              ),
              _SettingsTile(
                icon: Icons.vpn_key_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF5F3FF),
                title: 'Roles & Permissions',
                subtitle: 'User role access control list summary',
                onTap: () => context.push(RoutePaths.adminRolesPermission),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SettingsSection(
            title: 'Display',
            icon: Icons.palette_rounded,
            iconColor: const Color(0xFFF59E0B),
            items: [
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
                title: 'Theme Mode',
                subtitle: 'Switch between light and dark display',
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Theme: ${val ? 'Dark' : 'Light'} (requires app restart)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFD1FAE5),
                title: 'Language',
                subtitle: 'English (United States)',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SettingsSection(
            title: 'Data & Privacy',
            icon: Icons.security_rounded,
            iconColor: const Color(0xFFEF4444),
            items: [
              _SettingsTile(
                icon: Icons.backup_rounded,
                iconColor: const Color(0xFF3B82F6),
                iconBg: const Color(0xFFEFF6FF),
                title: 'Data Backup',
                subtitle: 'Export and backup all platform data',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFFEE2E2),
                title: 'Privacy Policy',
                subtitle: 'View and manage privacy settings',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF6B7280)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Version 1.0.0 • ExamPortal Admin • © 2026',
                    style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFFF9FAFB),
                appBar: const AdminAppBar(title: 'Settings', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const AdminAppBar(title: 'Settings'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_SettingsTile> items;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: iconColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (idx > 0) const Divider(height: 1, indent: 68),
                  item,
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1F2937))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)) : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
