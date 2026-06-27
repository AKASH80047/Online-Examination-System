import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/user_providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  final String examId;
  const LeaderboardScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider(examId));

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: leaderboardAsync.when(
        data: (results) {
          if (results.isEmpty) {
            return const Center(child: Text('No results yet. Be the first!'));
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Consumer(
                  builder: (context, ref, child) {
                    final userAsync = ref.watch(userProfileProvider(result.userId));
                    return userAsync.when(
                      data: (user) => Text(user?.name ?? 'Student (${result.userId.substring(0, 5)}...)'),
                      loading: () => const Text('Loading student...'),
                      error: (e, s) => Text(result.userId),
                    );
                  },
                ),
                subtitle: Text('Score: ${result.score} / ${result.totalMarks}'),
                trailing: result.isPassed
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
