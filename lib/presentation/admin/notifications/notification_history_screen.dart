import 'package:flutter/material.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      _HistoryItem(
        title: 'Weekly Science Quiz is Live!',
        body: 'Click here to take the exam. Good luck to all participants!',
        date: 'June 03, 2026 - 10:00 AM',
        target: 'Students Only',
      ),
      _HistoryItem(
        title: 'System Maintenance Scheduled',
        body: 'Platform will be down for maintenance on Sunday from 2 AM to 4 AM.',
        date: 'May 28, 2026 - 04:30 PM',
        target: 'All Users',
      ),
      _HistoryItem(
        title: 'New Feature Added: Certificates',
        body: 'Students who score above passing marks will now receive automatic PDF certificates.',
        date: 'May 15, 2026 - 11:15 AM',
        target: 'All Users',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History Log'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
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
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.target,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.body,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.date,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryItem {
  final String title;
  final String body;
  final String date;
  final String target;

  _HistoryItem({
    required this.title,
    required this.body,
    required this.date,
    required this.target,
  });
}
