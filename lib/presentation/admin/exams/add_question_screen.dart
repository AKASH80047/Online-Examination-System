import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class AddQuestionScreen extends ConsumerStatefulWidget {
  final String examId;
  const AddQuestionScreen({super.key, required this.examId});

  @override
  ConsumerState<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends ConsumerState<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _explanationController = TextEditingController();
  final _subjectController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];

  QuestionType _type = QuestionType.single;
  DifficultyLevel _difficulty = DifficultyLevel.medium;
  List<int> _correctIndices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addOption();
    _addOption();
  }

  void _addOption() {
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      _correctIndices.removeWhere((i) => i == index);
      _correctIndices = _correctIndices.map((i) => i > index ? i - 1 : i).toList();
    });
  }

  void _toggleCorrect(int index) {
    setState(() {
      if (_type == QuestionType.single || _type == QuestionType.trueFalse) {
        _correctIndices = [index];
      } else {
        if (_correctIndices.contains(index)) {
          _correctIndices.remove(index);
        } else {
          _correctIndices.add(index);
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_correctIndices.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one correct answer option')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final question = QuestionEntity(
        id: '',
        text: _textController.text.trim(),
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        correctOptionIndices: _correctIndices,
        explanation: _explanationController.text.trim(),
        type: _type,
        subject: _subjectController.text.trim(),
        difficulty: _difficulty,
      );

      await ref.read(examRepositoryProvider).addQuestion(widget.examId, question);

      ref.invalidate(examQuestionsProvider(widget.examId));
      if (!mounted) return;
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _explanationController.dispose();
    _subjectController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final cardBg = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF111827) : Colors.white);
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Widget buildBody() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Question to Bank',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: headingColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configure property fields, options list, and question texts.',
                    style: TextStyle(fontSize: 15, color: subtitleColor),
                  ),
                  const SizedBox(height: 32),

                  // Type & difficulty meta-card
                  _buildMetaCard(cardBg, borderColor, headingColor, subtitleColor),
                  const SizedBox(height: 20),

                  // Content card
                  _buildContentCard(cardBg, borderColor, headingColor, subtitleColor),
                  const SizedBox(height: 20),

                  // Option selections card
                  _buildOptionsCard(cardBg, borderColor, headingColor, subtitleColor, isDark),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Question to Bank', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
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
                appBar: const AdminAppBar(title: 'Add Question', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const AdminAppBar(title: 'Add Question'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }

  Widget _buildMetaCard(Color cardBg, Color borderColor, Color headingColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question Properties', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: headingColor)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<QuestionType>(
                  initialValue: _type,
                  style: TextStyle(color: headingColor),
                  dropdownColor: cardBg,
                  decoration: InputDecoration(
                    labelText: 'Evaluation Style',
                    labelStyle: TextStyle(color: subtitleColor),
                  ),
                  items: QuestionType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _type = val!;
                      if (_type == QuestionType.trueFalse) {
                        _optionControllers.clear();
                        _optionControllers.add(TextEditingController(text: 'True'));
                        _optionControllers.add(TextEditingController(text: 'False'));
                      }
                      _correctIndices.clear();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<DifficultyLevel>(
                  initialValue: _difficulty,
                  style: TextStyle(color: headingColor),
                  dropdownColor: cardBg,
                  decoration: InputDecoration(
                    labelText: 'Difficulty Level',
                    labelStyle: TextStyle(color: subtitleColor),
                  ),
                  items: DifficultyLevel.values
                      .map((d) => DropdownMenuItem(value: d, child: Text(d.name.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setState(() => _difficulty = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _subjectController,
            style: TextStyle(color: headingColor),
            decoration: InputDecoration(
              labelText: 'Subject (e.g. Mathematics, General Science)',
              labelStyle: TextStyle(color: subtitleColor),
              prefixIcon: Icon(Icons.subject, color: subtitleColor),
            ),
            validator: (v) => v!.isEmpty ? 'Required field' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Color cardBg, Color borderColor, Color headingColor, Color subtitleColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: headingColor)),
          const SizedBox(height: 20),
          TextFormField(
            controller: _textController,
            maxLines: 3,
            style: TextStyle(color: headingColor),
            decoration: InputDecoration(
              labelText: 'Write the question text here...',
              labelStyle: TextStyle(color: subtitleColor),
              alignLabelWithHint: true,
            ),
            validator: (v) => v!.isEmpty ? 'Required field' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _explanationController,
            maxLines: 2,
            style: TextStyle(color: headingColor),
            decoration: InputDecoration(
              labelText: 'Add optional explanation / answer logic...',
              labelStyle: TextStyle(color: subtitleColor),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(Color cardBg, Color borderColor, Color headingColor, Color subtitleColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Option Choices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: headingColor)),
          const SizedBox(height: 6),
          Text('Check the circle/box on the left to designate correct responses.', style: TextStyle(color: subtitleColor, fontSize: 13)),
          const SizedBox(height: 20),
          ..._optionControllers.asMap().entries.map((entry) {
            final idx = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _correctIndices.contains(idx),
                    onChanged: (_) => _toggleCorrect(idx),
                    shape: _type == QuestionType.multiple ? null : const CircleBorder(),
                    activeColor: const Color(0xFF0D9488),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: entry.value,
                      readOnly: _type == QuestionType.trueFalse,
                      style: TextStyle(color: headingColor),
                      decoration: InputDecoration(
                        labelText: 'Option Choice ${String.fromCharCode(65 + idx)}',
                        labelStyle: TextStyle(color: subtitleColor),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required field' : null,
                    ),
                  ),
                  if (_type != QuestionType.trueFalse)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => _removeOption(idx),
                    ),
                ],
              ),
            );
          }),
          if (_type != QuestionType.trueFalse)
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, color: Color(0xFF0D9488)),
              label: const Text('Add Option Row', style: TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}
