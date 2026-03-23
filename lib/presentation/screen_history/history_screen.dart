import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import '../bloc_global/all_item_control_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllItemControlBloc>(
      create: (_) => Get.find<AllItemControlBloc>(),
      child: const HistoryScreenWidget(),
    );
  }
}

class HistoryScreenWidget extends StatefulWidget {
  const HistoryScreenWidget({Key? key}) : super(key: key);

  @override
  State<HistoryScreenWidget> createState() => _HistoryScreenWidgetState();
}

class _HistoryScreenWidgetState extends State<HistoryScreenWidget> {
  @override
  Widget build(BuildContext context) {
    List<TodoItem> todoHistoryItemList = context
        .select((AllItemControlBloc bloc) => bloc.state.todoHistoryItemList);

    Map<String, List<TodoItem>> groupedMap =
        _groupItemsByWeek(todoHistoryItemList);

    List<String> weekKeys = groupedMap.keys.toList()
      ..sort((a, b) {
        DateTime dateA = _parseInternalWeekKey(a);
        DateTime dateB = _parseInternalWeekKey(b);
        return dateB.compareTo(dateA);
      });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F1117), Color(0xFF151826)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: weekKeys.isEmpty
                    ? const Center(
                        child: Text(
                          'Нет данных',
                          style:
                              TextStyle(color: Color(0xFFB9C1D9), fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 40),
                        itemCount: weekKeys.length,
                        itemBuilder: (context, index) {
                          String weekKey = weekKeys[index];
                          List<TodoItem> items = groupedMap[weekKey]!;
                          List<TodoItem>? prevItems =
                              (index + 1 < weekKeys.length)
                                  ? groupedMap[weekKeys[index + 1]]
                                  : null;

                          return WeekCard(
                            weekStartDate: _parseInternalWeekKey(weekKey),
                            items: items,
                            prevItems: prevItems,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'История',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE6E8EF),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.06),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFFAEB4C2),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<TodoItem>> _groupItemsByWeek(List<TodoItem> items) {
    Map<String, List<TodoItem>> groupedItems = {};
    for (var item in items) {
      if (item.targetDateTime == null) continue;
      DateTime date = item.targetDateTime!;
      DateTime monday = date.subtract(Duration(days: date.weekday - 1));
      String internalKey = DateFormat('yyyy-MM-dd').format(monday);
      groupedItems.putIfAbsent(internalKey, () => []).add(item);
    }
    return groupedItems;
  }

  DateTime _parseInternalWeekKey(String key) {
    return DateFormat('yyyy-MM-dd').parse(key);
  }
}

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

class TodoHistoryItemWidget extends StatefulWidget {
  final TodoItem todoItem;

  const TodoHistoryItemWidget({Key? key, required this.todoItem})
      : super(key: key);

  @override
  State<TodoHistoryItemWidget> createState() => _TodoHistoryItemWidgetState();
}

class _TodoHistoryItemWidgetState extends State<TodoHistoryItemWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool isSocial =
        widget.todoItem.category == EnumTodoCategory.history_social.name;

    int minutes = widget.todoItem.secondsSpent ~/ 60;

    return InkWell(
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSocial
                        ? const Color(0xFFB14CFF)
                        : const Color(0xFF60A5FA),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.todoItem.title,
                    style: const TextStyle(
                      color: Color(0xFFC7CBD6),
                      fontSize: 14,
                    ),
                  ),
                ),
                if (minutes > 0)
                  Text(
                    '${minutes}м',
                    style: const TextStyle(
                      color: Color(0xFF8A93A6),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            if (isExpanded && widget.todoItem.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  widget.todoItem.content,
                  style: const TextStyle(
                    color: Color(0xFF8A93A6),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeekCardState extends State<WeekCard> {
  int get taskCount => widget.items.length;

  int get socialCount => widget.items
      .where((item) => item.category == EnumTodoCategory.history_social.name)
      .length;

  int get minutesSpent =>
      widget.items.fold(0, (sum, item) => sum + item.secondsSpent) ~/ 60;

  int get prevTaskCount => widget.prevItems?.length ?? 0;
  int get taskDiff => taskCount - prevTaskCount;

  Color get trendColor {
    if (taskDiff > 0) {
      if (taskDiff >= 2) return const Color(0xFF43FF83);
      return const Color(0xFFFFD04A);
    }
    if (taskDiff < 0) return const Color(0xFFF87171);
    return const Color(0xFF7DD3FC);
  }

  /// Secondary lighter color for gradient effects
  Color get trendColorLight {
    if (taskDiff > 0) {
      if (taskDiff >= 2) return const Color(0xFFB7FF6A);
      return const Color(0xFFFFE28A);
    }
    if (taskDiff < 0) return const Color(0xFFFCA5A5);
    return const Color(0xFFA5D8FF);
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

  /// Returns which days of the week had activity (for dot indicators)
  List<bool> get dailyActivity {
    List<bool> activity = List.filled(7, false);
    for (var item in widget.items) {
      if (item.targetDateTime != null) {
        activity[item.targetDateTime!.weekday - 1] = true;
      }
    }
    return activity;
  }

  String get dateStr {
    DateTime end = widget.weekStartDate.add(const Duration(days: 6));
    // Format: "06 янв. – 12 янв."
    String startDay = DateFormat('dd').format(widget.weekStartDate);
    String startMonth = _shortMonthRu(widget.weekStartDate.month);
    String endDay = DateFormat('dd').format(end);
    String endMonth = _shortMonthRu(end.month);
    return '$startDay $startMonth – $endDay $endMonth';
  }

  String _shortMonthRu(int month) {
    const months = [
      'янв.',
      'фев.',
      'мар.',
      'апр.',
      'мая',
      'июн.',
      'июл.',
      'авг.',
      'сен.',
      'окт.',
      'ноя.',
      'дек.',
    ];
    return months[month - 1];
  }

  String get storyLabel {
    if (socialCount == 0) return '0 stories';
    if (socialCount == 1) return '1 story';
    return '$socialCount stories';
  }

  @override
  Widget build(BuildContext context) {
    const double chartWidth = 220;
    const double rightReservedPadding = chartWidth - 40;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 380;
        final double titleFontSize = isNarrow ? 22 : 26;
        final double metricFontSize = isNarrow ? 15 : 18;
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF3B4152).withValues(alpha: 0.62),
                            const Color(0xFF1A1D25).withValues(alpha: 0.90),
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
                            trendColor.withValues(alpha: 0.30),
                            trendColor.withValues(alpha: 0.10),
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
                    right: 10,
                    bottom: 12,
                    width: chartWidth,
                    height: chartHeight,
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: MiniChartPainter(
                          data: dailyCounts,
                          color: trendColor,
                        ),
                      ),
                    ),
                  ),
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    childrenPadding: EdgeInsets.zero,
                    trailing: const SizedBox(),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Padding(
                      padding:
                          const EdgeInsets.only(right: rightReservedPadding),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            height: 22,
                            child: CustomPaint(
                              painter: _TrendWavePainter(color: trendColor),
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
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE6E8EF),
                                letterSpacing: -0.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 1,
                            margin: const EdgeInsets.only(
                              bottom: 12,
                              right: 140,
                            ),
                            color: Colors.white.withValues(alpha: 0.10),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: rightReservedPadding,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: trendColor.withValues(
                                                alpha: 0.22),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: trendColor.withValues(
                                                  alpha: 0.45),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: trendColor.withValues(
                                                    alpha: 0.25),
                                                blurRadius: 12,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: Icon(
                                              Icons.check_rounded,
                                              size: 16,
                                              color: trendColor.withValues(
                                                  alpha: 0.95),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '$taskCount ',
                                                style: TextStyle(
                                                  fontSize: metricFontSize,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFFB9C1D9),
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'задач',
                                                style: TextStyle(
                                                  fontSize: metricFontSize,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      Colors.white.withValues(
                                                    alpha: 0.60,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Container(
                                          height: 14,
                                          width: 1,
                                          color: Colors.white
                                              .withValues(alpha: 0.10),
                                        ),
                                        const SizedBox(width: 14),
                                        Icon(
                                          Icons.access_time_filled_rounded,
                                          size: 18,
                                          color: Colors.white
                                              .withValues(alpha: 0.55),
                                        ),
                                        const SizedBox(width: 8),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '$minutesSpent ',
                                                style: TextStyle(
                                                  fontSize: metricFontSize,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFFB9C1D9),
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'мин',
                                                style: TextStyle(
                                                  fontSize: metricFontSize,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      Colors.white.withValues(
                                                    alpha: 0.60,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Container(
                                          height: 14,
                                          width: 1,
                                          color: Colors.white
                                              .withValues(alpha: 0.10),
                                        ),
                                        const SizedBox(width: 14),
                                        Icon(
                                          Icons.inventory_2_rounded,
                                          size: 18,
                                          color: Colors.white
                                              .withValues(alpha: 0.55),
                                        ),
                                        const SizedBox(width: 8),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '$socialCount ',
                                                style: TextStyle(
                                                  fontSize: metricFontSize,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      const Color(0xFFB9C1D9),
                                                ),
                                              ),
                                              TextSpan(
                                                text: socialCount == 1
                                                    ? 'story'
                                                    : 'stories',
                                                style: TextStyle(
                                                  fontSize: metricFontSize,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      Colors.white.withValues(
                                                    alpha: 0.60,
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
                                const SizedBox(width: 10),
                                _buildActivityDots(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: widget.items
                        .map((e) => TodoHistoryItemWidget(todoItem: e))
                        .toList(),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(9, (index) {
        bool hasActivity = index < dailyActivity.length && dailyActivity[index];
        return Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasActivity
                  ? trendColor.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.10),
              boxShadow: hasActivity
                  ? [
                      BoxShadow(
                        color: trendColor.withValues(alpha: 0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

/// Paints a small wavy trend line (~) to indicate trend direction
class _TrendWavePainter extends CustomPainter {
  final Color color;

  _TrendWavePainter({required this.color});

  @override
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5);

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    path.lineTo(size.width * 0.6, size.height * 0.5);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);

    // Main line (sharper)
    paint.maskFilter = null;
    paint.color = color;
    canvas.drawPath(path, paint);

    // Arrowhead
    final arrowPath = Path();
    arrowPath.moveTo(size.width, 0);
    arrowPath.lineTo(size.width - 6, 0);
    arrowPath.lineTo(size.width, 6);
    arrowPath.close();
    canvas.drawPath(arrowPath, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  MiniChartPainter({required this.data, required this.color});

  @override
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

    // Glow effect
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawPath(path, glowPaint);

    // Main line
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawPath(path, linePaint);

    // Arrow at the end
    final metric = path.computeMetrics().last;
    final tangent = metric.getTangentForOffset(metric.length);
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
      canvas.drawPath(arrowPath, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
