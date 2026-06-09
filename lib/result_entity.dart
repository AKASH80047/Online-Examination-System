import 'package:equatable/equatable.dart';

class ResultEntity extends Equatable {
  final String id;
  final String examId;
  final String userId;
  final String examTitle;
  final int score;
  final int totalMarks;
  final int correctCount;
  final int incorrectCount;
  final int attemptedCount;
  final bool isPassed;
  final DateTime timestamp;
  final Map<String, Map<String, int>> subjectStats;

  const ResultEntity({
    required this.id,
    required this.examId,
    required this.userId,
    required this.examTitle,
    required this.score,
    required this.totalMarks,
    required this.correctCount,
    required this.incorrectCount,
    required this.attemptedCount,
    required this.isPassed,
    required this.timestamp,
    required this.subjectStats,
  });

  @override
  List<Object?> get props => [
    id,
    examId,
    userId,
    examTitle,
    score,
    totalMarks,
    correctCount,
    incorrectCount,
    attemptedCount,
    isPassed,
    timestamp,
    subjectStats,
  ];
}
