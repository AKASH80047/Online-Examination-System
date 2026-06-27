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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final cardBg = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF111827) : Colors.white);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Widget buildBody() {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          // Header
          Text(
            'System Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: headingColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Manage application configuration, roles, and preferences.',
            style: TextStyle(fontSize: 15, color: subtitleColor),
          ),
          const SizedBox(height: 32),

          _SettingsSection(
            title: 'Application',
            icon: Icons.settings_applications_rounded,
            iconColor: const Color(0xFF0D9488), // Teal Theme Accent
            items: [
              _SettingsTile(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF0D9488),
                iconBg: const Color(0xFF0D9488).withValues(alpha: 0.1),
                title: 'Application Configuration',
                subtitle: 'Global variables, firebase flags, maintenance mode',
                onTap: () => context.push(RoutePaths.adminAppConfig),
              ),
              _SettingsTile(
                icon: Icons.vpn_key_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
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
                iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                title: 'Theme Mode',
                subtitle: 'Switch between light and dark display',
                trailing: Switch(
                  value: isDark,
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
                iconBg: const Color(0xFF10B981).withValues(alpha: 0.1),
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
                iconBg: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                title: 'Data Backup',
                subtitle: 'Export and backup all platform data',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFEF4444).withValues(alpha: 0.1),
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
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: subtitleColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Version 1.0.0 • ExamPortal Admin • © 2026',
                    style: TextStyle(fontSize: 13, color: subtitleColor),
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
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                appBar: const AdminAppBar(title: 'Settings', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF111827) : Colors.white);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

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
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isDark
                ? []
                : [
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
                  if (idx > 0) Divider(height: 1, indent: 68, color: borderColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final chevronColor = isDark ? const Color(0xFF64748B) : const Color(0xFF9CA3AF);

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
                    Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: headingColor)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
                  ],
                ),
              ),
              trailing ?? (onTap != null ? Icon(Icons.arrow_forward_ios, size: 14, color: chevronColor) : const SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
