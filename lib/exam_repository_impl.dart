import 'package:exam_paper/exam_entity.dart';
import 'package:exam_paper/exam_repository.dart';
import 'package:exam_paper/exam_remote_ds.dart';
import 'package:exam_paper/exam_model.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/question_model.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDataSource remoteDataSource;

  ExamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ExamEntity>> getPublishedExams() async {
    final examModels = await remoteDataSource.getPublishedExams();
    return examModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ExamEntity>> getAllExams() async {
    final examModels = await remoteDataSource.getAllExams();
    return examModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ExamEntity> getExamById(String id) async {
    final examModel = await remoteDataSource.getExamById(id);
    return examModel.toEntity();
  }

  @override
  Future<void> createExam(ExamEntity exam) async {
    final examModel = ExamModel(
      id: '',
      title: exam.title,
      description: exam.description,
      durationInMinutes: exam.durationInMinutes,
      totalMarks: exam.totalMarks,
      passingMarks: exam.passingMarks,
      category: exam.category,
      createdAt: exam.createdAt,
      isPublished: exam.isPublished,
      isInstantFeedback: exam.isInstantFeedback,
    );
    await remoteDataSource.createExam(examModel);
  }

  @override
  Future<void> deleteExam(String id) async {
    await remoteDataSource.deleteExam(id);
  }

  @override
  Future<void> updateExam(ExamEntity exam) async {
    final examModel = ExamModel(
      id: exam.id,
      title: exam.title,
      description: exam.description,
      durationInMinutes: exam.durationInMinutes,
      totalMarks: exam.totalMarks,
      passingMarks: exam.passingMarks,
      category: exam.category,
      createdAt: exam.createdAt,
      isPublished: exam.isPublished,
      isInstantFeedback: exam.isInstantFeedback,
    );
    await remoteDataSource.updateExam(examModel);
  }

  @override
  Future<List<QuestionEntity>> getQuestionsForExam(String examId) async {
    final questionModels = await remoteDataSource.getQuestionsForExam(examId);
    return questionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addQuestion(String examId, QuestionEntity question) async {
    final questionModel = QuestionModel(
      id: '',
      text: question.text,
      options: question.options,
      correctOptionIndices: question.correctOptionIndices,
      explanation: question.explanation,
      imageUrl: question.imageUrl,
      type: question.type,
      subject: question.subject,
      difficulty: question.difficulty,
    );
    await remoteDataSource.addQuestion(examId, questionModel);
  }

  @override
  Future<void> updateQuestion(String examId, QuestionEntity question) async {
    final questionModel = QuestionModel(
      id: question.id,
      text: question.text,
      options: question.options,
      correctOptionIndices: question.correctOptionIndices,
      explanation: question.explanation,
      imageUrl: question.imageUrl,
      type: question.type,
      subject: question.subject,
      difficulty: question.difficulty,
    );
    await remoteDataSource.updateQuestion(examId, questionModel);
  }

  @override
  Future<void> deleteQuestion(String examId, String questionId) async {
    await remoteDataSource.deleteQuestion(examId, questionId);
  }
}
