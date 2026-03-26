import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';

enum WaveShimmerPatternType {
  parabola,
  zigzag,
  spiral,
  orb,
}

class WaveShimmerOverlay extends StatefulWidget {
  final Object? seed;
  final Widget child;

  const WaveShimmerOverlay({
    super.key,
    this.seed,
    required this.child,
  });

  @override
  State<WaveShimmerOverlay> createState() => WaveShimmerOverlayState();
}

class WaveShimmerOverlayState extends State<WaveShimmerOverlay>
    with SingleTickerProviderStateMixin {
  static const double minAlpha = 0.05;
  static const double maxAlpha = 0.14;
  static const double blurSigma = 36;
  static const double waveEdgeFade = 0.35;
  static const double sizeScale = 2.0;
  static const double spiralSpinFactor = 0.08;
  static const int maxActiveObjects = 4;
  static const double lifeExtension = 0.40;

  AnimationController? animationController;
  List<WaveObject> activeObjects = [];
  int waveSeed = 0;
  DateTime lastSpawnTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    final Object seedSource =
        widget.seed ?? widget.key ?? widget.child.runtimeType;
    waveSeed =
        DateTime.now().microsecondsSinceEpoch ^ (seedSource.hashCode * 31);

    // Инициализируем несколько объектов сразу на разных этапах жизни
    final Random random = Random(waveSeed);
    for (int i = 0; i < 2; i++) {
      activeObjects
          .add(createWaveObject(random, startProgress: random.nextDouble()));
    }

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Используем как тикер
    )..repeat();

    animationController?.addListener(_onTick);
  }

  void _onTick() {
    final DateTime now = DateTime.now();
    bool changed = false;

    // Обновляем прогресс всех объектов и удаляем завершенные
    for (int i = activeObjects.length - 1; i >= 0; i--) {
      final obj = activeObjects[i];
      final double elapsedMs =
          now.difference(obj.startTime).inMilliseconds.toDouble();
      obj.progress = elapsedMs / obj.durationMs;

      if (obj.progress > 1.0 + lifeExtension) {
        activeObjects.removeAt(i);
        changed = true;
      }
    }

    // Добавляем новые объекты, если нужно
    if (activeObjects.length < maxActiveObjects) {
      final Random random = Random();
      // Спавним новый объект не чаще чем раз в 2-3 секунды
      if (now.difference(lastSpawnTime).inSeconds >= 2 + random.nextInt(2)) {
        activeObjects.add(createWaveObject(random));
        lastSpawnTime = now;
        changed = true;
      }
    }

    if (changed || activeObjects.isNotEmpty) {
      setState(() {});
    }
  }

  WaveObject createWaveObject(Random random, {double startProgress = 0.0}) {
    final List<Color> colors = [
      ToolThemeData.itemBorderColor,
      ToolThemeData.highlightColor,
      ToolThemeData.specialItemColor,
      ToolThemeData.mainGreenColor,
      ToolThemeData.highlightGreenColor,
    ];

    final double durationMs = 8000.0 + random.nextInt(5000);
    DateTime startTime = DateTime.now();
    if (startProgress > 0) {
      startTime = startTime.subtract(
          Duration(milliseconds: (durationMs * startProgress).round()));
    }

    return WaveObject(
      patternType: WaveShimmerPatternType
          .values[random.nextInt(WaveShimmerPatternType.values.length)],
      startTime: startTime,
      durationMs: durationMs,
      progress: startProgress,
      speedFactor: 1.0,
      directionSign: random.nextBool() ? 1.0 : -1.0,
      curvatureSign: random.nextBool() ? 1.0 : -1.0,
      amplitudeFactor: 0.60 + random.nextDouble() * 0.90,
      thicknessFactor: 0.55 + random.nextDouble() * 0.85,
      driftFactor: (random.nextDouble() * 2 - 1) * 0.35,
      wobbleFactor: random.nextDouble() * 0.30,
      frequency: 1.0 + random.nextDouble() * 2.2,
      rotationSpeed: ((random.nextDouble() * 2 - 1) * 1.3) / 15.0,
      rotationPhase: random.nextDouble() * 2 * pi,
      motionPhase: random.nextDouble(),
      originX: random.nextBool() ? 0.0 : 1.0,
      originY: random.nextBool() ? 0.0 : 1.0,
      color: colors[random.nextInt(colors.length)],
    );
  }

  @override
  void dispose() {
    animationController?.removeListener(_onTick);
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TickerMode(
      enabled: true,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: WaveShimmerBackgroundPainter(
                  objects: activeObjects,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveObject {
  final WaveShimmerPatternType patternType;
  final DateTime startTime;
  final double durationMs;
  double progress;
  final double speedFactor;
  final double directionSign;
  final double curvatureSign;
  final double amplitudeFactor;
  final double thicknessFactor;
  final double driftFactor;
  final double wobbleFactor;
  final double frequency;
  final double rotationSpeed;
  final double rotationPhase;
  final double motionPhase;
  final double originX;
  final double originY;
  final Color color;

  WaveObject({
    required this.patternType,
    required this.startTime,
    required this.durationMs,
    required this.progress,
    required this.speedFactor,
    required this.directionSign,
    required this.curvatureSign,
    required this.amplitudeFactor,
    required this.thicknessFactor,
    required this.driftFactor,
    required this.wobbleFactor,
    required this.frequency,
    required this.rotationSpeed,
    required this.rotationPhase,
    required this.motionPhase,
    required this.originX,
    required this.originY,
    required this.color,
  });
}

class WaveShimmerBackgroundPainter extends CustomPainter {
  final List<WaveObject> objects;

  WaveShimmerBackgroundPainter({
    required this.objects,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final double baseAmplitude =
        WaveShimmerOverlayState.sizeScale * min(60.0, height * 0.14);
    final double baseThickness =
        WaveShimmerOverlayState.sizeScale * min(46.0, height * 0.10);
    final double step = max(6.0, width / 60);

    for (final WaveObject obj in objects) {
      double waveT = obj.progress;
      if (obj.directionSign < 0) {
        waveT = 1.0 - waveT;
      }

      final double fadeMain =
          sin(pi * obj.progress.clamp(0.0, 1.0)).clamp(0.0, 1.0);

      double edgeFade = 1.0;
      if (obj.progress < 0.0) {
        edgeFade = ((obj.progress + WaveShimmerOverlayState.lifeExtension) /
                WaveShimmerOverlayState.lifeExtension)
            .clamp(0.0, 1.0);
      } else if (obj.progress > 1.0) {
        edgeFade =
            ((1.0 + WaveShimmerOverlayState.lifeExtension - obj.progress) /
                    WaveShimmerOverlayState.lifeExtension)
                .clamp(0.0, 1.0);
      }

      if (edgeFade <= 0.0) continue;

      final double fade = fadeMain * edgeFade;
      final double alpha = (WaveShimmerOverlayState.minAlpha +
              (WaveShimmerOverlayState.maxAlpha -
                      WaveShimmerOverlayState.minAlpha) *
                  fade)
          .clamp(
        WaveShimmerOverlayState.minAlpha,
        WaveShimmerOverlayState.maxAlpha,
      );
      final Color waveColor = obj.color.withValues(alpha: alpha);

      final double y = -height * 0.25 + (height * 1.5) * waveT;
      final double amplitude = baseAmplitude * obj.amplitudeFactor;
      final double thickness = baseThickness * obj.thicknessFactor;

      final double driftX = width * obj.driftFactor * (waveT - 0.5);

      final double localRotation =
          (obj.rotationPhase + obj.progress * obj.rotationSpeed);

      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = waveColor
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          WaveShimmerOverlayState.blurSigma,
        );

      canvas.save();
      canvas.translate(width * 0.5, height * 0.5);
      canvas.rotate(localRotation);
      canvas.translate(-width * 0.5, -height * 0.5);

      final Path path = createPathForPattern(
        patternType: obj.patternType,
        width: width,
        height: height,
        step: step,
        waveT: waveT,
        centerY: y,
        amplitude: amplitude,
        driftX: driftX,
        curvatureSign: obj.curvatureSign,
        wobbleFactor: obj.wobbleFactor,
        frequency: obj.frequency,
        motionPhase: obj.motionPhase,
        originX: obj.originX,
        originY: obj.originY,
      );

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  Path createPathForPattern({
    required WaveShimmerPatternType patternType,
    required double width,
    required double height,
    required double step,
    required double waveT,
    required double centerY,
    required double amplitude,
    required double driftX,
    required double curvatureSign,
    required double wobbleFactor,
    required double frequency,
    required double motionPhase,
    required double originX,
    required double originY,
  }) {
    if (patternType == WaveShimmerPatternType.orb) {
      final double startX = width * originX;
      final double startY = height * originY;
      final double radius = WaveShimmerOverlayState.sizeScale *
          ((min(width, height) * 0.12) + (min(width, height) * 0.90) * waveT);

      final Rect rect = Rect.fromCircle(
        center: Offset(startX + driftX, startY),
        radius: radius,
      );
      return Path()..addOval(rect);
    }

    if (patternType == WaveShimmerPatternType.spiral) {
      final Path path = Path();
      final double centerX = width * 0.5 + driftX;
      final double cy = centerY;
      final double turns = 2.4 + frequency * 0.5;
      final int points = 120;

      for (int i = 0; i <= points; i++) {
        final double p = i / points;
        final double angle = (2 * pi * turns) * p +
            2 *
                pi *
                (WaveShimmerOverlayState.spiralSpinFactor * waveT +
                    motionPhase);
        final double radius = (amplitude * 0.2) + (amplitude * 1.2) * p;
        final double x = centerX + cos(angle) * radius;
        final double y = cy + sin(angle) * radius;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    final Path path = Path();
    for (double x = 0; x <= width; x += step) {
      final double dx = (x / width) - 0.5;
      final double px = x + driftX;

      double py = centerY;
      if (patternType == WaveShimmerPatternType.zigzag) {
        final double phase = (dx * frequency + waveT + motionPhase);
        final double saw = 2 * (phase - phase.floorToDouble());
        final double tri = saw <= 1 ? saw : 2 - saw;
        final double zig = (tri - 0.5) * 2;
        final double wobble = amplitude *
            wobbleFactor *
            sin(2 * pi * (dx * (frequency * 0.7) + waveT + motionPhase));
        py = centerY + amplitude * 0.55 * zig + wobble;
      } else {
        final double parabola = amplitude * (dx * dx) * 4;
        final double wobble = amplitude *
            wobbleFactor *
            sin(2 * pi * (dx * frequency + waveT + motionPhase));
        py = centerY + curvatureSign * parabola + wobble;
      }

      if (x == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant WaveShimmerBackgroundPainter oldDelegate) {
    return true;
  }
}
