import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:zymixx_todo_list/data/services/service_statistic_data.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/my_animated_card.dart';
import 'package:zymixx_todo_list/presentation/bloc_global/all_item_control_bloc.dart';

class LineChartSample extends StatefulWidget {
  final List<StatisticWeekHolder> weekData;
  final List<StatisticDayHolder> dayData;

  const LineChartSample({
    required this.weekData,
    required this.dayData,
    super.key,
  });

  @override
  State<LineChartSample> createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  List<Color> gradientColors = [
    //ToolThemeData.itemBorderColor,
    ToolThemeData.mainGreenColor,
    ToolThemeData.specialItemColor,
    // Colors.cyan,
    // Colors.blue,
    // Colors.blue,
  ];

  bool isWeeklyMod = false;

  Map<int, StatisticWeekHolder> weekStatisticMap = {};
  Map<int, StatisticDayHolder> dayStatisticMap = {};

  @override
  void initState() {
    //выравниваем порядок и берём только часть от общего пула
    var weekList = widget.weekData.reversed
        .toList()
        .sublist(widget.weekData.length > 8 ? widget.weekData.length - 8 : 0);
    var dayList = widget.dayData.reversed
        .toList()
        .sublist(widget.dayData.length > 12 ? widget.dayData.length - 12 : 0);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    for (var i = 0; i < (weekList.length >= 8 ? 8 : weekList.length); i++) {
      weekStatisticMap[i] = weekList[i];
    }
    for (var i = 0; i < (dayList.length >= 12 ? 12 : dayList.length); i++) {
      dayStatisticMap[i] = dayList[i];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          elevation: 5,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 0.7),
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.all(5),
            child: MyAnimatedCard(
              intensity: 0.01,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'Статистика ${isWeeklyMod ? 'за Неделю' : 'по Дням'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () {
                                isWeeklyMod = !isWeeklyMod;
                                if (isWeeklyMod) {
                                  _animationController..forward();
                                } else {
                                  _animationController..reverse();
                                }
                                setState(() {});
                              },
                              icon: AnimatedIcon(
                                icon: AnimatedIcons.list_view,
                                progress: _animationController,
                              ),
                            ),
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: 1.70,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 18,
                              left: 12,
                              top: 6,
                              bottom: 12,
                            ),
                            child: LineChart(
                              isWeeklyMod ? weeklyData() : dayByDayData(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWeekly(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    StatisticWeekHolder? statHolder = weekStatisticMap[value.toInt()];
    if (statHolder != null) {
      text = Text('${statHolder.weekName.substring(0, 5)}-');
    } else {
      text = const Text('', style: style);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Transform.rotate(angle: -90 * 3.1415926535 / 180, child: text),
      ),
    );
  }

  Widget leftTitleWeekly(double value, TitleMeta meta) {
    var style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey[600]!,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 10:
        text = '10h';
        break;
      case 20:
        text = '20h';
        break;
      default:
        return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData weeklyData() {
    List<FlSpot> listFLSpot = [];
    for (var key in weekStatisticMap.keys) {
      listFLSpot.add(FlSpot(key.toDouble(), weekStatisticMap[key]!.weekScore));
    }
    return LineChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: 1,
            getTitlesWidget: bottomTitleWeekly,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWeekly,
            reservedSize: 35,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black),
      ),
      minX: 0,
      maxX: 8,
      minY: 0,
      maxY: 30,
      lineBarsData: [
        LineChartBarData(
          spots: listFLSpot,
          isCurved: true,
          color: ToolThemeData.mainGreenColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
              show: true,
              getDotPainter: (q, w, e, r) => FlDotCirclePainter(
                    color: ToolThemeData.itemBorderColor,
                    radius: 5,
                  )),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: gradientColors.map((color) => color.withOpacity(0.45)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleDayByDay(double value, TitleMeta meta) {
    //ii day
    StatisticDayHolder? statHolder = dayStatisticMap[value.toInt()];
    Widget text;
    if (statHolder != null) {
      TextStyle style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: statHolder.isMonday ? Colors.orange[800] : null,
      );
      text = Text(
        '${statHolder.dayName}-',
        style: style,
      );
    } else {
      text = Text('');
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Transform.rotate(angle: -90 * 3.1415926535 / 180, child: text),
      ),
    );
  }

  Widget leftTitleDayByDay(double value, TitleMeta meta) {
    //ii day
    var style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.grey[600]!,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 2:
        text = '2h';
        break;
      case 4:
        text = '4h';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  double heightScore = 2.9;

  LineChartData dayByDayData() {
    //ii day
    List<FlSpot> listFLSpot = [];
    for (var key in dayStatisticMap.keys) {
      double data = dayStatisticMap[key]!.dayScore;
      listFLSpot.add(HighlightFlSpot(key.toDouble(), data));
      if (data > heightScore) {
        listFLSpot.add(HighlightFlSpot(key.toDouble(), data, isHighlight: true));
      }
    }
    return LineChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: 1,
            getTitlesWidget: bottomTitleDayByDay,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleDayByDay,
            reservedSize: 35,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.black),
      ),
      clipData: FlClipData.all(),
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          spots: listFLSpot,
          isCurved: true,
          barWidth: 3,
          isStrokeCapRound: true,
          color: ToolThemeData.mainGreenColor,
          preventCurveOverShooting: true,
          dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                Color color;
                double radius = 5;
                if (spot.y < 1.1) {
                  color = Colors.red;
                } else if (spot.y < heightScore) {
                  color = ToolThemeData.itemBorderColor;
                } else {
                  color = Colors.black;
                  radius = 6.5;
                  if ((spot as HighlightFlSpot).isHighlight) {
                    color = ToolThemeData.specialItemColor;
                    radius = 5;
                  }
                }
                return FlDotCirclePainter(
                  color: color,
                  radius: radius,
                );
              }),
          belowBarData: BarAreaData(
            show: true,
            applyCutOffY: true,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              stops: [0.3, 1],
              colors: gradientColors.map((color) => color.withOpacity(0.45)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class HighlightFlSpot extends FlSpot {
  bool isHighlight;

  HighlightFlSpot(super.x, super.y, {this.isHighlight = false});
}
