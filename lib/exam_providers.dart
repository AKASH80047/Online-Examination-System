import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/exam_remote_ds.dart';
import 'package:exam_paper/exam_repository_impl.dart';
import 'package:exam_paper/exam_repository.dart';
import 'package:exam_paper/exam_entity.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/result_entity.dart';
import 'package:exam_paper/auth_providers.dart';
import 'package:exam_paper/user_providers.dart';
import 'package:exam_paper/analytics_entity.dart';
import 'package:exam_paper/result_repository.dart';
import 'package:exam_paper/result_repository_impl.dart';

final examDataSourceProvider = Provider<ExamRemoteDataSource>((ref) {
  return ExamRemoteDataSourceImpl();
});

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final dataSource = ref.watch(examDataSourceProvider);
  return ExamRepositoryImpl(remoteDataSource: dataSource);
});

final resultRepositoryProvider = Provider<ResultRepository>((ref) {
  return ResultRepositoryImpl();
});

final publishedExamsProvider = FutureProvider<List<ExamEntity>>((ref) {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getPublishedExams();
});

final allExamsProvider = FutureProvider<List<ExamEntity>>((ref) {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getAllExams();
});

final examDetailProvider = FutureProvider.family<ExamEntity, String>((ref, examId) {
  final repository = ref.watch(examRepositoryProvider);
  return repository.getExamById(examId);
});

final examQuestionsProvider =
    FutureProvider.family<List<QuestionEntity>, String>((ref, examId) {
      final repository = ref.watch(examRepositoryProvider);
      return repository.getQuestionsForExam(examId);
    });

final userResultsProvider = FutureProvider<List<ResultEntity>>((ref) {
  final repository = ref.watch(resultRepositoryProvider);
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return const [];
  return repository.getUserResults(userId);
});

final leaderboardProvider = FutureProvider.family<List<ResultEntity>, String>((
  ref,
  examId,
) {
  final repository = ref.watch(resultRepositoryProvider);
  return repository.getTopResultsForExam(examId, limit: 10);
});

final adminExamSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAdminExamsProvider = Provider<AsyncValue<List<ExamEntity>>>((
  ref,
) {
  final examsAsync = ref.watch(allExamsProvider);
  final query = ref.watch(adminExamSearchQueryProvider).toLowerCase();

  return examsAsync.whenData((exams) {
    if (query.isEmpty) return exams;
    return exams
        .where(
          (exam) =>
              exam.title.toLowerCase().contains(query) ||
              exam.category.toLowerCase().contains(query),
        )
        .toList();
  });
});

final adminAnalyticsProvider = FutureProvider<AnalyticsEntity>((ref) async {
  final users = await ref.read(allUsersProvider.future);
  final exams = await ref.read(allExamsProvider.future);
  // In a real app, you would fetch aggregate result data from Firestore here

  return AnalyticsEntity(
    totalUsers: users.length,
    totalExams: exams.length,
    totalResults: 0,
    averageScore: 0,
  );
});
