import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final analyticsAsync = ref.watch(adminAnalyticsProvider);

    Widget buildBody() {
      return analyticsAsync.when(
        data: (stats) => ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const Text(
              'Platform Analytics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Overview of platform performance and activity.',
              style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),

            // Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final statCards = [
                  _StatCard(
                    title: 'Total Users',
                    value: stats.totalUsers.toString(),
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF4F46E5),
                    subtitle: 'Registered accounts',
                  ),
                  _StatCard(
                    title: 'Total Exams',
                    value: stats.totalExams.toString(),
                    icon: Icons.quiz_rounded,
                    color: const Color(0xFF10B981),
                    subtitle: 'Created exams',
                  ),
                  _StatCard(
                    title: 'Avg. Score',
                    value: '${stats.averageScore}%',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF8B5CF6),
                    subtitle: 'Platform average',
                  ),
                  _StatCard(
                    title: 'Submissions',
                    value: stats.totalResults.toString(),
                    icon: Icons.assignment_turned_in_rounded,
                    color: const Color(0xFFF59E0B),
                    subtitle: 'Total attempts',
                  ),
                ];

                // Mobile: vertical stack, no aspect ratio constraint
                if (w <= 500) {
                  return Column(
                    children: statCards
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: c,
                            ))
                        .toList(),
                  );
                }

                final cols = w > 800 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: w > 800 ? 2.0 : 2.5,
                  children: statCards,
                );
              },
            ),

            const SizedBox(height: 32),

            // Subject Performance
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subject Performance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Average scores per subject area',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  _SubjectBar(subject: 'Mathematics', score: 74, color: const Color(0xFF4F46E5)),
                  _SubjectBar(subject: 'Physics', score: 68, color: const Color(0xFF8B5CF6)),
                  _SubjectBar(subject: 'Computer Science', score: 82, color: const Color(0xFF10B981)),
                  _SubjectBar(subject: 'Chemistry', score: 61, color: const Color(0xFFF59E0B)),
                  _SubjectBar(subject: 'Biology', score: 77, color: const Color(0xFFEF4444)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Activity Metrics
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Metrics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 20),
                  _MetricRow(icon: Icons.check_circle_outline, color: Colors.green, label: 'Pass Rate', value: '78.5%'),
                  _MetricRow(icon: Icons.timer_outlined, color: Colors.blue, label: 'Avg. Completion Time', value: '42 mins'),
                  _MetricRow(icon: Icons.repeat, color: Colors.purple, label: 'Retake Rate', value: '23%'),
                  _MetricRow(icon: Icons.emoji_events_outlined, color: Colors.amber, label: 'Top Score', value: '98%'),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
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
                appBar: const AdminAppBar(title: 'Analytics', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const AdminAppBar(title: 'Analytics'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    height: 1.1,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectBar extends StatelessWidget {
  final String subject;
  final int score;
  final Color color;
  const _SubjectBar({required this.subject, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
              Text('$score%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _MetricRow({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
          ),
        ],
      ),
    );
  }
}
