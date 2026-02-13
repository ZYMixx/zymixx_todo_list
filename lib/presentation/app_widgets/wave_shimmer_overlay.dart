import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';

class WaveShimmerOverlay extends StatefulWidget {
  final String id;
  final Widget child;

  const WaveShimmerOverlay({
    super.key,
    required this.id,
    required this.child,
  });

  @override
  State<WaveShimmerOverlay> createState() => WaveShimmerOverlayState();
}

class WaveShimmerOverlayState extends State<WaveShimmerOverlay>
    with SingleTickerProviderStateMixin {
  static final Map<String, Color> cachedColorById = {};

  AnimationController? animationController;
  Color? color;

  @override
  void initState() {
    super.initState();

    color = cachedColorById[widget.id] ?? randomColorFromTheme(widget.id);
    cachedColorById[widget.id] = color!;

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController controller = animationController!;
    final Color shimmerColor = color!;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final double t = controller.value;

                final double alpha =
                    0.10 + 0.05 * sin(2 * pi * t); // 0.05..0.15
                final Color c = shimmerColor.withValues(
                  alpha: alpha.clamp(0.05, 0.15),
                );

                return CustomPaint(
                  painter: WaveShimmerPainter(
                    progress: t,
                    color: c,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color randomColorFromTheme(String seed) {
    final List<Color> colors = [
      ToolThemeData.itemBorderColor,
      ToolThemeData.highlightColor,
      ToolThemeData.specialItemColor,
      ToolThemeData.mainGreenColor,
      ToolThemeData.highlightGreenColor,
    ];

    final int stableSeed = seed.hashCode;
    final Random random = Random(stableSeed);
    return colors[random.nextInt(colors.length)];
  }
}

class WaveShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  WaveShimmerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final double y = -height * 0.25 + (height * 1.5) * progress;
    final double amplitude = min(60.0, height * 0.14);
    final double thickness = min(46.0, height * 0.10);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = color
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final Path path = Path();
    final double step = max(6.0, width / 60);

    for (double x = 0; x <= width; x += step) {
      final double dx = (x / width) - 0.5;
      final double curve = amplitude * (dx * dx) * 4;
      final double py = y - curve;
      if (x == 0) {
        path.moveTo(x, py);
      } else {
        path.lineTo(x, py);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
