import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/exam_providers.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_stat_card.dart';

class ExamAnalyticsScreen extends ConsumerWidget {
  final String examId;
  const ExamAnalyticsScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examAsync = ref.watch(examDetailProvider(examId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Analytics Deep-dive'),
      ),
      body: examAsync.when(
        data: (exam) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                exam.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Performance and score distribution graphs',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  const statCards = [
                    AdminStatCard(
                      title: 'Total Attempts',
                      value: '48',
                      icon: Icons.assignment_outlined,
                      color: Colors.blue,
                    ),
                    AdminStatCard(
                      title: 'Average Mark',
                      value: '76.8%',
                      icon: Icons.analytics_outlined,
                      color: Colors.green,
                    ),
                    AdminStatCard(
                      title: 'Standard Deviation',
                      value: '8.4',
                      icon: Icons.insights_outlined,
                      color: Colors.purple,
                    ),
                  ];

                  if (constraints.maxWidth <= 600) {
                    return Column(
                      children: statCards
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: c,
                              ))
                          .toList(),
                    );
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.8,
                    children: statCards,
                  );
                },
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score Frequency Distribution',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _HistogramPainter(
                            barColor: Theme.of(context).colorScheme.primary,
                            textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                            gridColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: const Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.check_circle_outline, color: Colors.green),
                      title: Text('Highest Score'),
                      trailing: Text('98% (John Doe)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.remove_circle_outline, color: Colors.amber),
                      title: Text('Passing Threshold'),
                      trailing: Text('70% required', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.cancel_outlined, color: Colors.red),
                      title: Text('Lowest Score'),
                      trailing: Text('42% (Jane Austin)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _HistogramPainter extends CustomPainter {
  final Color barColor;
  final Color textColor;
  final Color gridColor;

  _HistogramPainter({
    required this.barColor,
    required this.textColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw horizontal grid lines
    const gridLines = 3;
    final rowHeight = size.height / gridLines;
    for (var i = 0; i <= gridLines; i++) {
      final y = size.height - (i * rowHeight);
      canvas.drawLine(Offset(25, y), Offset(size.width, y), gridPaint);
    }

    // Score ranges: [0-50, 50-60, 60-70, 70-80, 80-90, 90-100]
    final ranges = ['<50', '50-60', '60-70', '70-80', '80-90', '90-100'];
    final frequencies = [4, 6, 12, 18, 25, 10]; // Frequency count
    const maxFreq = 30;

    final colWidth = (size.width - 25) / ranges.length;

    final barPaint = Paint()
      ..color = barColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < ranges.length; i++) {
      final x = 25 + (i * colWidth) + (colWidth / 2);

      // Draw bar representing frequency
      final barHeight = (frequencies[i] / maxFreq) * size.height;
      final barTop = size.height - barHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x - 12, barTop, x + 12, size.height),
          const Radius.circular(3),
        ),
        barPaint,
      );

      // Value label on top of bar
      textPainter.text = TextSpan(
        text: frequencies[i].toString(),
        style: TextStyle(color: barColor, fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, barTop - 12));

      // Range label under column
      textPainter.text = TextSpan(
        text: ranges[i],
        style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
