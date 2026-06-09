import 'package:equatable/equatable.dart';
import 'package:exam_paper/question_entity.dart';

class ExamEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final int durationInMinutes;
  final int totalMarks;
  final int passingMarks;
  final String category;
  final DateTime createdAt;
  final bool isPublished;
  final bool isInstantFeedback;
  final List<QuestionEntity>? questions;

  const ExamEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.durationInMinutes,
    required this.totalMarks,
    required this.passingMarks,
    required this.category,
    required this.createdAt,
    required this.isPublished,
    this.isInstantFeedback = false,
    this.questions,
  });

  int get durationMinutes => durationInMinutes;
  int get passingPercentage => totalMarks > 0 ? ((passingMarks / totalMarks) * 100).round() : 0;
  bool get instantFeedback => isInstantFeedback;

  ExamEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? durationInMinutes,
    int? totalMarks,
    int? passingMarks,
    String? category,
    DateTime? createdAt,
    bool? isPublished,
    bool? isInstantFeedback,
    List<QuestionEntity>? questions,
  }) {
    return ExamEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      totalMarks: totalMarks ?? this.totalMarks,
      passingMarks: passingMarks ?? this.passingMarks,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isPublished: isPublished ?? this.isPublished,
      isInstantFeedback: isInstantFeedback ?? this.isInstantFeedback,
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    durationInMinutes,
    totalMarks,
    passingMarks,
    category,
    createdAt,
    isPublished,
    isInstantFeedback,
    questions,
  ];
}
