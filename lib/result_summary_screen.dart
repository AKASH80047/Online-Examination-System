import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:collection/collection.dart';
import 'package:exam_paper/exam_session_provider.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/pdf_service.dart';
import 'package:exam_paper/certificate_service.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/auth_providers.dart';
import 'package:exam_paper/result_entity.dart';

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

    if (examAsync.isLoading || questionsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (examAsync.hasError || questionsAsync.hasError) {
      return Scaffold(
        body: Center(
          child: Text('Error loading result stats: ${examAsync.error ?? questionsAsync.error}'),
        ),
      );
    }

    final exam = examAsync.value!;
    final questions = questionsAsync.value!;

    final correct = session.correctCount;
    final total = session.questions.length;
    final attempted = session.attemptedCount;
    final isPassed = session.isPassed;

    final scorePercentage = total > 0 ? (correct / total) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Academic Performance Report'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Pass/Fail Banner Card
                _buildStatusBanner(context, isPassed),
                const SizedBox(height: 32),

                // Score Gauge & General Stats Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;
                    final gridChildren = [
                      _buildCircularScoreGauge(context, scorePercentage, correct, total),
                      _buildStatsSummaryGrid(context, attempted, correct, total),
                    ];

                    if (isSmall) {
                      return Column(
                        children: [
                          gridChildren[0],
                          const SizedBox(height: 24),
                          gridChildren[1],
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: gridChildren[0]),
                        const SizedBox(width: 32),
                        Expanded(child: gridChildren[1]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Subject breakdown
                _buildSubjectBreakdown(context, session),
                const SizedBox(height: 32),

                // Reports Action Buttons
                _buildActionButtons(context, ref, exam, questions, session, correct, total, attempted, isPassed),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, bool isPassed) {
    Color bannerCol = isPassed ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    Color textCol = isPassed ? const Color(0xFF166534) : const Color(0xFF991B1B);
    IconData icon = isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bannerCol,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPassed ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 48, color: textCol),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPassed ? 'Exam Cleared successfully!' : 'Did Not Clear Exam',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textCol),
                ),
                const SizedBox(height: 4),
                Text(
                  isPassed
                      ? 'Congratulations, you have cleared the required passing criteria.'
                      : 'You did not meet the minimum score threshold. Try practicing again.',
                  style: TextStyle(fontSize: 13, color: textCol.withValues(alpha: 0.8), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularScoreGauge(BuildContext context, double scoreRatio, int correct, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        children: [
          const Text('Total Score Ratio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: scoreRatio,
                  strokeWidth: 12,
                  backgroundColor: const Color(0xFFF1F5F9),
                  color: const Color(0xFF4F46E5),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(scoreRatio * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    Text('$correct of $total', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummaryGrid(BuildContext context, int attempted, int correct, int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Key Metrics Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          _buildStatRow('Attempted Count', attempted.toString(), Colors.blue),
          const Divider(height: 20),
          _buildStatRow('Correct Answers', correct.toString(), Colors.green),
          const Divider(height: 20),
          _buildStatRow('Incorrect Answers', (attempted - correct).toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectBreakdown(BuildContext context, ExamSessionState session) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subject-wise Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          ...session.subjectStats.entries.map((entry) {
            final subject = entry.key;
            final correct = entry.value['correct'] ?? 0;
            final total = entry.value['total'] ?? 1;
            final ratio = correct / total;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                      Text('$correct / $total (${(ratio * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    dynamic exam,
    dynamic questions,
    dynamic session,
    int correct,
    int total,
    int attempted,
    bool isPassed,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () async {
              final pdfBytes = await PdfService().generateResultPdf(
                ResultEntity(
                  id: '',
                  examId: exam.id,
                  userId: ref.read(authStateProvider).value?.uid ?? 'unknown',
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
                filename: 'result_${exam.title}.pdf',
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Download PDF Report Sheet', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        if (isPassed) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                final user = ref.read(authStateProvider).value;
                final pdfBytes = await CertificateService().generateCertificate(
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
              label: const Text('Download Passing Certificate', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => context.go(RoutePaths.userDashboard),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to Student Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
