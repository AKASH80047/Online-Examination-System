import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_paper/exam_entity.dart';

class ExamModel extends ExamEntity {
  const ExamModel({
    required super.id,
    required super.title,
    required super.description,
    required super.durationInMinutes,
    required super.totalMarks,
    required super.passingMarks,
    required super.category,
    required super.createdAt,
    required super.isPublished,
    super.isInstantFeedback = false,
    super.questions,
  });

  factory ExamModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExamModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      durationInMinutes: data['durationInMinutes'] ?? 0,
      totalMarks: data['totalMarks'] ?? 0,
      passingMarks: data['passingMarks'] ?? 0,
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? false,
      isInstantFeedback: data['isInstantFeedback'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'durationInMinutes': durationInMinutes,
      'totalMarks': totalMarks,
      'passingMarks': passingMarks,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublished': isPublished,
      'isInstantFeedback': isInstantFeedback,
    };
  }

  ExamEntity toEntity() => ExamEntity(
    id: id,
    title: title,
    description: description,
    durationInMinutes: durationInMinutes,
    totalMarks: totalMarks,
    passingMarks: passingMarks,
    category: category,
    createdAt: createdAt,
    isPublished: isPublished,
    isInstantFeedback: isInstantFeedback,
  );
}
