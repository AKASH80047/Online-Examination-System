import 'package:exam_paper/exam_entity.dart';
import 'package:exam_paper/question_entity.dart';

abstract class ExamRepository {
  Future<List<ExamEntity>> getPublishedExams();
  Future<List<ExamEntity>> getAllExams();
  Future<ExamEntity> getExamById(String id);
  Future<void> createExam(ExamEntity exam);
  Future<void> deleteExam(String id);
  Future<void> updateExam(ExamEntity exam);
  Future<List<QuestionEntity>> getQuestionsForExam(String examId);
  Future<void> addQuestion(String examId, QuestionEntity question);
  Future<void> updateQuestion(String examId, QuestionEntity question);
  Future<void> deleteQuestion(String examId, String questionId);
}
