import 'package:flutter/material.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _targetAudience = 'all';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSending = false);
      _titleController.clear();
      _bodyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Notification broadcasted successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    final audiences = [
      _AudienceOption(value: 'all', label: 'All Users', icon: Icons.people_rounded, color: const Color(0xFF4F46E5)),
      _AudienceOption(value: 'student', label: 'Students Only', icon: Icons.school_rounded, color: const Color(0xFF10B981)),
      _AudienceOption(value: 'admin', label: 'Admins Only', icon: Icons.admin_panel_settings_rounded, color: const Color(0xFFEF4444)),
    ];

    Widget buildBody() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Broadcast Notification',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Send instant push alerts to students and admins via Firebase Cloud Messaging.',
                                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Target Audience selector
                  const Text(
                    'Target Audience',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: audiences.map((a) {
                      final selected = _targetAudience == a.value;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _targetAudience = a.value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: selected ? a.color.withValues(alpha: 0.1) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected ? a.color : const Color(0xFFE5E7EB),
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(a.icon, color: selected ? a.color : const Color(0xFF9CA3AF), size: 22),
                                  const SizedBox(height: 6),
                                  Text(
                                    a.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                      color: selected ? a.color : const Color(0xFF6B7280),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // Form fields
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Compose Message',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Notification Title',
                            prefixIcon: const Icon(Icons.title_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bodyController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Message Body',
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 64),
                              child: Icon(Icons.message_outlined),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Message body is required' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _isSending ? null : _send,
                            icon: _isSending
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send_rounded),
                            label: Text(_isSending ? 'Sending...' : 'Send Broadcast'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
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
        backgroundColor: const Color(0xFFF9FAFB),
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFFF9FAFB),
                appBar: const AdminAppBar(title: 'Send Notification', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const AdminAppBar(title: 'Send Notification'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }
}

class _AudienceOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _AudienceOption({required this.value, required this.label, required this.icon, required this.color});
}
