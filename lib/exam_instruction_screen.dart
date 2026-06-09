import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'app_constants.dart';
import 'package:exam_paper/exam_providers.dart';

class ExamInstructionScreen extends ConsumerWidget {
  final String examId;
  const ExamInstructionScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examAsync = ref
        .watch(publishedExamsProvider)
        .whenData((exams) => exams.firstWhereOrNull((e) => e.id == examId));

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Instructions')),
      body: examAsync.when(
        data: (exam) {
          if (exam == null) return const Center(child: Text('Exam not found.'));
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please read the following instructions carefully before starting the exam:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('• Total Duration: ${exam.durationInMinutes} minutes'),
                Text('• Total Marks: ${exam.totalMarks}'),
                Text('• Passing Marks: ${exam.passingMarks}'),
                const Text('• All questions are compulsory.'),
                const Text(
                  '• Do not refresh the page or exit the app during the exam.',
                ),
                const Text(
                  '• The exam will be automatically submitted once the timer ends.',
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.pushReplacement(
                      RoutePaths.userExamScreen.replaceAll(':examId', examId),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('I Agree & Start Exam'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
