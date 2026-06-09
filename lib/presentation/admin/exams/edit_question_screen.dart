import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/question_entity.dart';
import 'package:exam_paper/exam_providers.dart';

class EditQuestionScreen extends ConsumerStatefulWidget {
  final String examId;
  final QuestionEntity question;

  const EditQuestionScreen({super.key, required this.examId, required this.question});

  @override
  ConsumerState<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends ConsumerState<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _explanationController = TextEditingController();
  final _subjectController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];

  QuestionType _type = QuestionType.single;
  List<int> _correctIndices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.question.text;
    _explanationController.text = widget.question.explanation ?? '';
    _subjectController.text = widget.question.subject;
    _type = widget.question.type;
    _correctIndices = List.from(widget.question.correctOptionIndices);
    for (var opt in widget.question.options) {
      _optionControllers.add(TextEditingController(text: opt));
    }
  }

  void _addOption() {
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      _correctIndices.removeWhere((i) => i == index);
      _correctIndices = _correctIndices
          .map((i) => i > index ? i - 1 : i)
          .toList();
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
        const SnackBar(content: Text('Select at least one correct answer')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final question = QuestionEntity(
        id: widget.question.id,
        text: _textController.text.trim(),
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        correctOptionIndices: _correctIndices,
        explanation: _explanationController.text.trim(),
        type: _type,
        subject: _subjectController.text.trim(),
      );

      await ref
          .read(examRepositoryProvider)
          .updateQuestion(widget.examId, question);

      ref.invalidate(examQuestionsProvider(widget.examId));
      if (!mounted) return;
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Question'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<QuestionType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Question Type',
                border: OutlineInputBorder(),
              ),
              items: QuestionType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _type = val!;
                  if (_type == QuestionType.trueFalse) {
                    _optionControllers.clear();
                    _optionControllers.add(TextEditingController(text: 'True'));
                    _optionControllers.add(
                      TextEditingController(text: 'False'),
                    );
                  }
                  _correctIndices.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject (e.g., Mathematics, Physics)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Check the circle/box to mark as correct'),
            const SizedBox(height: 8),
            ..._optionControllers.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _correctIndices.contains(index),
                      onChanged: (_) => _toggleCorrect(index),
                      shape: _type == QuestionType.multiple
                          ? null
                          : const CircleBorder(),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        readOnly: _type == QuestionType.trueFalse,
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    if (_type != QuestionType.trueFalse)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeOption(index),
                      ),
                  ],
                ),
              );
            }),
            if (_type != QuestionType.trueFalse)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _explanationController,
              decoration: const InputDecoration(
                labelText: 'Explanation (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Question'),
            ),
          ],
        ),
      ),
    );
  }
}
