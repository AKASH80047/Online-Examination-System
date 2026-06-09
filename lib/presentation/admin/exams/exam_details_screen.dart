import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_stat_card.dart';

class ExamDetailsScreen extends ConsumerWidget {
  final String examId;
  const ExamDetailsScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examAsync = ref.watch(examDetailProvider(examId));
    final questionsAsync = ref.watch(examQuestionsProvider(examId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
              RoutePaths.adminEditExam.replaceAll(':examId', examId),
            ),
          ),
        ],
      ),
      body: examAsync.when(
        data: (exam) {
          final questionsCount = questionsAsync.valueOrNull?.length ?? 0;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: exam.isPublished ? Colors.green.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exam.isPublished ? 'Published' : 'Draft',
                              style: TextStyle(
                                color: exam.isPublished ? Colors.green : Colors.amber[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            'Exam ID: ${exam.id}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        exam.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exam.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final statCards = [
                    AdminStatCard(
                      title: 'Duration',
                      value: '${exam.durationMinutes} mins',
                      icon: Icons.timer_outlined,
                      color: Colors.blue,
                    ),
                    AdminStatCard(
                      title: 'Passing Score',
                      value: '${exam.passingPercentage}%',
                      icon: Icons.school_outlined,
                      color: Colors.green,
                    ),
                    AdminStatCard(
                      title: 'Questions Count',
                      value: questionsCount.toString(),
                      icon: Icons.question_answer_outlined,
                      color: Colors.purple,
                    ),
                  ];

                  if (constraints.maxWidth <= 600) {
                    return Column(
                      children: statCards
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: c,
                              ))
                          .toList(),
                    );
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.8,
                    children: statCards,
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        RoutePaths.adminQuestionList.replaceAll(':examId', examId),
                      ),
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Manage Questions'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(
                        RoutePaths.adminLeaderboard.replaceAll(':examId', examId),
                      ),
                      icon: const Icon(Icons.leaderboard_outlined),
                      label: const Text('View Leaderboard'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Additional actions
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Exam Settings & Mode'),
                      subtitle: Text(
                        exam.instantFeedback
                            ? 'Instant Feedback (Users see score immediately)'
                            : 'Delayed Results (Review before publishing scores)',
                      ),
                      trailing: Icon(
                        exam.instantFeedback ? Icons.feedback_outlined : Icons.timer_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Publish / Unpublish Exam'),
                      subtitle: Text(
                        exam.isPublished
                            ? 'Exam is visible to users on their dashboard'
                            : 'Exam is in draft mode and hidden from users',
                      ),
                      trailing: Switch(
                        value: exam.isPublished,
                        onChanged: (val) async {
                          final updated = exam.copyWith(isPublished: val);
                          await ref.read(examRepositoryProvider).updateExam(updated);
                          ref.invalidate(examDetailProvider(examId));
                          ref.invalidate(allExamsProvider);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
