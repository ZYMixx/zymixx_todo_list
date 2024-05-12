import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zymixx_todo_list/data/tools/tool_date_formatter.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/statistic_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/mu_animated_card.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => StatisticBloc(),
        child: const StatisticWidget(),
      ),
    );
  }
}

class StatisticWidget extends StatelessWidget {
  const StatisticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<AllItemControlBloc>().state.todoActiveItemList;
    return Column(
      children: [
        Flexible(child: LineChartSample()),
        Flexible(child: DataTableWidget()),
      ],
    );
  }
}

class LineChartSample extends StatefulWidget {
  const LineChartSample({super.key});

  @override
  State<LineChartSample> createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AspectRatio(
        aspectRatio: 1.70,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 12,
            top: 24,
            bottom: 12,
          ),
          child: LineChart(
             mainData(),
          ),
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
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
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
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
      maxY: 300,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (q,w,e,r) => FlDotCirclePainter(color: Colors.purpleAccent, radius: 5,)
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {
      'date': DateTime.now(),
      'time': '10:00',
      'tasks': 5,
      'fails': 1,
      'story': 'Story 1',
      'points': 10,
    },
    {
      'date': DateTime.now(),
      'time': '11:00',
      'tasks': 7,
      'fails': 2,
      'story': 'Story 2',
      'points': 15,
    },    {
      'date': DateTime.now(),
      'time': '11:00',
      'tasks': 7,
      'fails': 2,
      'story': 'Story 2',
      'points': 15,
    },    {
      'date': DateTime.now(),
      'time': '11:00',
      'tasks': 7,
      'fails': 2,
      'story': 'Story 2',
      'points': 15,
    },    {
      'date': DateTime.now(),
      'time': '11:00',
      'tasks': 7,
      'fails': 2,
      'story': 'Story 2',
      'points': 15,
    },{
      'date': DateTime.now(),
      'time': '11:00',
      'tasks': 7,
      'fails': 2,
      'story': 'Story 2',
      'points': 15,
    },{
      'date': DateTime.now(),
      'time': '11:00',
      'tasks': 7,
      'fails': 2,
      'story': 'Story 2',
      'points': 15,
    },
    // Add more data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return MyAnimatedCard(
      intensity: 0.02,
      child: Card(
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          height: 220,
          child: SingleChildScrollView(
            child: DataTable(
              horizontalMargin: 10,
              headingRowColor: MaterialStateProperty.all<Color>(Colors.grey[300]!),
              columnSpacing: 25,
              border: TableBorder(
                verticalInside: BorderSide(color: Colors.grey),
                right: BorderSide(color: Colors.grey),
              ),
              columns: [
                DataColumn(label: Center(child: Text('Дата'))),
                DataColumn(label: Center(child:Text('Время'))),
                DataColumn(label: Center(child:Text('Дел'))),
                DataColumn(label: Center(child:Text('Fails'))),
                DataColumn(label: Center(child:Text('Story'))),
                DataColumn(label: Center(child: Text('Итого'))),
              ],
              rows: data
                  .map(
                    (item) => DataRow(cells: [
                  DataCell(Center(child:Text(calculateWeek()))),
                  DataCell(Center(child:Text(item['time']))),
                  DataCell(Center(child:Text(item['tasks'].toString()))),
                  DataCell(Center(child:Text(item['fails'].toString()))),
                  DataCell(Center(child:Text(item['story']))),
                  DataCell(Center(child:Text(item['points'].toString()))),
                ]),
              )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
  String calculateWeek(){
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    DateTime sunday = now.add(Duration(days: DateTime.daysPerWeek - now.weekday));

    DateFormat dateFormat1 = DateFormat('dd', 'ru');
    DateFormat dateFormat2 = DateFormat('dd MMM', 'ru');

    String formattedMonday = dateFormat1.format(monday);
    String formattedSunday = dateFormat2.format(sunday);


    return '$formattedMonday-$formattedSunday';
  }
}
