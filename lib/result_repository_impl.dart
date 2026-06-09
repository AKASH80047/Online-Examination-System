import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_paper/result_entity.dart';
import 'package:exam_paper/result_repository.dart';

import 'package:exam_paper/result_model.dart'; // Corrected import for ResultModel

class ResultRepositoryImpl implements ResultRepository {
  final FirebaseFirestore _firestore;

  ResultRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitResult(ResultEntity result) async {
    final model = ResultModel(
      id: result.id, // Firestore will generate if empty
      examId: result.examId,
      userId: result.userId,
      examTitle: result.examTitle,
      score: result.score,
      totalMarks: result.totalMarks,
      correctCount: result.correctCount,
      incorrectCount: result.incorrectCount,
      attemptedCount: result.attemptedCount,
      isPassed: result.isPassed,
      timestamp: result.timestamp,
      subjectStats: result.subjectStats,
    );
    await _firestore.collection('results').add(model.toFirestore());
  }

  @override
  Future<List<ResultEntity>> getUserResults(String userId) async {
    final snapshot = await _firestore
        .collection('results')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => ResultModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ResultEntity>> getTopResultsForExam(
    String examId, {
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('results')
        .where('examId', isEqualTo: examId)
        .orderBy('score', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => ResultModel.fromFirestore(doc)).toList();
  }
}
