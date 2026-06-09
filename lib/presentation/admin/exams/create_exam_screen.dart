import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/exam_entity.dart';
import 'package:exam_paper/exam_providers.dart';

class CreateExamScreen extends ConsumerStatefulWidget {
  const CreateExamScreen({super.key});

  @override
  ConsumerState<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends ConsumerState<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _totalMarksController = TextEditingController();
  final _passingMarksController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isPublished = false;
  bool _isInstantFeedback = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _totalMarksController.dispose();
    _passingMarksController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _createExam() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final newExam = ExamEntity(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          durationInMinutes: int.parse(_durationController.text.trim()),
          totalMarks: int.parse(_totalMarksController.text.trim()),
          passingMarks: int.parse(_passingMarksController.text.trim()),
          category: _categoryController.text.trim(),
          createdAt: DateTime.now(),
          isPublished: _isPublished,
          isInstantFeedback: _isInstantFeedback,
        );

        await ref.read(examRepositoryProvider).createExam(newExam);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exam created successfully!')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create exam: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Create New Exam', style: TextStyle(color: Color(0xFF1F2937))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    title: 'Basic Details',
                    children: [
                      _buildTextField(controller: _titleController, label: 'Exam Title', icon: Icons.title),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _descriptionController, label: 'Description', icon: Icons.description, maxLines: 3),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _categoryController, label: 'Category (e.g., Math, Science)', icon: Icons.category),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Rules & Scoring',
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildTextField(controller: _durationController, label: 'Duration (mins)', icon: Icons.timer, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(controller: _totalMarksController, label: 'Total Marks', icon: Icons.score, isNumber: true)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField(controller: _passingMarksController, label: 'Passing Marks', icon: Icons.grading, isNumber: true)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Settings',
                    children: [
                      SwitchListTile(
                        title: const Text('Publish Exam Immediately'),
                        subtitle: const Text('Students can see and take this exam right away.'),
                        value: _isPublished,
                        activeTrackColor: const Color(0xFF4F46E5),
                        onChanged: (value) => setState(() => _isPublished = value),
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Instant Feedback'),
                        subtitle: const Text('Show correct answers instantly during the test.'),
                        value: _isInstantFeedback,
                        activeTrackColor: const Color(0xFF4F46E5),
                        onChanged: (value) => setState(() => _isInstantFeedback = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createExam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Create Exam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (isNumber && int.tryParse(value) == null) return 'Must be a number';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
    );
  }
}
