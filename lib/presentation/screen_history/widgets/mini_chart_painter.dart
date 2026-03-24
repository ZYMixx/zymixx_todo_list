import 'dart:math' as math;
import 'package:flutter/material.dart';

class MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double animationValue;

  MiniChartPainter({
    required this.data,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    double maxData = data.reduce(math.max);
    if (maxData == 0) maxData = 1;

    Path path = Path();
    double stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      double x = i * stepX;
      double y = size.height -
          (data[i] / maxData) * size.height * 0.45 -
          size.height * 0.30;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        double prevX = (i - 1) * stepX;
        double prevY = size.height -
            (data[i - 1] / maxData) * size.height * 0.45 -
            size.height * 0.30;

        // Smooth curve
        path.cubicTo(
          prevX + (x - prevX) * 0.4,
          prevY,
          prevX + (x - prevX) * 0.6,
          y,
          x,
          y,
        );
      }
    }

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.10)
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, glowPaint);

    final softPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.16)
      ..strokeWidth = 5;
    canvas.drawPath(path, softPaint);

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 2.2;
    canvas.drawPath(path, corePaint);

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.last;

    final double runnerBase = (animationValue * 0.666) % 1.0;
    final List<double> phases = [
      runnerBase,
      (runnerBase + 0.33) % 1.0,
      (runnerBase + 0.66) % 1.0,
    ];

    for (final phase in phases) {
      final double distance = metric.length * phase;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent == null) continue;
      final pos = tangent.position;

      final double tailLength = math.min(metric.length * 0.12, 26);
      final double start = (distance - tailLength).clamp(0.0, metric.length);
      final double end = distance;
      final extractPath = metric.extractPath(start, end);

      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4.0
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.28),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(extractPath, trailPaint);

      final Rect runnerRect = Rect.fromCircle(center: pos, radius: 10);
      final runnerPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.30),
            color.withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(runnerRect)
        ..blendMode = BlendMode.screen;
      canvas.drawCircle(pos, 10, runnerPaint);
      canvas.drawCircle(
        pos,
        3.2,
        Paint()..color = color.withValues(alpha: 0.42),
      );
    }

    // Arrow at the end
    final endMetric = metric;
    final tangent = endMetric.getTangentForOffset(endMetric.length);
    if (tangent != null) {
      final pos = tangent.position;
      final angle = tangent.angle;

      final arrowPath = Path();
      const arrowSize = 5.0;
      arrowPath.moveTo(pos.dx, pos.dy);
      arrowPath.lineTo(
        pos.dx - arrowSize * math.cos(angle - 0.5),
        pos.dy - arrowSize * math.sin(angle - 0.5),
      );
      arrowPath.lineTo(
        pos.dx - arrowSize * math.cos(angle + 0.5),
        pos.dy - arrowSize * math.sin(angle + 0.5),
      );
      arrowPath.close();
      canvas.drawPath(
        arrowPath,
        Paint()..color = color.withValues(alpha: 0.60),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MiniChartPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.color != color ||
      oldDelegate.data != data;
}
