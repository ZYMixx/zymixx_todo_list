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
  static const Duration standardDuration = Duration(seconds: 10);
  static const double minAlpha = 0.55;
  static const double maxAlpha = 0.65;
  static const int minWaveCount = 2;
  static const int maxWaveCount = 3;
  static const double speedRandomRange = 0.30;
  static const double blurSigma = 36;
  static const double fadeInPortion = 0.18;
  static const double fadeOutPortion = 0.32;
  static const double durationRandomRange = 0.30;
  static const double waveEdgeFade = 0.18;
  static const double sizeScale = 2.0;
  static const double spiralSpinFactor = 0.08;

  static final Map<String, Color> cachedColorById = {};

  AnimationController? animationController;
  Color? color;
  List<WaveShimmerConfig> waveConfigs = const [];
  double lastControllerValue = 0;
  int waveSeed = 0;
  int lastLogMs = 0;
  int cycleIndex = 0;
  int lastSameValueMs = 0;
  int lastBuildLogMs = 0;

  @override
  void initState() {
    super.initState();

    color = cachedColorById[widget.id] ?? randomColorFromTheme(widget.id);
    cachedColorById[widget.id] = color!;

    waveSeed =
        DateTime.now().microsecondsSinceEpoch ^ (widget.id.hashCode * 31);
    waveConfigs = createWaveConfigs();

    final Random random = Random(waveSeed);
    final double durationFactor =
        1.0 + (random.nextDouble() * 2 - 1) * durationRandomRange;
    final Duration duration = Duration(
      milliseconds: (standardDuration.inMilliseconds * durationFactor)
          .round()
          .clamp(1000, 600000),
    );

    debugPrint(
      'WaveShimmerOverlay(${widget.id}) init: seed=$waveSeed durationMs=${duration.inMilliseconds} waveCount=${waveConfigs.length}',
    );

    animationController = AnimationController(
      vsync: this,
      duration: duration,
    );

    animationController?.value = random.nextDouble();

    animationController?.repeat();

    debugPrint(
      'WaveShimmerOverlay(${widget.id}) start: controllerValue=${animationController?.value}',
    );

    animationController?.addListener(() {
      final double value = animationController?.value ?? 0;
      final double delta = value - lastControllerValue;

      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      if (nowMs - lastLogMs >= 500) {
        lastLogMs = nowMs;
        final int configCount = waveConfigs.length;
        String firstPattern = 'none';
        double firstWaveT = -999;
        int visibleCount = 0;
        if (waveConfigs.isNotEmpty) {
          for (final WaveShimmerConfig cfg in waveConfigs) {
            double waveT = value * cfg.speedFactor + cfg.phase;
            if (cfg.directionSign < 0) {
              waveT = 1.0 - waveT;
            }
            if (waveT >= 0.0 && waveT <= 1.0) {
              visibleCount++;
            }
          }
        }

        if (waveConfigs.isNotEmpty) {
          firstPattern = waveConfigs.first.patternType.name;
          firstWaveT =
              value * waveConfigs.first.speedFactor + waveConfigs.first.phase;
        }

        if (delta.abs() < 0.000001) {
          lastSameValueMs = nowMs;
        }

        final bool valueStuck =
            lastSameValueMs != 0 && (nowMs - lastSameValueMs) > 1500;
        debugPrint(
          'WaveShimmerOverlay(${widget.id}) tick: cycle=$cycleIndex value=$value delta=$delta configs=$configCount visible=$visibleCount firstPattern=$firstPattern firstWaveTRaw=$firstWaveT stuck=$valueStuck',
        );
      }

      if (value < lastControllerValue) {
        setState(() {
          cycleIndex++;
          waveConfigs = createWaveConfigs();
        });

        debugPrint(
          'WaveShimmerOverlay(${widget.id}) cycleEnd: newCycle=$cycleIndex newWaveCount=${waveConfigs.length}',
        );
      }
      lastControllerValue = value;
    });

    Future.delayed(const Duration(seconds: 1), () {
      final AnimationController? c = animationController;
      debugPrint(
        'WaveShimmerOverlay(${widget.id}) probe+1s: hasController=${c != null} isAnimating=${c?.isAnimating} value=${c?.value}',
      );
    });
    Future.delayed(const Duration(seconds: 2), () {
      final AnimationController? c = animationController;
      debugPrint(
        'WaveShimmerOverlay(${widget.id}) probe+2s: hasController=${c != null} isAnimating=${c?.isAnimating} value=${c?.value}',
      );
    });
    Future.delayed(const Duration(seconds: 3), () {
      final AnimationController? c = animationController;
      debugPrint(
        'WaveShimmerOverlay(${widget.id}) probe+3s: hasController=${c != null} isAnimating=${c?.isAnimating} value=${c?.value}',
      );
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController controller = animationController!;

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - lastBuildLogMs >= 1000) {
      lastBuildLogMs = nowMs;
      debugPrint(
        'WaveShimmerOverlay(${widget.id}) build: tickerMode=${TickerMode.of(context)} controllerValue=${controller.value} isAnimating=${controller.isAnimating}',
      );
    }

    return TickerMode(
      enabled: true,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final double t = controller.value;

                  final double globalFade = calculateGlobalFade(t);

                  return CustomPaint(
                    painter: WaveShimmerBackgroundPainter(
                      progress: t,
                      configs: waveConfigs,
                      globalFade: globalFade,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
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

  double calculateGlobalFade(double t) {
    if (t < fadeInPortion) {
      return (t / fadeInPortion).clamp(0.0, 1.0);
    }

    if (t > 1.0 - fadeOutPortion) {
      return ((1.0 - t) / fadeOutPortion).clamp(0.0, 1.0);
    }

    return 1.0;
  }

  List<WaveShimmerConfig> createWaveConfigs() {
    final Random random = Random(waveSeed);

    final int count =
        minWaveCount + random.nextInt(maxWaveCount - minWaveCount + 1);

    final List<Color> colors = [
      ToolThemeData.itemBorderColor,
      ToolThemeData.highlightColor,
      ToolThemeData.specialItemColor,
      ToolThemeData.mainGreenColor,
      ToolThemeData.highlightGreenColor,
    ];

    final List<WaveShimmerConfig> configs = [];
    for (int i = 0; i < count; i++) {
      final double speedFactor =
          1.0 + (random.nextDouble() * 2 - 1) * speedRandomRange;

      final double sequentialPhase =
          (-0.36 * i) + ((random.nextDouble() * 2 - 1) * 0.06);

      configs.add(
        WaveShimmerConfig(
          patternType: WaveShimmerPatternType
              .values[random.nextInt(WaveShimmerPatternType.values.length)],
          phase: sequentialPhase,
          speedFactor: speedFactor.clamp(0.70, 1.30),
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
        ),
      );
    }

    bool hasNonOrb = false;
    for (final WaveShimmerConfig cfg in configs) {
      if (cfg.patternType != WaveShimmerPatternType.orb) {
        hasNonOrb = true;
        break;
      }
    }

    if (!hasNonOrb && configs.isNotEmpty) {
      final WaveShimmerConfig old = configs.first;
      configs[0] = WaveShimmerConfig(
        patternType: WaveShimmerPatternType.parabola,
        phase: old.phase,
        speedFactor: old.speedFactor,
        directionSign: old.directionSign,
        curvatureSign: old.curvatureSign,
        amplitudeFactor: old.amplitudeFactor,
        thicknessFactor: old.thicknessFactor,
        driftFactor: old.driftFactor,
        wobbleFactor: old.wobbleFactor,
        frequency: old.frequency,
        rotationSpeed: old.rotationSpeed,
        rotationPhase: old.rotationPhase,
        motionPhase: old.motionPhase,
        originX: old.originX,
        originY: old.originY,
        color: old.color,
      );
    }

    for (int i = 0; i < configs.length; i++) {
      if (configs[i].patternType == WaveShimmerPatternType.orb) {
        continue;
      }
      final WaveShimmerConfig old = configs[i];
      configs[i] = WaveShimmerConfig(
        patternType: old.patternType == WaveShimmerPatternType.orb
            ? WaveShimmerPatternType.parabola
            : old.patternType,
        phase: old.phase,
        speedFactor: old.speedFactor,
        directionSign: old.directionSign,
        curvatureSign: old.curvatureSign,
        amplitudeFactor: old.amplitudeFactor,
        thicknessFactor: old.thicknessFactor,
        driftFactor: old.driftFactor,
        wobbleFactor: old.wobbleFactor,
        frequency: old.frequency,
        rotationSpeed: old.rotationSpeed,
        rotationPhase: old.rotationPhase,
        motionPhase: old.motionPhase,
        originX: old.originX,
        originY: old.originY,
        color: old.color,
      );
    }

    return configs;
  }
}

class WaveShimmerConfig {
  final WaveShimmerPatternType patternType;
  final double phase;
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

  WaveShimmerConfig({
    required this.patternType,
    required this.phase,
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
  final double progress;
  final List<WaveShimmerConfig> configs;
  final double globalFade;

  WaveShimmerBackgroundPainter({
    required this.progress,
    required this.configs,
    required this.globalFade,
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

    for (final WaveShimmerConfig cfg in configs) {
      double waveT = (progress * cfg.speedFactor + cfg.phase);
      if (cfg.directionSign < 0) {
        waveT = 1.0 - waveT;
      }

      final double normalized = (waveT).clamp(0.0, 1.0);
      final double fadeMain = sin(pi * normalized).clamp(0.0, 1.0);

      double edgeFade = 1.0;
      if (waveT < 0.0) {
        edgeFade = ((waveT + WaveShimmerOverlayState.waveEdgeFade) /
                WaveShimmerOverlayState.waveEdgeFade)
            .clamp(0.0, 1.0);
      } else if (waveT > 1.0) {
        edgeFade = ((1.0 + WaveShimmerOverlayState.waveEdgeFade - waveT) /
                WaveShimmerOverlayState.waveEdgeFade)
            .clamp(0.0, 1.0);
      }

      if (edgeFade <= 0.0) {
        continue;
      }

      final double fade = fadeMain * edgeFade;
      final double alpha = (WaveShimmerOverlayState.minAlpha +
              (WaveShimmerOverlayState.maxAlpha -
                      WaveShimmerOverlayState.minAlpha) *
                  (fade * globalFade))
          .clamp(
        WaveShimmerOverlayState.minAlpha,
        WaveShimmerOverlayState.maxAlpha,
      );
      final Color waveColor = cfg.color.withValues(alpha: alpha);

      final double y = -height * 0.25 + (height * 1.5) * normalized;
      final double amplitude = baseAmplitude * cfg.amplitudeFactor;
      final double thickness = baseThickness * cfg.thicknessFactor;

      final double driftX = width * cfg.driftFactor * (waveT - 0.5);

      final double localRotation =
          (cfg.rotationPhase + progress * cfg.rotationSpeed) * globalFade;

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
        patternType: cfg.patternType,
        width: width,
        height: height,
        step: step,
        waveT: waveT,
        centerY: y,
        amplitude: amplitude,
        driftX: driftX,
        curvatureSign: cfg.curvatureSign,
        wobbleFactor: cfg.wobbleFactor,
        frequency: cfg.frequency,
        motionPhase: cfg.motionPhase,
        originX: cfg.originX,
        originY: cfg.originY,
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
    return oldDelegate.progress != progress ||
        oldDelegate.configs != configs ||
        oldDelegate.globalFade != globalFade;
  }
}
