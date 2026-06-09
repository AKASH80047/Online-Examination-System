import 'package:flutter/material.dart';

class SubjectReportScreen extends StatelessWidget {
  const SubjectReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      _SubjectItem(name: 'Mathematics', averageScore: 84.2, examAttempts: 124, status: 'Excellent'),
      _SubjectItem(name: 'Physics', averageScore: 71.5, examAttempts: 98, status: 'Satisfactory'),
      _SubjectItem(name: 'Chemistry', averageScore: 68.4, examAttempts: 110, status: 'Needs Improvement'),
      _SubjectItem(name: 'General Science', averageScore: 79.8, examAttempts: 156, status: 'Good'),
      _SubjectItem(name: 'Literature', averageScore: 88.0, examAttempts: 64, status: 'Excellent'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject-wise Performance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topic Strengths & Performance Analysis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comparison of examinee scores segmented by subject area.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final sub = subjects[index];
              Color statusColor;
              if (sub.averageScore >= 80) {
                statusColor = Colors.green;
              } else if (sub.averageScore >= 70) {
                statusColor = Colors.blue;
              } else {
                statusColor = Colors.orange;
              }

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sub.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sub.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Avg Score: ${sub.averageScore}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${sub.examAttempts} attempts',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: sub.averageScore / 100,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        color: statusColor,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
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
}

class _SubjectItem {
  final String name;
  final double averageScore;
  final int examAttempts;
  final String status;

  _SubjectItem({
    required this.name,
    required this.averageScore,
    required this.examAttempts,
    required this.status,
  });
}
