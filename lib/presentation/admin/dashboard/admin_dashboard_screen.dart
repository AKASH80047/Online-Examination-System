import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';
import 'package:exam_paper/presentation/admin/dashboard/widgets/dashboard_chart.dart';
import 'package:exam_paper/presentation/admin/dashboard/widgets/recent_activity_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    final examsAsync = ref.watch(allExamsProvider);

    Widget buildDashboardContent(int examsCount) {
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allExamsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            const Text(
              'Welcome back, Admin 👋',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here is what is happening with your exams today.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),
            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final gridWidth = constraints.maxWidth;

                final cards = [
                  _buildPremiumStatCard(
                    title: 'Total Exams',
                    value: examsCount.toString(),
                    icon: Icons.quiz_rounded,
                    color: const Color(0xFF4F46E5),
                    trend: '+12% this week',
                  ),
                  _buildPremiumStatCard(
                    title: 'Active Students',
                    value: '142',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF10B981),
                    trend: '+8% this week',
                  ),
                  _buildPremiumStatCard(
                    title: 'Avg. Pass Rate',
                    value: '78.5%',
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFF8B5CF6),
                    trend: '+2.4% this month',
                  ),
                  _buildPremiumStatCard(
                    title: 'Pending Reviews',
                    value: '5',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFF59E0B),
                    trend: 'Requires attention',
                  ),
                ];

                // On mobile, stack vertically — no aspect ratio constraints
                if (gridWidth <= 600) {
                  return Column(
                    children: cards
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: c,
                            ))
                        .toList(),
                  );
                }

                // On desktop/tablet, 2 or 4 column grid
                final crossAxisCount = gridWidth > 1200 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: gridWidth > 1200 ? 2.2 : 2.8,
                  children: cards,
                );
              },
            ),
            const SizedBox(height: 32),
            // Charts and Activity split or stack
            if (width > 1100)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: DashboardChart()),
                  SizedBox(width: 24),
                  Expanded(flex: 2, child: RecentActivityCard()),
                ],
              )
            else ...[
              const DashboardChart(),
              const SizedBox(height: 32),
              const RecentActivityCard(),
            ],
          ],
        ),
      );
    }

    final body = examsAsync.when(
      data: (exams) => buildDashboardContent(exams.length),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Failed to load dashboard data: $err'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(allExamsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFFF9FAFB),
                appBar: const AdminAppBar(title: 'Admin Dashboard', showLeading: false),
                body: body,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const AdminAppBar(title: 'Admin Dashboard'),
      drawer: const AdminDrawer(),
      body: body,
    );
  }

  Widget _buildPremiumStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}