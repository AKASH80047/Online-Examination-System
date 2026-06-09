import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/exam_session_provider.dart';

class QuestionPalette extends ConsumerWidget {
  final String examId;
  const QuestionPalette({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeExamSessionProvider(examId));
    final notifier = ref.read(activeExamSessionProvider(examId).notifier);

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text('Question Palette', style: TextStyle(fontSize: 20)),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: session.questions.length,
              itemBuilder: (context, index) {
                final qId = session.questions[index].id;
                final isAnswered = session.selectedAnswers.containsKey(qId);
                final isMarked = session.markedForReview.contains(qId);
                final isCurrent = session.currentQuestionIndex == index;

                return InkWell(
                  onTap: () {
                    notifier.jumpToQuestion(index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isMarked
                          ? Colors.orange
                          : (isAnswered ? Colors.green : Colors.grey[300]),
                      border: isCurrent
                          ? Border.all(width: 3, color: Colors.blue)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
