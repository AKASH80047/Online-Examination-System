import 'package:flutter/material.dart';

class ResultDetailsScreen extends StatelessWidget {
  final String resultId;
  const ResultDetailsScreen({super.key, required this.resultId});

  @override
  Widget build(BuildContext context) {
    // Mock user submission details
    final questions = [
      _QuestionDetail(
        text: 'What is the powerhouse of the cell?',
        options: ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi Apparatus'],
        selectedIdx: 1,
        correctIdx: 1,
        explanation: 'Mitochondria generates chemical energy (ATP) for the cell, hence called powerhouse.',
      ),
      _QuestionDetail(
        text: 'Which planet is known as the Red Planet?',
        options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
        selectedIdx: 2, // incorrect Mars is index 1
        correctIdx: 1,
        explanation: 'Mars is known as the Red Planet due to the iron oxide prevalent on its surface.',
      ),
      _QuestionDetail(
        text: 'What is the chemical formula for water?',
        options: ['CO2', 'H2O', 'NaCl', 'O2'],
        selectedIdx: 1,
        correctIdx: 1,
        explanation: 'Water is made of two hydrogen atoms bonded to one oxygen atom (H2O).',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Submission detail: $resultId'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text('Examinee: John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryStat(context, 'Exam', 'Science Quiz 101'),
                      _buildSummaryStat(context, 'Score', '66.7%'),
                      _buildSummaryStat(context, 'Status', 'Passed'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Question Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            itemBuilder: (context, qIdx) {
              final q = questions[qIdx];
              final isCorrect = q.selectedIdx == q.correctIdx;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: isCorrect ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                            child: Icon(
                              isCorrect ? Icons.check : Icons.close,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Q${qIdx + 1}: ${q.text}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...q.options.asMap().entries.map((entry) {
                        final optIdx = entry.key;
                        final optText = entry.value;
                        Color textColor = Colors.black87;
                        Widget trailing = const SizedBox();

                        if (optIdx == q.correctIdx) {
                          textColor = Colors.green;
                          trailing = const Icon(Icons.check, color: Colors.green, size: 16);
                        } else if (optIdx == q.selectedIdx) {
                          textColor = Colors.red;
                          trailing = const Icon(Icons.close, color: Colors.red, size: 16);
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: optIdx == q.correctIdx
                                ? Colors.green.withValues(alpha: 0.05)
                                : optIdx == q.selectedIdx
                                    ? Colors.red.withValues(alpha: 0.05)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: optIdx == q.correctIdx
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : optIdx == q.selectedIdx
                                      ? Colors.red.withValues(alpha: 0.3)
                                      : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(optText, style: TextStyle(color: textColor, fontWeight: optIdx == q.correctIdx || optIdx == q.selectedIdx ? FontWeight.bold : FontWeight.normal)),
                              trailing,
                            ],
                          ),
                        );
                      }),
                      if (q.explanation != null) ...[
                        const Divider(height: 24),
                        Text(
                          'Explanation:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          q.explanation!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _QuestionDetail {
  final String text;
  final List<String> options;
  final int selectedIdx;
  final int correctIdx;
  final String? explanation;

  _QuestionDetail({
    required this.text,
    required this.options,
    required this.selectedIdx,
    required this.correctIdx,
    this.explanation,
  });
}
