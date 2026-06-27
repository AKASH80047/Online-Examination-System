import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'app_constants.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/auth_providers.dart';

class ExamInstructionScreen extends ConsumerStatefulWidget {
  final String examId;
  const ExamInstructionScreen({super.key, required this.examId});

  @override
  ConsumerState<ExamInstructionScreen> createState() => _ExamInstructionScreenState();
}

class _ExamInstructionScreenState extends ConsumerState<ExamInstructionScreen> {
  bool _hasAgreed = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    final examAsync = ref
        .watch(publishedExamsProvider)
        .whenData((exams) => exams.firstWhereOrNull((e) => e.id == widget.examId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Instruction Guidelines'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: examAsync.when(
        data: (exam) {
          if (exam == null) {
            return const Center(child: Text('Exam not found.'));
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Paper Info Banner
                      _buildHeaderBanner(context, exam),
                      const SizedBox(height: 24),

                      // Candidate Info Card
                      _buildCandidateCard(context, user?.name ?? 'Student', user?.email ?? ''),
                      const SizedBox(height: 24),

                      // Instructions Box
                      _buildInstructionsCard(context, exam),
                      const SizedBox(height: 24),

                      // Agree Checkbox
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: CheckboxListTile(
                          value: _hasAgreed,
                          onChanged: (val) => setState(() => _hasAgreed = val ?? false),
                          title: const Text(
                            'I have read and understood the instructions. I agree to abide by the exam rules.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          activeColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _hasAgreed
                              ? () => context.pushReplacement(
                                    RoutePaths.userExamScreen.replaceAll(':examId', widget.examId),
                                  )
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF94A3B8),
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text(
                            'Enter Examination Hall',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, dynamic exam) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            exam.description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.person, color: Color(0xFF64748B), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CANDIDATE DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context, dynamic exam) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EXAMINATION RULES', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          _buildRuleRow(Icons.timer_outlined, 'Duration: ${exam.durationInMinutes} minutes'),
          _buildRuleRow(Icons.score, 'Maximum Marks: ${exam.totalMarks} Points'),
          _buildRuleRow(Icons.check_circle_outline, 'Passing Threshold: ${exam.passingMarks} Points (${exam.passingPercentage}%)'),
          _buildRuleRow(Icons.lock_outline, 'Anti-Cheat: Navigating away from the application will auto-submit the exam.'),
          _buildRuleRow(Icons.device_thermostat, 'OMR Mode: Instant selection auto-saves your progress dynamically.'),
        ],
      ),
    );
  }

  Widget _buildRuleRow(IconData icon, String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4F46E5), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
