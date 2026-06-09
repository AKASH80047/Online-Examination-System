import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/user_providers.dart';
import 'package:exam_paper/user_entity.dart';
import 'package:exam_paper/user_model.dart';

class UserPerformanceScreen extends ConsumerWidget {
  final String uid;
  const UserPerformanceScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
      ),
      body: usersAsync.when(
        data: (users) {
          final user = users.firstWhere(
            (u) => u.uid == uid,
            orElse: () => UserModel(uid: uid, email: 'unknown@email.com', name: 'Unknown User', role: UserRole.user),
          );

          // Mock performance data
          final examAttempts = [
            _AttemptItem(title: 'Science Quiz 101', date: 'June 03, 2026', score: 85, passed: true),
            _AttemptItem(title: 'Math Foundations', date: 'May 28, 2026', score: 72, passed: true),
            _AttemptItem(title: 'Python Development', date: 'May 15, 2026', score: 45, passed: false),
          ];

          final certificates = [
            'Science Quiz 101 Certificate',
            'Math Foundations Certificate',
          ];

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name}\'s Performance Summary',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat(context, 'Attempts', '3'),
                          _buildSummaryStat(context, 'Avg Score', '67.3%'),
                          _buildSummaryStat(context, 'Pass Rate', '66.7%'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Exam Attempts History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: examAttempts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final attempt = examAttempts[index];
                    return ListTile(
                      title: Text(attempt.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(attempt.date),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: attempt.passed ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${attempt.score}%',
                              style: TextStyle(
                                color: attempt.passed ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            attempt.passed ? Icons.check_circle_outline : Icons.cancel_outlined,
                            color: attempt.passed ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Earned Certificates',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (certificates.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(child: Text('No certificates earned yet.')),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: certificates.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.workspace_premium, color: Colors.orangeAccent),
                        title: Text(certificates[index]),
                        subtitle: const Text('ID: CERT-2026-X8392'),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_outlined, color: Colors.blue),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Generating certificate PDF download...')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _AttemptItem {
  final String title;
  final String date;
  final int score;
  final bool passed;

  _AttemptItem({
    required this.title,
    required this.date,
    required this.score,
    required this.passed,
  });
}
