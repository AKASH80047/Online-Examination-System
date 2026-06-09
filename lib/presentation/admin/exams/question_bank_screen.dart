import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/question_entity.dart';

class QuestionBankScreen extends ConsumerWidget {
  final String examId;
  const QuestionBankScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(examQuestionsProvider(examId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Seed 10 MCQ Questions',
            onPressed: () async {
              final repo = ref.read(examRepositoryProvider);
              final messenger = ScaffoldMessenger.of(context);
              
              messenger.showSnackBar(
                const SnackBar(content: Text('Seeding 10 MCQ questions...')),
              );

              final mockQuestions = [
                QuestionEntity(
                  id: '',
                  text: 'Which gland is known as the "master gland" in the human body?',
                  options: ['Thyroid gland', 'Pituitary gland', 'Adrenal gland', 'Pancreas'],
                  correctOptionIndices: [1],
                  explanation: 'The pituitary gland is called the master gland because it controls the functions of many other endocrine glands.',
                  type: QuestionType.single,
                  subject: 'General Science',
                ),
                QuestionEntity(
                  id: '',
                  text: 'What is the pH value of a neutral solution?',
                  options: ['0', '7', '10', '14'],
                  correctOptionIndices: [1],
                  explanation: 'A neutral solution, such as pure water, has a pH value of exactly 7.',
                  type: QuestionType.single,
                  subject: 'General Science',
                ),
                QuestionEntity(
                  id: '',
                  text: 'In the context of electricity, what is the SI unit of electric potential difference?',
                  options: ['Ampere', 'Ohm', 'Volt', 'Watt'],
                  correctOptionIndices: [2],
                  explanation: 'The SI unit of electric potential difference is Volt (V).',
                  type: QuestionType.single,
                  subject: 'General Science',
                ),
                QuestionEntity(
                  id: '',
                  text: 'The first Prime Minister of independent India was:',
                  options: ['Mahatma Gandhi', 'Sardar Vallabhbhai Patel', 'Dr. B.R. Ambedkar', 'Jawaharlal Nehru'],
                  correctOptionIndices: [3],
                  explanation: 'Jawaharlal Nehru was the first Prime Minister of independent India from 1947 to 1964.',
                  type: QuestionType.single,
                  subject: 'Social Studies',
                ),
                QuestionEntity(
                  id: '',
                  text: 'Which of these metals is the best conductor of electricity?',
                  options: ['Silver', 'Copper', 'Aluminum', 'Iron'],
                  correctOptionIndices: [0],
                  explanation: 'Silver is the best conductor of electricity due to its high density of free electrons.',
                  type: QuestionType.single,
                  subject: 'General Science',
                ),
                QuestionEntity(
                  id: '',
                  text: 'If a polynomial is represented as x² - 3x + 2 = 0, what are its roots?',
                  options: ['1 and -2', '-1 and 2', '1 and 2', '-1 and -2'],
                  correctOptionIndices: [2],
                  explanation: 'Factoring x² - 3x + 2 = 0 gives (x - 1)(x - 2) = 0, so the roots are x = 1 and x = 2.',
                  type: QuestionType.single,
                  subject: 'Mathematics',
                ),
                QuestionEntity(
                  id: '',
                  text: 'Which country is known as the birthplace of democracy?',
                  options: ['Rome', 'India', 'Greece', 'Egypt'],
                  correctOptionIndices: [2],
                  explanation: 'Athens, Greece is historically recognized as the birthplace of democracy.',
                  type: QuestionType.single,
                  subject: 'Social Studies',
                ),
                QuestionEntity(
                  id: '',
                  text: 'What is the process by which plants prepare their own food?',
                  options: ['Respiration', 'Transpiration', 'Photosynthesis', 'Digestion'],
                  correctOptionIndices: [2],
                  explanation: 'Plants prepare their own food through photosynthesis using sunlight, water, and carbon dioxide.',
                  type: QuestionType.single,
                  subject: 'General Science',
                ),
                QuestionEntity(
                  id: '',
                  text: 'Which of the following is considered a non-renewable energy source?',
                  options: ['Solar energy', 'Wind energy', 'Coal', 'Hydroelectric energy'],
                  correctOptionIndices: [2],
                  explanation: 'Coal is a fossil fuel and a non-renewable resource because it takes millions of years to form.',
                  type: QuestionType.single,
                  subject: 'Social Studies',
                ),
                QuestionEntity(
                  id: '',
                  text: 'In a circle, if the radius is 7 cm, what is its circumference?',
                  options: ['22 cm', '44 cm', '154 cm', '3.14 cm'],
                  correctOptionIndices: [1],
                  explanation: 'Circumference = 2 * pi * r = 2 * (22/7) * 7 = 44 cm.',
                  type: QuestionType.single,
                  subject: 'Mathematics',
                ),
              ];

              try {
                for (final q in mockQuestions) {
                  await repo.addQuestion(examId, q);
                }
                ref.invalidate(examQuestionsProvider(examId));
                messenger.showSnackBar(
                  const SnackBar(content: Text('Successfully added 10 MCQ questions!')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to seed questions: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text('No questions added yet.'));
          }
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    question.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Type: ${question.type.name} • Options: ${question.options.length}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Question'),
                              content: const Text(
                                'Are you sure you want to delete this question?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(examRepositoryProvider)
                                .deleteQuestion(examId, question.id);
                            ref.invalidate(examQuestionsProvider(examId));
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () => context.push(
                    RoutePaths.adminEditQuestion.replaceAll(':examId', examId),
                    extra: question,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          RoutePaths.adminAddQuestion.replaceAll(':examId', examId),
        ),
        label: const Text('Add Question'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
