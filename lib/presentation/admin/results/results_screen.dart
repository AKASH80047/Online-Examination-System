import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    // Mock data
    final results = [
      _ResultItem(id: 'R001', name: 'John Doe', examTitle: 'Science Quiz 101', score: 85, passed: true, date: 'June 03, 2026'),
      _ResultItem(id: 'R002', name: 'Jane Smith', examTitle: 'Science Quiz 101', score: 92, passed: true, date: 'June 02, 2026'),
      _ResultItem(id: 'R003', name: 'Robert Johnson', examTitle: 'Math Foundations', score: 55, passed: false, date: 'May 30, 2026'),
      _ResultItem(id: 'R004', name: 'Emily Davis', examTitle: 'Math Foundations', score: 78, passed: true, date: 'May 28, 2026'),
      _ResultItem(id: 'R005', name: 'Michael Wilson', examTitle: 'Python Development', score: 45, passed: false, date: 'May 15, 2026'),
    ];

    Widget buildBody() {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Summary row
          Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  label: 'Total',
                  value: results.length.toString(),
                  color: const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  label: 'Passed',
                  value: results.where((r) => r.passed).length.toString(),
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  label: 'Failed',
                  value: results.where((r) => !r.passed).length.toString(),
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search + Export row
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by student or exam...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.push(RoutePaths.adminExportResults),
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Results list
          ...results.map((res) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push(
                    RoutePaths.adminResultDetails.replaceAll(':resultId', res.id),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Score Circle
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: res.passed
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEE2E2),
                          ),
                          child: Center(
                            child: Text(
                              '${res.score}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: res.passed ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                res.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                res.examTitle,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                res.date,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: res.passed
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                res.passed ? 'PASSED' : 'FAILED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: res.passed ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
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
                appBar: const AdminAppBar(title: 'Exam Results', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const AdminAppBar(title: 'Exam Results'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultItem {
  final String id;
  final String name;
  final String examTitle;
  final int score;
  final bool passed;
  final String date;

  _ResultItem({
    required this.id,
    required this.name,
    required this.examTitle,
    required this.score,
    required this.passed,
    required this.date,
  });
}
