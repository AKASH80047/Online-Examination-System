import 'package:equatable/equatable.dart';

enum QuestionType { single, multiple, trueFalse }

class QuestionEntity extends Equatable {
  final String id;
  final String text;
  final List<String> options;
  final List<int> correctOptionIndices;
  final String? explanation;
  final String? imageUrl;
  final QuestionType type;
  final String subject;

  const QuestionEntity({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndices,
    this.explanation,
    this.imageUrl,
    required this.type,
    required this.subject,
  });

  @override
  List<Object?> get props => [
    id,
    text,
    options,
    correctOptionIndices,
    explanation,
    imageUrl,
    type,
    subject,
  ];
}
