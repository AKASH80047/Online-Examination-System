import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class QuestionBankScreen extends ConsumerWidget {
  final String examId;
  const QuestionBankScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final questionsAsync = ref.watch(examQuestionsProvider(examId));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF111827) : Colors.white);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Widget buildBody() {
      return questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline_rounded, size: 56, color: Color(0xFF0D9488)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Questions Configured',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: headingColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click Add Question to start populating this exam question bank.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtitleColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(32),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionCard(context, ref, question, cardBg, borderColor, headingColor, subtitleColor, isDark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Error loading questions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: headingColor),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtitleColor, fontSize: 13),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(examQuestionsProvider(examId)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                appBar: AdminAppBar(
                  title: 'Question Bank',
                  showLeading: false,
                  extraActions: [_buildSeedButton(context, ref)],
                ),
                body: buildBody(),
                floatingActionButton: _buildFAB(context),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AdminAppBar(
        title: 'Question Bank',
        extraActions: [_buildSeedButton(context, ref)],
      ),
      drawer: const AdminDrawer(),
      body: buildBody(),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFF0D9488),
      foregroundColor: Colors.white,
      onPressed: () => context.push(
        RoutePaths.adminAddQuestion.replaceAll(':examId', examId),
      ),
      label: const Text('Add Question', style: TextStyle(fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.add),
    );
  }

  Widget _buildSeedButton(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.playlist_add, color: Color(0xFF0D9488)),
      tooltip: 'Seed Mock MCQ Questions',
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
            options: const ['Thyroid gland', 'Pituitary gland', 'Adrenal gland', 'Pancreas'],
            correctOptionIndices: const [1],
            explanation: 'The pituitary gland is called the master gland because it controls the functions of many other endocrine glands.',
            type: QuestionType.single,
            subject: 'General Science',
            difficulty: DifficultyLevel.easy,
          ),
          QuestionEntity(
            id: '',
            text: 'What is the pH value of a neutral solution?',
            options: const ['0', '7', '10', '14'],
            correctOptionIndices: const [1],
            explanation: 'A neutral solution, such as pure water, has a pH value of exactly 7.',
            type: QuestionType.single,
            subject: 'Chemistry',
            difficulty: DifficultyLevel.easy,
          ),
          QuestionEntity(
            id: '',
            text: 'In the context of electricity, what is the SI unit of electric potential difference?',
            options: const ['Ampere', 'Ohm', 'Volt', 'Watt'],
            correctOptionIndices: const [2],
            explanation: 'The SI unit of electric potential difference is Volt (V).',
            type: QuestionType.single,
            subject: 'Physics',
            difficulty: DifficultyLevel.medium,
          ),
          QuestionEntity(
            id: '',
            text: 'The first Prime Minister of independent India was:',
            options: const ['Mahatma Gandhi', 'Sardar Vallabhbhai Patel', 'Dr. B.R. Ambedkar', 'Jawaharlal Nehru'],
            correctOptionIndices: const [3],
            explanation: 'Jawaharlal Nehru was the first Prime Minister of independent India from 1947 to 1964.',
            type: QuestionType.single,
            subject: 'Social Studies',
            difficulty: DifficultyLevel.easy,
          ),
          QuestionEntity(
            id: '',
            text: 'Which of these metals is the best conductor of electricity?',
            options: const ['Silver', 'Copper', 'Aluminum', 'Iron'],
            correctOptionIndices: const [0],
            explanation: 'Silver is the best conductor of electricity due to its high density of free electrons.',
            type: QuestionType.single,
            subject: 'Physics',
            difficulty: DifficultyLevel.medium,
          ),
          QuestionEntity(
            id: '',
            text: 'If a polynomial is represented as x² - 3x + 2 = 0, what are its roots?',
            options: const ['1 and -2', '-1 and 2', '1 and 2', '-1 and -2'],
            correctOptionIndices: const [2],
            explanation: 'Factoring x² - 3x + 2 = 0 gives (x - 1)(x - 2) = 0, so the roots are x = 1 and x = 2.',
            type: QuestionType.single,
            subject: 'Mathematics',
            difficulty: DifficultyLevel.hard,
          ),
          QuestionEntity(
            id: '',
            text: 'Which country is known as the birthplace of democracy?',
            options: const ['Rome', 'India', 'Greece', 'Egypt'],
            correctOptionIndices: const [2],
            explanation: 'Athens, Greece is historically recognized as the birthplace of democracy.',
            type: QuestionType.single,
            subject: 'Social Studies',
            difficulty: DifficultyLevel.easy,
          ),
          QuestionEntity(
            id: '',
            text: 'What is the process by which plants prepare their own food?',
            options: const ['Respiration', 'Transpiration', 'Photosynthesis', 'Digestion'],
            correctOptionIndices: const [2],
            explanation: 'Plants prepare their own food through photosynthesis using sunlight, water, and carbon dioxide.',
            type: QuestionType.single,
            subject: 'Biology',
            difficulty: DifficultyLevel.easy,
          ),
          QuestionEntity(
            id: '',
            text: 'Which of the following is considered a non-renewable energy source?',
            options: const ['Solar energy', 'Wind energy', 'Coal', 'Hydroelectric energy'],
            correctOptionIndices: const [2],
            explanation: 'Coal is a fossil fuel and a non-renewable resource because it takes millions of years to form.',
            type: QuestionType.single,
            subject: 'Geography',
            difficulty: DifficultyLevel.easy,
          ),
          QuestionEntity(
            id: '',
            text: 'In a circle, if the radius is 7 cm, what is its circumference?',
            options: const ['22 cm', '44 cm', '154 cm', '3.14 cm'],
            correctOptionIndices: const [1],
            explanation: 'Circumference = 2 * pi * r = 2 * (22/7) * 7 = 44 cm.',
            type: QuestionType.single,
            subject: 'Mathematics',
            difficulty: DifficultyLevel.medium,
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
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    WidgetRef ref,
    QuestionEntity question,
    Color cardBg,
    Color borderColor,
    Color headingColor,
    Color subtitleColor,
    bool isDark,
  ) {
    Color difficultyColor = const Color(0xFF10B981); // Green
    if (question.difficulty == DifficultyLevel.medium) {
      difficultyColor = const Color(0xFFF59E0B); // Amber
    } else if (question.difficulty == DifficultyLevel.hard) {
      difficultyColor = const Color(0xFFEF4444); // Red
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.help_outline_rounded, color: Color(0xFF0D9488), size: 22),
          ),
          title: Text(
            question.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, color: headingColor, fontSize: 15),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.subject.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question.difficulty.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: difficultyColor),
                  ),
                ),
              ],
            ),
          ),
          trailing: GestureDetector(
            onTap: () {}, // Intercept taps to prevent tile expansion toggle
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF0D9488), size: 20),
                  onPressed: () => context.push(
                    RoutePaths.adminEditQuestion.replaceAll(':examId', examId),
                    extra: question,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Question?'),
                        content: const Text('Are you sure you want to delete this question? This action is permanent.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(examRepositoryProvider).deleteQuestion(examId, question.id);
                      ref.invalidate(examQuestionsProvider(examId));
                    }
                  },
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 20, color: borderColor),
                  Text('Options List:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: subtitleColor)),
                  const SizedBox(height: 8),
                  ...question.options.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final text = entry.value;
                    final isCorrect = question.correctOptionIndices.contains(idx);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: isCorrect ? const Color(0xFF10B981) : (isDark ? const Color(0xFF475569) : Colors.grey),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${String.fromCharCode(65 + idx)}. $text',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                              color: isCorrect
                                  ? const Color(0xFF10B981)
                                  : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (question.explanation != null && question.explanation!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('Explanation:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: subtitleColor)),
                    const SizedBox(height: 4),
                    Text(
                      question.explanation!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
