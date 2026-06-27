import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/exam_entity.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/result_entity.dart';
import 'package:exam_paper/result_repository.dart';
import 'package:exam_paper/auth_providers.dart';
import 'package:exam_paper/exam_providers.dart';

class ExamSessionState {
  final ExamEntity exam;
  final List<QuestionEntity> questions;
  final int currentQuestionIndex;
  final int remainingSeconds;
  final Map<String, List<int>> selectedAnswers;
  final Set<String> markedForReview;
  final bool isCompleted;
  final int correctCount;
  final int attemptedCount;
  final bool isPassed;
  final Map<String, Map<String, int>> subjectStats;

  ExamSessionState({
    required this.exam,
    required this.questions,
    this.currentQuestionIndex = 0,
    required this.remainingSeconds,
    this.selectedAnswers = const {},
    this.markedForReview = const {},
    this.isCompleted = false,
    this.correctCount = 0,
    this.attemptedCount = 0,
    this.isPassed = false,
    this.subjectStats = const {},
  });

  ExamSessionState copyWith({
    int? currentQuestionIndex,
    int? remainingSeconds,
    Map<String, List<int>>? selectedAnswers,
    Set<String>? markedForReview,
    bool? isCompleted,
    int? correctCount,
    int? attemptedCount,
    bool? isPassed,
    Map<String, Map<String, int>>? subjectStats,
  }) {
    return ExamSessionState(
      exam: exam,
      questions: questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      markedForReview: markedForReview ?? this.markedForReview,
      isCompleted: isCompleted ?? this.isCompleted,
      correctCount: correctCount ?? this.correctCount,
      attemptedCount: attemptedCount ?? this.attemptedCount,
      isPassed: isPassed ?? this.isPassed,
      subjectStats: subjectStats ?? this.subjectStats,
    );
  }
}

class ExamSessionNotifier extends StateNotifier<ExamSessionState> {
  Timer? _timer;
  final ResultRepository _resultRepository;
  final String? _userId;

  ExamSessionNotifier(
    ExamEntity exam,
    List<QuestionEntity> questions,
    this._resultRepository,
    this._userId,
  ) : super(
        ExamSessionState(
          exam: exam,
          questions: questions,
          remainingSeconds: exam.durationInMinutes * 60,
        ),
      ) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        submitExam();
      }
    });
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
      );
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  void jumpToQuestion(int index) {
    state = state.copyWith(currentQuestionIndex: index);
  }

  void selectAnswer(String questionId, List<int> optionIndices) {
    final newAnswers = Map<String, List<int>>.from(state.selectedAnswers);
    newAnswers[questionId] = optionIndices;
    state = state.copyWith(selectedAnswers: newAnswers);
  }

  void toggleMarkForReview(String questionId) {
    final newMarked = Set<String>.from(state.markedForReview);
    if (newMarked.contains(questionId)) {
      newMarked.remove(questionId);
    } else {
      newMarked.add(questionId);
    }
    state = state.copyWith(markedForReview: newMarked);
  }

  Future<void> submitExam() async {
    _timer?.cancel();

    int correctCount = 0;
    final attemptedCount = state.selectedAnswers.keys.length;
    final Map<String, Map<String, int>> subjectStats = {};

    for (final question in state.questions) {
      subjectStats.putIfAbsent(
        question.subject,
        () => {'correct': 0, 'total': 0},
      );
      subjectStats[question.subject]!['total'] =
          subjectStats[question.subject]!['total']! + 1;

      final userAnswers = state.selectedAnswers[question.id] ?? [];
      final correctAnswers = question.correctOptionIndices;

      if (userAnswers.isNotEmpty) {
        final isCorrect =
            userAnswers.length == correctAnswers.length &&
            userAnswers.every((index) => correctAnswers.contains(index));
        if (isCorrect) {
          correctCount++;
          subjectStats[question.subject]!['correct'] =
              subjectStats[question.subject]!['correct']! + 1;
        }
      }
    }

    final score = correctCount;
    final isPassed = score >= state.exam.passingMarks;

    if (_userId != null) {
      final result = ResultEntity(
        id: '',
        examId: state.exam.id,
        userId: _userId,
        examTitle: state.exam.title,
        score: score,
        totalMarks: state.questions.length,
        correctCount: correctCount,
        incorrectCount: attemptedCount - correctCount,
        attemptedCount: attemptedCount,
        isPassed: isPassed,
        timestamp: DateTime.now(),
        subjectStats: subjectStats,
      );

      await _resultRepository.submitResult(result);
    }

    state = state.copyWith(
      isCompleted: true,
      correctCount: correctCount,
      attemptedCount: attemptedCount,
      isPassed: isPassed,
      subjectStats: subjectStats,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final activeExamSessionProvider =
    StateNotifierProvider.family<
      ExamSessionNotifier,
      ExamSessionState,
      String
    >((ref, examId) {
      // Watch the async values for initial data load.
      // Use .select to only rebuild if the value changes, not just the AsyncValue state.
      final examAsync = ref.watch(examDetailProvider(examId));
      final questionsAsync = ref.watch(examQuestionsProvider(examId));

      final resultRepo = ref.watch(resultRepositoryProvider);
      // Use ref.read for userId to ensure the session doesn't
      // recreate if the auth state flickers during the exam.
      final userId = ref.read(authStateProvider).value?.uid;

      // Ensure both exam data and questions are ready before starting the session
      final exam = examAsync.value;
      final questions = questionsAsync.value;

      if (examAsync.isLoading || questionsAsync.isLoading) {
        throw Exception('Loading exam data...');
      }

      if (exam == null) {
        throw Exception('Exam not found or not yet loaded');
      }

      if (questions == null) {
        throw Exception('Questions not found or not yet loaded');
      }

      return ExamSessionNotifier(exam, questions, resultRepo, userId);
    });
