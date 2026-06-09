import 'package:flutter/material.dart';

class DashboardChart extends StatelessWidget {
  const DashboardChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exam Attempts & Activity',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Weekly overview of test submissions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  value: '7days',
                  underline: const SizedBox(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  items: const [
                    DropdownMenuItem(value: '7days', child: Text('Last 7 Days')),
                    DropdownMenuItem(value: '30days', child: Text('Last 30 Days')),
                  ],
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: _ChartPainter(
                  primaryColor: Theme.of(context).colorScheme.primary,
                  secondaryColor: Theme.of(context).colorScheme.secondary,
                  textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  gridColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(context, 'Exam Attempts', Theme.of(context).colorScheme.primary),
                const SizedBox(width: 24),
                _buildLegendItem(context, 'Pass Rate (%)', Theme.of(context).colorScheme.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color gridColor;

  _ChartPainter({
    required this.primaryColor,
    required this.secondaryColor,
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

    // Draw horizontal grids & labels
    const gridLines = 4;
    final rowHeight = size.height / gridLines;
    for (var i = 0; i <= gridLines; i++) {
      final y = size.height - (i * rowHeight);
      canvas.drawLine(Offset(30, y), Offset(size.width, y), gridPaint);

      // Label (0 to 100)
      final labelVal = (i * 25).toString();
      textPainter.text = TextSpan(
        text: labelVal,
        style: TextStyle(color: textColor, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // Chart Data (Mocking 7 days: Mon, Tue, Wed, Thu, Fri, Sat, Sun)
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final attempts = [45, 62, 85, 50, 75, 90, 60]; // Primary values (mapped to 0-100 scale)
    final passRates = [70, 75, 80, 78, 85, 88, 82]; // Secondary values (mapped to 0-100 scale)

    final colWidth = (size.width - 30) / days.length;

    // Draw columns / bars for attempts and lines for passRate
    final barPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    final points = <Offset>[];

    for (var i = 0; i < days.length; i++) {
      final x = 30 + (i * colWidth) + (colWidth / 2);

      // Draw bars (Attempts)
      final barHeight = (attempts[i] / 100) * size.height;
      final barTop = size.height - barHeight;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(x - 8, barTop, x + 8, size.height),
          const Radius.circular(4),
        ),
        barPaint,
      );

      // Draw line points (Pass rates)
      final lineY = size.height - ((passRates[i] / 100) * size.height);
      points.add(Offset(x, lineY));

      // Draw x-axis label
      textPainter.text = TextSpan(
        text: days[i],
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w500),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 4));
    }

    // Draw connecting line for pass rates
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Draw dots on path
    for (final pt in points) {
      canvas.drawCircle(pt, 5, dotPaint);
      canvas.drawCircle(pt, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
