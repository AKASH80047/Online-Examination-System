import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/auth_providers.dart';
import 'package:exam_paper/app_constants.dart';

class AdminSidebar extends ConsumerWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Brand Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ExamPortal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Admin Console',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('MAIN'),
                  _buildNavItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: RoutePaths.adminDashboard,
                    currentLocation: currentLocation,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.quiz_rounded,
                    label: 'Manage Exams',
                    route: RoutePaths.adminExamList,
                    currentLocation: currentLocation,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.people_alt_rounded,
                    label: 'Users',
                    route: RoutePaths.adminUserList,
                    currentLocation: currentLocation,
                  ),

                  const SizedBox(height: 16),
                  _buildSectionLabel('REPORTS'),
                  _buildNavItem(
                    context,
                    icon: Icons.bar_chart_rounded,
                    label: 'Analytics',
                    route: RoutePaths.adminAnalytics,
                    currentLocation: currentLocation,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.assignment_turned_in_rounded,
                    label: 'Results',
                    route: RoutePaths.adminResults,
                    currentLocation: currentLocation,
                  ),

                  const SizedBox(height: 16),
                  _buildSectionLabel('TOOLS'),
                  _buildNavItem(
                    context,
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    route: RoutePaths.adminSendNotification,
                    currentLocation: currentLocation,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    route: RoutePaths.adminSettings,
                    currentLocation: currentLocation,
                  ),
                ],
              ),
            ),
          ),

          // Bottom user area
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Administrator',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) => IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFF9CA3AF), size: 18),
                    tooltip: 'Sign Out',
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required String currentLocation,
  }) {
    final isActive = currentLocation == route ||
        (route != RoutePaths.adminDashboard && currentLocation.startsWith(route));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF4F46E5).withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? const Color(0xFF818CF8) : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? const Color(0xFFE0E7FF) : const Color(0xFF9CA3AF),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF818CF8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
