import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/user_providers.dart';
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
    final usersAsync = ref.watch(allUsersProvider);

    Widget buildDashboardContent(int examsCount, int usersCount) {
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allExamsProvider);
          ref.invalidate(allUsersProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(32.0),
          children: [
            // Welcome Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Overview',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFE2E8F0)),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Monitor platform metrics, exams, and candidate enrollment.',
                        style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_person, color: Color(0xFF14B8A6), size: 16),
                      SizedBox(width: 8),
                      Text('Admin Mode', style: TextStyle(color: Color(0xFF14B8A6), fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Premium Stats Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final gridWidth = constraints.maxWidth;

                final cards = [
                  _buildStatCard('Total Exams', examsCount.toString(), Icons.assignment_outlined, const Color(0xFF0D9488), 'Configured tests'),
                  _buildStatCard('Registered Users', usersCount.toString(), Icons.people_alt_outlined, const Color(0xFF10B981), 'Student registry'),
                  _buildStatCard('Pass Rate Threshold', '75%', Icons.trending_up, const Color(0xFF8B5CF6), 'Average baseline'),
                  _buildStatCard('Pending Approvals', '0', Icons.pending_actions_outlined, const Color(0xFFF59E0B), 'Requires review'),
                ];

                if (gridWidth <= 600) {
                  return Column(
                    children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
                  );
                }

                final crossCount = gridWidth > 1200 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: gridWidth > 1200 ? 2.4 : 2.8,
                  children: cards,
                );
              },
            ),
            const SizedBox(height: 32),

            // Charts and Activity split
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
            const SizedBox(height: 32),

            // User Table Section
            _buildRecentUsersTable(context, usersAsync),
          ],
        ),
      );
    }

    final body = examsAsync.when(
      data: (exams) => usersAsync.when(
        data: (users) => buildDashboardContent(exams.length, users.length),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildErrorPane(context, err.toString(), ref),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => _buildErrorPane(context, err.toString(), ref),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0F19), // Dark Slate Navy
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFF0B0F19),
                appBar: const AdminAppBar(title: 'Admin Console', showLeading: false),
                body: body,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: const AdminAppBar(title: 'Admin Console'),
      drawer: const AdminDrawer(),
      body: body,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Slate 900
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsersTable(BuildContext context, AsyncValue<List<dynamic>> usersAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Enrollments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          usersAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return const Text('No students registered yet.', style: TextStyle(color: Color(0xFF94A3B8)));
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length > 5 ? 5 : users.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFF1E293B), height: 16),
                itemBuilder: (context, idx) {
                  final user = users[idx];
                  return Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF1E293B),
                        child: Icon(Icons.person, color: Color(0xFF14B8A6), size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(user.email, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPane(BuildContext context, String error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Failed to load dashboard: $error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(allExamsProvider);
              ref.invalidate(allUsersProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}