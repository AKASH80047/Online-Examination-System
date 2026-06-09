import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/exam_session_provider.dart';
import 'question_palette.dart';
import 'app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/exam_providers.dart'; // Import exam_providers for publishedExamsProvider and examQuestionsProvider

class ExamScreen extends ConsumerStatefulWidget {
  final String examId;
  const ExamScreen({super.key, required this.examId});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen>
    with WidgetsBindingObserver {
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Enter full-screen immersive mode when exam starts
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Exit full-screen mode when exam ends
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Anti-cheat: Auto-submit if the user leaves the app or opens another window
      final notifier = ref.read(
        activeExamSessionProvider(widget.examId).notifier,
      );
      final session = ref.read(activeExamSessionProvider(widget.examId));

      if (!session.isCompleted) {
        notifier.submitExam();
        if (mounted) {
          context.pushReplacement(
            RoutePaths.userResultSummary.replaceAll(':examId', widget.examId),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exam auto-submitted because you left the app.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(publishedExamsProvider);
    final questionsAsync = ref.watch(examQuestionsProvider(widget.examId));

    return examsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => _buildErrorState(context, err.toString()),
      data: (exams) => questionsAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => _buildErrorState(context, err.toString()),
        data: (questions) => _buildExamContent(context),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(publishedExamsProvider);
                ref.invalidate(examQuestionsProvider(widget.examId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamContent(BuildContext context) {
    final session = ref.watch(activeExamSessionProvider(widget.examId));
    final notifier = ref.read(
      activeExamSessionProvider(widget.examId).notifier,
    );

    final currentQuestion = session.questions[session.currentQuestionIndex];
    final selectedIndices = session.selectedAnswers[currentQuestion.id] ?? [];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _confirmSubmit(context, notifier);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(session.exam.title),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _formatTime(session.remainingSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
        drawer: QuestionPalette(examId: widget.examId),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${session.currentQuestionIndex + 1} of ${session.questions.length}',
                  ),
                  if (session.markedForReview.contains(currentQuestion.id))
                    const Chip(
                      label: Text('Marked for Review'),
                      backgroundColor: Colors.orangeAccent,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                currentQuestion.text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedIndices.contains(index);
                    final isCorrect = currentQuestion.correctOptionIndices
                        .contains(index);
                    final showFeedback =
                        session.exam.isInstantFeedback &&
                        selectedIndices.isNotEmpty;

                    Color? tileColor;
                    if (showFeedback) {
                      if (isSelected) {
                        tileColor = isCorrect
                            ? Colors.green.shade100
                            : Colors.red.shade100;
                      } else if (isCorrect) {
                        tileColor = Colors.green.shade50;
                      }
                    }

                    return CheckboxListTile(
                      tileColor: tileColor,
                      title: Text(currentQuestion.options[index]),
                      value: isSelected,
                      onChanged: (val) {
                        // Disable selection changes if instant feedback is shown
                        if (session.exam.isInstantFeedback &&
                            selectedIndices.isNotEmpty) {
                          return;
                        }

                        List<int> newList = List.from(selectedIndices);
                        if (currentQuestion.type == QuestionType.multiple) {
                          val == true
                              ? newList.add(index)
                              : newList.remove(index);
                        } else {
                          newList = [index];
                        }
                        notifier.selectAnswer(currentQuestion.id, newList);
                      },
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: session.currentQuestionIndex > 0
                        ? notifier.previousQuestion
                        : null,
                    child: const Text('Previous'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        notifier.toggleMarkForReview(currentQuestion.id),
                    child: Text(
                      session.markedForReview.contains(currentQuestion.id)
                          ? 'Unmark'
                          : 'Mark for Review',
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        session.currentQuestionIndex <
                            session.questions.length - 1
                        ? notifier.nextQuestion
                        : () => _confirmSubmit(context, notifier),
                    child: Text(
                      session.currentQuestionIndex <
                              session.questions.length - 1
                          ? 'Next'
                          : 'Submit Exam',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSubmit(BuildContext context, ExamSessionNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Exam?'),
        content: const Text('Are you sure you want to finish the exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await notifier.submitExam();
              if (context.mounted) { // Check mounted before pop and push
                Navigator.pop(context); // Pop the dialog
                context.pushReplacement( // Navigate to summary
                  RoutePaths.userResultSummary.replaceAll(
                    ':examId',
                    widget.examId,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
