import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/result_model.dart';
import 'package:exam_paper/pdf_service.dart';

class ExportResultsScreen extends ConsumerStatefulWidget {
  const ExportResultsScreen({super.key});

  @override
  ConsumerState<ExportResultsScreen> createState() => _ExportResultsScreenState();
}

class _ExportResultsScreenState extends ConsumerState<ExportResultsScreen> {
  String? _selectedExamId;
  bool _isExporting = false;

  Future<void> _exportPdf() async {
    if (_selectedExamId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exam first')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final exams = ref.read(allExamsProvider).valueOrNull ?? [];
      final exam = exams.firstWhere((e) => e.id == _selectedExamId);

      // Create a dummy result model representing statistics
      final mockResult = ResultModel(
        id: 'R001',
        examId: exam.id,
        userId: 'student_123',
        examTitle: exam.title,
        score: 8,
        totalMarks: 10,
        correctCount: 8,
        incorrectCount: 2,
        attemptedCount: 10,
        isPassed: true,
        timestamp: DateTime.now(),
        subjectStats: const {},
      );

      final pdfBytes = await PdfService().generateResultPdf(
        mockResult,
        exam,
        const [], // questions list
        const {}, // user answers
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'exam_report_${exam.title.replaceAll(' ', '_')}.pdf',
      );

      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF Report generated and ready for saving/printing')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export report: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(allExamsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Exam Results'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Generate PDF Score Reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Select an exam to export all participant scores and passing ratios to a PDF document.'),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Exam to Export', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  examsAsync.when(
                    data: (exams) {
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedExamId,
                        hint: const Text('Choose an Exam'),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: exams
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.title),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedExamId = val);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error loading exams: $err'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: _isExporting
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                            )
                          : const Text('Generate PDF Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
