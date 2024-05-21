import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/services/service_statistic_data.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_animated_card.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const StatisticWidget(),
    );
  }
}

class StatisticWidget extends StatelessWidget {
  const StatisticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<AllItemControlBloc>().state.todoActiveItemList;
    return FutureBuilder(
      future: ServiceStatisticData.requestData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Log.e(" snapshot.data ${snapshot.data}");
          return Column(
            children: [
              LineChartSample(
                  weekData: snapshot.data![ServiceStatisticData.weekKey],
                  dayData: snapshot.data![ServiceStatisticData.dayKey]),
              DataTableWidget(
                weekData: snapshot.data![ServiceStatisticData.weekKey],
              ),
            ],
          );
        } else {
          return Center(
            child: Text(
              'Build Statistic..',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }
}

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
    Colors.cyan,
    Colors.blue,
  ];

  bool isWeeklyMod = false;

  Map<int, StatisticWeekHolder> weekStatisticMap = {};
  Map<int, StatisticDayHolder> dayStatisticMap = {};

  @override
  void initState() {
    var weekList = widget.weekData.toList();
    var dayList = widget.dayData.toList();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    //выравниваем порядок и берём только часть от общего пула
    for (var i = 0; i < (weekList.length >= 8 ? 8 : weekList.length); i++) {
      weekStatisticMap[i] = weekList[weekList.length - 1 - i];
    }
    for (var i = 0; i < (dayList.length >= 14 ? 14 : dayList.length); i++) {
      dayStatisticMap[i] = dayList[dayList.length - 1 - i];
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
      case 30:
        text = '30h';
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
      maxY: 40,
      lineBarsData: [
        LineChartBarData(
          spots: listFLSpot,
          isCurved: true,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
              show: true,
              getDotPainter: (q, w, e, r) => FlDotCirclePainter(
                    color: Colors.purpleAccent,
                    radius: 5,
                  )),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleDayByDay(double value, TitleMeta meta) {
    //ii day
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    StatisticDayHolder? statHolder = dayStatisticMap[value.toInt()];
    if (statHolder != null) {
      text = Text('${statHolder.dayName}-');
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
      case 6:
        text = '6h';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData dayByDayData() {
    //ii day
    List<FlSpot> listFLSpot = [];
    for (var key in dayStatisticMap.keys) {
      listFLSpot.add(FlSpot(key.toDouble(), dayStatisticMap[key]!.dayScore));
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
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY: 8,
      lineBarsData: [
        LineChartBarData(
          spots: listFLSpot,
          isCurved: true,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
              show: true,
              getDotPainter: (q, w, e, r) => FlDotCirclePainter(
                    color: Colors.purpleAccent,
                    radius: 5,
                  )),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

//ii НИЖНЯЯ ТАБЛИЦА
class DataTableWidget extends StatelessWidget {
  final List<StatisticWeekHolder> weekData;

  const DataTableWidget({
    required this.weekData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MyAnimatedCard(
        intensity: 0.01,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          borderOnForeground: true,
          clipBehavior: Clip.hardEdge,
          elevation: 4,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border.all(width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Container(
              height: 220,
              child: StreamBuilder<Object>(
                  stream: null,
                  builder: (context, snapshot) {
                    return SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all<Color>(Colors.grey[300]!),
                        columnSpacing: 40,
                        border: TableBorder(
                          verticalInside: BorderSide(color: Colors.grey),
                          bottom: BorderSide(color: Colors.grey[400]!.withOpacity(0.8)!),
                        ),
                        columns: [
                          DataColumn(label: Center(child: Text('Дата'))),
                          DataColumn(label: Center(child: Text('Дел'))),
                          DataColumn(label: Center(child: Text('Fails'))),
                          DataColumn(label: Center(child: Text('Story'))),
                          DataColumn(label: Center(child: Text('Итого'))),
                        ],
                        rows: weekData
                            .map(
                              (item) => DataRow(cells: [
                                DataCell(Center(
                                    child: Text(item.weekName,
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15.5)))),
                                DataCell(Center(
                                    child: Text(item.todoItemCount.toString(),
                                        style:
                                            TextStyle(fontWeight: FontWeight.w600, fontSize: 18)))),
                                DataCell(
                                  Center(
                                    child: Text(
                                      item.dailyFails.toString(),
                                      style: TextStyle(
                                          color: item.dailyFails == 0
                                              ? Colors.greenAccent[700]
                                              : item.dailyFails > 3
                                                  ? Colors.red[700]
                                                  : Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      item.storyItems.toString(),
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      '${item.weekScore}h',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ]),
                            )
                            .toList(),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
