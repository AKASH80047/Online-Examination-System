import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class ExamListScreen extends ConsumerStatefulWidget {
  const ExamListScreen({super.key});

  @override
  ConsumerState<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends ConsumerState<ExamListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final examsAsync = ref.watch(filteredAdminExamsProvider);

    Widget buildBody() {
      return Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        ref.read(adminExamSearchQueryProvider.notifier).state = v,
                    decoration: InputDecoration(
                      hintText: 'Search by title or category...',
                      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(adminExamSearchQueryProvider.notifier).state = '';
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push(RoutePaths.adminCreateExam),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Exam'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: examsAsync.when(
              data: (exams) {
                if (exams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.quiz_outlined, size: 56, color: Color(0xFF4F46E5)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Exams Found',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your first exam to get started.',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton.icon(
                          onPressed: () => context.push(RoutePaths.adminCreateExam),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Exam'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allExamsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final exam = exams[index];
                      return _ExamCard(exam: exam);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                    const SizedBox(height: 16),
                    Text('Error: $e', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(allExamsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
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
                appBar: const AdminAppBar(title: 'Manage Exams', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const AdminAppBar(title: 'Manage Exams'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }
}

class _ExamCard extends ConsumerWidget {
  final dynamic exam;
  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(
            RoutePaths.adminExamDetails.replaceAll(':examId', exam.id),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: Color(0xFF4F46E5), size: 24),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _Tag(label: exam.category, color: const Color(0xFF4F46E5)),
                          const SizedBox(width: 8),
                          _Tag(
                            label: '${exam.durationInMinutes} mins',
                            color: const Color(0xFF6B7280),
                            bgColor: const Color(0xFFF3F4F6),
                          ),
                          const SizedBox(width: 8),
                          _Tag(
                            label: exam.isPublished ? 'Published' : 'Draft',
                            color: exam.isPublished ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            bgColor: exam.isPublished
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEF3C7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      color: const Color(0xFF4F46E5),
                      tooltip: 'Edit',
                      onTap: () => context.push(
                        RoutePaths.adminEditExam.replaceAll(':examId', exam.id),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _ActionButton(
                      icon: Icons.leaderboard_outlined,
                      color: const Color(0xFF8B5CF6),
                      tooltip: 'Leaderboard',
                      onTap: () => context.push(
                        RoutePaths.adminLeaderboard.replaceAll(':examId', exam.id),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      color: const Color(0xFFEF4444),
                      tooltip: 'Delete',
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Exam'),
                            content: Text('Delete "${exam.title}"? This cannot be undone.'),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(examRepositoryProvider).deleteExam(exam.id);
                          ref.invalidate(allExamsProvider);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _Tag({
    required this.label,
    required this.color,
    this.bgColor = const Color(0xFFEEF2FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
