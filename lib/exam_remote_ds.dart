import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_paper/exam_model.dart';
import 'package:exam_paper/question_model.dart';
// Import ExamModel
// Import QuestionModel

abstract class ExamRemoteDataSource {
  Future<List<ExamModel>> getPublishedExams();
  Future<List<ExamModel>> getAllExams();
  Future<ExamModel> getExamById(String id);
  Future<void> createExam(ExamModel exam);
  Future<void> deleteExam(String id);
  Future<void> updateExam(ExamModel exam);
  Future<List<QuestionModel>> getQuestionsForExam(String examId);
  Future<void> addQuestion(String examId, QuestionModel question);
  Future<void> updateQuestion(String examId, QuestionModel question);
  Future<void> deleteQuestion(String examId, String questionId);
}

class ExamRemoteDataSourceImpl implements ExamRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExamRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ExamModel>> getPublishedExams() async {
    final snapshot = await _firestore
        .collection('exams')
        .where('isPublished', isEqualTo: true)
        .get();
    return snapshot.docs.map((doc) => ExamModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ExamModel>> getAllExams() async {
    final snapshot = await _firestore.collection('exams').get();
    return snapshot.docs.map((doc) => ExamModel.fromFirestore(doc)).toList();
  }

  @override
  Future<ExamModel> getExamById(String id) async {
    final doc = await _firestore.collection('exams').doc(id).get();
    return ExamModel.fromFirestore(doc);
  }

  @override
  Future<void> createExam(ExamModel exam) async {
    await _firestore.collection('exams').add(exam.toFirestore());
  }

  @override
  Future<void> deleteExam(String id) async {
    await _firestore.collection('exams').doc(id).delete();
  }

  @override
  Future<void> updateExam(ExamModel exam) async {
    await _firestore
        .collection('exams')
        .doc(exam.id)
        .update(exam.toFirestore());
  }

  @override
  Future<List<QuestionModel>> getQuestionsForExam(String examId) async {
    final snapshot = await _firestore
        .collection('exams')
        .doc(examId)
        .collection('questions')
        .get();
    return snapshot.docs
        .map((doc) => QuestionModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> addQuestion(String examId, QuestionModel question) async {
    await _firestore
        .collection('exams')
        .doc(examId)
        .collection('questions')
        .add(question.toFirestore());
  }

  @override
  Future<void> updateQuestion(String examId, QuestionModel question) async {
    await _firestore
        .collection('exams')
        .doc(examId)
        .collection('questions')
        .doc(question.id)
        .update(question.toFirestore());
  }

  @override
  Future<void> deleteQuestion(String examId, String questionId) async {
    await _firestore
        .collection('exams')
        .doc(examId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }
}
