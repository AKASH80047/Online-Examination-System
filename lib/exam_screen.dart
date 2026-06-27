import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/exam_session_provider.dart';
import 'app_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/exam_providers.dart';

class ExamScreen extends ConsumerStatefulWidget {
  final String examId;
  const ExamScreen({super.key, required this.examId});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final notifier = ref.read(activeExamSessionProvider(widget.examId).notifier);
      final session = ref.read(activeExamSessionProvider(widget.examId));

      if (!session.isCompleted) {
        notifier.submitExam();
        if (mounted) {
          context.pushReplacement(
            RoutePaths.userResultSummary.replaceAll(':examId', widget.examId),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exam auto-submitted because you left the app.')),
          );
        }
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final examAsync = ref.watch(examDetailProvider(widget.examId));
    final questionsAsync = ref.watch(examQuestionsProvider(widget.examId));

    return examAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => _buildErrorState(context, err.toString()),
      data: (exam) => questionsAsync.when(
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
    final notifier = ref.read(activeExamSessionProvider(widget.examId).notifier);

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 950;

    final currentQuestion = session.questions[session.currentQuestionIndex];
    final selectedIndices = session.selectedAnswers[currentQuestion.id] ?? [];

    Widget buildQuestionPane() {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate info & progress bar
            _buildCandidateHeader(context, session),
            const SizedBox(height: 20),
            
            // Question context
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'QUESTION ${session.currentQuestionIndex + 1} OF ${session.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentQuestion.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 24),
            
            // Options list
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndices.contains(index);
                  final isCorrect = currentQuestion.correctOptionIndices.contains(index);
                  final showFeedback = session.exam.isInstantFeedback && selectedIndices.isNotEmpty;

                  Color borderCol = isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0);
                  Color bgCol = isSelected ? const Color(0xFFEEF2FF) : Colors.white;

                  if (showFeedback) {
                    if (isSelected) {
                      borderCol = isCorrect ? Colors.green : Colors.red;
                      bgCol = isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
                    } else if (isCorrect) {
                      borderCol = Colors.green;
                      bgCol = const Color(0xFFF0FDF4);
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: bgCol,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol, width: 1.8),
                    ),
                    child: CheckboxListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      title: Text(
                        '${String.fromCharCode(65 + index)}. ${currentQuestion.options[index]}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                      value: isSelected,
                      activeColor: const Color(0xFF4F46E5),
                      onChanged: (val) {
                        if (session.exam.isInstantFeedback && selectedIndices.isNotEmpty) {
                          return;
                        }

                        List<int> newList = List.from(selectedIndices);
                        if (currentQuestion.type == QuestionType.multiple) {
                          val == true ? newList.add(index) : newList.remove(index);
                        } else {
                          newList = [index];
                        }
                        notifier.selectAnswer(currentQuestion.id, newList);
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Bottom control row
            _buildControlRow(context, session, notifier, currentQuestion),
          ],
        ),
      );
    }

    Widget buildPalettePane() {
      return Container(
        width: 320,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(left: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Question Palette',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: session.questions.length,
                itemBuilder: (context, idx) {
                  final qId = session.questions[idx].id;
                  final isCurrent = idx == session.currentQuestionIndex;
                  final isAnswered = session.selectedAnswers[qId]?.isNotEmpty ?? false;
                  final isMarked = session.markedForReview.contains(qId);

                  Color itemCol = const Color(0xFFF1F5F9);
                  Color textCol = const Color(0xFF64748B);
                  Border? border;

                  if (isAnswered) {
                    itemCol = const Color(0xFF10B981); // Emerald Green
                    textCol = Colors.white;
                  }
                  if (isMarked) {
                    itemCol = const Color(0xFFF59E0B); // Amber
                    textCol = Colors.white;
                  }
                  if (isCurrent) {
                    border = Border.all(color: const Color(0xFF4F46E5), width: 2.5);
                  }

                  return InkWell(
                    onTap: () => notifier.jumpToQuestion(idx),
                    child: Container(
                      decoration: BoxDecoration(
                        color: itemCol,
                        shape: BoxShape.circle,
                        border: border,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: textCol),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // Legends
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildLegendRow(const Color(0xFF10B981), 'Answered'),
                  const SizedBox(height: 8),
                  _buildLegendRow(const Color(0xFFF59E0B), 'Marked for Review'),
                  const SizedBox(height: 8),
                  _buildLegendRow(const Color(0xFFF1F5F9), 'Unanswered'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _confirmSubmit(context, notifier);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(session.exam.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(session.remainingSeconds),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
        endDrawer: isDesktop ? null : Drawer(child: buildPalettePane()),
        body: Row(
          children: [
            Expanded(child: buildQuestionPane()),
            if (isDesktop) buildPalettePane(),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateHeader(BuildContext context, ExamSessionState session) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Candidate: Student User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
          Text('Code: ${session.exam.id.substring(0, 5).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildControlRow(BuildContext context, ExamSessionState session, ExamSessionNotifier notifier, QuestionEntity currentQuestion) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: session.currentQuestionIndex > 0 ? notifier.previousQuestion : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Previous', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          OutlinedButton.icon(
            onPressed: () => notifier.toggleMarkForReview(currentQuestion.id),
            icon: Icon(
              session.markedForReview.contains(currentQuestion.id) ? Icons.bookmark : Icons.bookmark_border,
              color: const Color(0xFFF59E0B),
            ),
            label: Text(
              session.markedForReview.contains(currentQuestion.id) ? 'Unmark' : 'Mark Review',
              style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          ElevatedButton(
            onPressed: session.currentQuestionIndex < session.questions.length - 1
                ? notifier.nextQuestion
                : () => _confirmSubmit(context, notifier),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              session.currentQuestionIndex < session.questions.length - 1 ? 'Next' : 'Submit Exam',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String text) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
      ],
    );
  }

  void _confirmSubmit(BuildContext context, ExamSessionNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Examination Paper?'),
        content: const Text('Are you sure you want to finish the exam? This will submit your answers immediately.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await notifier.submitExam();
              if (context.mounted) {
                Navigator.pop(context);
                context.pushReplacement(
                  RoutePaths.userResultSummary.replaceAll(':examId', widget.examId),
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
