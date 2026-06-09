import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_paper/result_entity.dart';

class ResultModel extends ResultEntity {
  const ResultModel({
    required super.id,
    required super.examId,
    required super.userId,
    required super.examTitle,
    required super.score,
    required super.totalMarks,
    required super.correctCount,
    required super.incorrectCount,
    required super.attemptedCount,
    required super.isPassed,
    required super.timestamp,
    required super.subjectStats,
  });

  factory ResultModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    if (data == null) {
      throw Exception('Result document does not exist');
    }

    return ResultModel(
      id: doc.id,
      examId: data['examId'] ?? '',
      userId: data['userId'] ?? '',
      examTitle: data['examTitle'] ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      totalMarks: (data['totalMarks'] as num?)?.toInt() ?? 0,
      correctCount: (data['correctCount'] as num?)?.toInt() ?? 0,
      incorrectCount: (data['incorrectCount'] as num?)?.toInt() ?? 0,
      attemptedCount: (data['attemptedCount'] as num?)?.toInt() ?? 0,
      isPassed: data['isPassed'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subjectStats: _parseSubjectStats(data['subjectStats']),
    );
  }

  static Map<String, Map<String, int>> _parseSubjectStats(dynamic data) {
    if (data == null) return {};

    final result = <String, Map<String, int>>{};

    (data as Map<String, dynamic>).forEach((subject, stats) {
      result[subject] = {};

      (stats as Map<String, dynamic>).forEach((key, value) {
        result[subject]![key] = (value as num?)?.toInt() ?? 0;
      });
    });

    return result;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'examId': examId,
      'userId': userId,
      'examTitle': examTitle,
      'score': score,
      'totalMarks': totalMarks,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'attemptedCount': attemptedCount,
      'isPassed': isPassed,
      'subjectStats': subjectStats,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
