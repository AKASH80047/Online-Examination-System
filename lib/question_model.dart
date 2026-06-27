import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_paper/question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.text,
    required super.options,
    required super.correctOptionIndices,
    super.explanation,
    super.imageUrl,
    required super.type,
    required super.subject,
    required super.difficulty,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      text: data['text'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndices: (data['correctOptionIndices'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      explanation: data['explanation'],
      imageUrl: data['imageUrl'],
      type: QuestionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => QuestionType.single,
      ),
      subject: data['subject'] ?? '',
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == data['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'options': options,
      'correctOptionIndices': correctOptionIndices,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'type': type.name,
      'subject': subject,
      'difficulty': difficulty.name,
    };
  }

  QuestionEntity toEntity() => QuestionEntity(
    id: id,
    text: text,
    options: options,
    correctOptionIndices: correctOptionIndices,
    explanation: explanation,
    imageUrl: imageUrl,
    type: type,
    subject: subject,
    difficulty: difficulty,
  );
}
