import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:collection/collection.dart';
import 'package:exam_paper/exam_session_provider.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/pdf_service.dart';
import 'package:exam_paper/certificate_service.dart';
import 'package:exam_paper/exam_providers.dart'; // Ensure this is imported
import 'package:exam_paper/auth_providers.dart'; // Import authStateProvider
import 'package:exam_paper/result_entity.dart'; // Import ResultEntity

class ResultSummaryScreen extends ConsumerWidget {
  final String examId;
  const ResultSummaryScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeExamSessionProvider(examId));
    final examAsync = ref
        .watch(publishedExamsProvider)
        .whenData((exams) => exams.firstWhereOrNull((e) => e.id == examId));
    final questionsAsync = ref.watch(examQuestionsProvider(examId));

    // Ensure all data is available before building the screen
    if (examAsync.isLoading || questionsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (examAsync.hasError || questionsAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Text(
            'Error loading exam details: ${examAsync.error ?? questionsAsync.error}',
          ),
        ),
      );
    }

    final exam = examAsync.value!;
    final questions = questionsAsync.value!;

    // Extract computed stats from the session state
    final correct = session.correctCount;
    final total = session.questions.length;
    final attempted = session.attemptedCount;
    final isPassed = session.isPassed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              isPassed ? Icons.check_circle : Icons.cancel,
              size: 100,
              color: isPassed ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isPassed ? 'Congratulations!' : 'Better Luck Next Time!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: isPassed ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPassed
                  ? 'You have passed the exam.'
                  : 'You did not meet the passing criteria.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            _buildStatCard(context, 'Total Score', '$correct / $total'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSmallStat(context, 'Attempted', '$attempted'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSmallStat(context, 'Correct', '$correct'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSmallStat(
                    context,
                    'Incorrect',
                    '${attempted - correct}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Subject Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ...session.subjectStats.entries.map((entry) {
              final subject = entry.key;
              final correct = entry.value['correct'] ?? 0;
              final total = entry.value['total'] ?? 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$subject ($correct / $total)'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: correct / total,
                      backgroundColor: Colors.grey[300],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(RoutePaths.userDashboard),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Back to Dashboard'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final pdfBytes = await PdfService().generateResultPdf(
                    ResultEntity(
                      id: '', // Not relevant for PDF generation
                      examId: exam.id,
                      userId:
                          ref.read(authStateProvider).value?.uid ??
                          'unknown', // Handle null user
                      examTitle: exam.title,
                      score: correct,
                      totalMarks: total,
                      correctCount: correct,
                      incorrectCount: attempted - correct,
                      attemptedCount: attempted,
                      isPassed: isPassed,
                      timestamp: DateTime.now(),
                      subjectStats: session.subjectStats,
                    ),
                    exam,
                    questions,
                    session.selectedAnswers,
                  );
                  await Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'exam_result_${exam.title}.pdf',
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Download PDF Report'),
              ),
            ),
            if (isPassed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final user = ref
                        .read(authStateProvider)
                        .value; // Ensure authStateProvider is imported
                    final pdfBytes = await CertificateService()
                        .generateCertificate(
                          userName: user?.name ?? 'Student',
                          result: ResultEntity(
                            id: '',
                            examId: exam.id,
                            userId: user?.uid ?? 'unknown',
                            examTitle: exam.title,
                            score: correct,
                            totalMarks: total,
                            correctCount: correct,
                            incorrectCount: attempted - correct,
                            attemptedCount: attempted,
                            isPassed: isPassed,
                            timestamp: DateTime.now(),
                            subjectStats: session.subjectStats,
                          ),
                          exam: exam,
                        );
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: 'certificate_${exam.title}.pdf',
                    );
                  },
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text('Download Certificate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
