import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

import '../history_screen.dart';
import 'mini_chart_painter.dart';
import 'todo_history_item_widget.dart';

class WeekCard extends StatefulWidget {
  final DateTime weekStartDate;
  final List<TodoItem> items;
  final List<TodoItem>? prevItems;

  const WeekCard({
    Key? key,
    required this.weekStartDate,
    required this.items,
    this.prevItems,
  }) : super(key: key);

  @override
  State<WeekCard> createState() => _WeekCardState();
}

class _WeekCardState extends State<WeekCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  int get taskCount => widget.items.length;

  int get socialCount => widget.items
      .where((item) => item.category == EnumTodoCategory.history_social.name)
      .length;

  int get minutesSpent =>
      widget.items.fold(0, (sum, item) => sum + item.secondsSpent) ~/ 60;

  int get prevMinutesSpent =>
      (widget.prevItems ?? [])
          .fold(0, (sum, item) => sum + item.secondsSpent) ~/
      60;

  int get minuteDiff => minutesSpent - prevMinutesSpent;

  Color get trendColor {
    if (minuteDiff > HistoryScreenWidget.diffYellowMax) {
      return const Color(0xFF43FF83); // Green
    } else if (minuteDiff < HistoryScreenWidget.diffYellowMin) {
      return const Color(0xFFF87171); // Red
    }
    return const Color(0xFFFFD04A); // Yellow
  }

  Color get trendColorLight {
    if (minuteDiff > HistoryScreenWidget.diffYellowMax) {
      return const Color(0xFFB7FF6A);
    } else if (minuteDiff < HistoryScreenWidget.diffYellowMin) {
      return const Color(0xFFFCA5A5);
    }
    return const Color(0xFFFFE28A);
  }

  List<double> get dailyCounts {
    List<double> counts = List.filled(7, 0);
    for (var item in widget.items) {
      if (item.targetDateTime != null) {
        counts[item.targetDateTime!.weekday - 1]++;
      }
    }
    return counts;
  }

  List<int> get dailyMinutes {
    List<int> minutes = List.filled(7, 0);
    for (var item in widget.items) {
      if (item.targetDateTime != null) {
        minutes[item.targetDateTime!.weekday - 1] += item.secondsSpent ~/ 60;
      }
    }
    return minutes;
  }

  String get dateStr {
    DateTime end = widget.weekStartDate.add(const Duration(days: 6));
    String startDay = DateFormat('dd').format(widget.weekStartDate);
    String startMonth = _shortMonthRu(widget.weekStartDate.month);
    String endDay = DateFormat('dd').format(end);
    String endMonth = _shortMonthRu(end.month);
    return '$startDay $startMonth – $endDay $endMonth';
  }

  String _shortMonthRu(int month) {
    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'мая',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    return months[month - 1];
  }

  IconData get trendIcon {
    if (minuteDiff > HistoryScreenWidget.diffYellowMax)
      return Icons.trending_up_rounded;
    if (minuteDiff < HistoryScreenWidget.diffYellowMin)
      return Icons.trending_down_rounded;
    return Icons.trending_flat_rounded;
  }

  Widget _buildMetricChip(
      IconData icon, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
              scale: 1.1,
              child: Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Icon(icon, size: 16, color: color),
              )),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            unit,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMetricsContent({
    required bool isNarrow,
    required double metricFontSize,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMetricChip(Icons.check_circle_outline, '$taskCount', 'задач',
              const Color(0xFF34D399)),
          const SizedBox(width: 5),
          _buildMetricChip(Icons.access_time, '$minutesSpent', 'мин',
              const Color(0xFF60A5FA)),

          const SizedBox(width: 5),
          //иконка победы (кубок)
          _buildMetricChip(Icons.emoji_events, '$socialCount',
              socialCount == 1 ? 'story' : 'stories', const Color(0xFFB14CFF)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 380;
        final double titleFontSize = isNarrow ? 18 : 22;
        final double metricFontSize = isNarrow ? 14 : 16;
        const double chartHeight = 56;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => setState(() => isExpanded = !isExpanded),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: RingGlowPainter(
                                  color: trendColor,
                                  progress: _shimmerController.value,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: ColoredBox(
                                color: Colors.white.withValues(alpha: 0.02),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF3B4152)
                                      .withValues(alpha: 0.62),
                                  const Color(0xFF1A1D25)
                                      .withValues(alpha: 0.90),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(0.98, 0.20),
                                radius: 1.05,
                                colors: [
                                  trendColor.withValues(alpha: 0.16),
                                  trendColor.withValues(alpha: 0.06),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.38, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: const Alignment(-0.90, -0.65),
                                radius: 1.10,
                                colors: [
                                  trendColorLight.withValues(alpha: 0.10),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.06),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.18),
                                ],
                                stops: const [0.0, 0.55, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.10),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.25),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 10,
                          height: chartHeight,
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: 0.25,
                                  child: CustomPaint(
                                    painter: MiniChartPainter(
                                      data: dailyCounts,
                                      color: trendColor,
                                      animationValue: _shimmerController.value,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: trendColor.withValues(
                                                  alpha: 0.12),
                                              border: Border.all(
                                                color: trendColor.withValues(
                                                    alpha: 0.22),
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              trendIcon,
                                              size: 20,
                                              color: trendColor.withValues(
                                                  alpha: 0.95),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              dateStr,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: titleFontSize,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white
                                                    .withValues(alpha: 0.95),
                                                letterSpacing: -0.2,
                                                shadows: [
                                                  Shadow(
                                                    color:
                                                        trendColor.withValues(
                                                            alpha: 0.35),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 0),
                                                  ),
                                                  Shadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.55),
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.white
                                            .withValues(alpha: 0.10),
                                        endIndent: 20,
                                        indent: 5,
                                      ),
                                      SizedBox(height: 2),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: chartHeight * 0.5),
                                        child: buildMetricsContent(
                                          isNarrow: isNarrow,
                                          metricFontSize: metricFontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Padding(
                                  padding: EdgeInsets.only(
                                      bottom: chartHeight * 0.4),
                                  child: _buildActivityDots(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF0F1117).withValues(alpha: 0.75),
                            const Color(0xFF0F1117).withValues(alpha: 0.92),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.10),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Column(
                          children: widget.items.map((e) {
                            final int index = widget.items.indexOf(e);
                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white.withValues(alpha: 0.04),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.06),
                                      width: 1,
                                    ),
                                  ),
                                  child: TodoHistoryItemWidget(todoItem: e),
                                ),
                                if (index != widget.items.length - 1)
                                  const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityDots() {
    List<int> mins = dailyMinutes;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        int m = mins[index];
        Color dotColor;
        if (m == 0) {
          dotColor = Colors.white.withValues(alpha: 0.10);
        } else if (m <= HistoryScreenWidget.minutesRedThreshold) {
          dotColor = const Color(0xFFF87171); // Red
        } else if (m <= HistoryScreenWidget.minutesYellowThreshold) {
          dotColor = const Color(0xFFFFD04A); // Yellow
        } else {
          dotColor = const Color(0xFF43FF83); // Green
        }

        return AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            if (m == 0) {
              return Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              );
            }

            final double t = (_shimmerController.value + (index / 7.0)) % 1.0;
            final double pulse = 0.72 + 0.28 * math.sin(t * math.pi * 2);
            final double radius = 2.0 + 1.5 * pulse;
            final double outerRadius = 6.5 + 2.0 * pulse;

            final Rect rect = Rect.fromCircle(
              center: const Offset(0, 0),
              radius: outerRadius,
            );

            return Opacity(
              opacity: pulse,
              child: Container(
                width: 14,
                height: 14,
                alignment: Alignment.center,
                child: CustomPaint(
                  painter: _DotGlowPainter(
                    color: dotColor,
                    pulse: pulse,
                    radius: radius,
                    rect: rect,
                  ),
                  child: const SizedBox(width: 14, height: 14),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _DotGlowPainter extends CustomPainter {
  final Color color;
  final double pulse;
  final double radius;
  final Rect rect;

  _DotGlowPainter({
    required this.color,
    required this.pulse,
    required this.radius,
    required this.rect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.30 * pulse),
          color.withValues(alpha: 0.10 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(c, 7.0 + 2.0 * pulse, glow);

    canvas.drawCircle(
      c,
      radius,
      Paint()..color = color.withValues(alpha: 0.95),
    );
  }

  @override
  bool shouldRepaint(covariant _DotGlowPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}

class RingGlowPainter extends CustomPainter {
  final Color color;
  final double progress;

  RingGlowPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      const Radius.circular(22),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        transform: GradientRotation(progress * math.pi * 2),
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.55, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant RingGlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
