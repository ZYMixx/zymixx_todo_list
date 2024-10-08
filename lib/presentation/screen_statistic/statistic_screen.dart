import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/services/service_statistic_data.dart';
import 'package:zymixx_todo_list/presentation/screen_statistic/widgets/calendar_screen_widget.dart';
import 'package:zymixx_todo_list/presentation/screen_statistic/widgets/data_table_widget.dart';
import 'package:zymixx_todo_list/presentation/screen_statistic/widgets/line_chart_sample.dart';
import 'package:zymixx_todo_list/presentation/screen_statistic/widgets/streak_widget.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: const StatisticWidget(),
    );
  }
}

class StatisticWidget extends StatelessWidget {
  const StatisticWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Get.find<ServiceStatisticData>().requestData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 880,
              child: Column(
                children: [
                  LineChartSample(
                      weekData: snapshot.data![Get.find<ServiceStatisticData>().weekKey],
                      dayData: snapshot.data![Get.find<ServiceStatisticData>().dayKey]),
                  Expanded(
                      child: CalendarScreenWidget(
                          dayData: snapshot.data![Get.find<ServiceStatisticData>().dayKey])),
                  StreakWidget(
                    streakCount: snapshot.data![Get.find<ServiceStatisticData>().streakKey],
                  ),
                  DataTableWidget(
                    weekData: snapshot.data![Get.find<ServiceStatisticData>().weekKey],
                  ),
                  Gap(20),
                ],
              ),
            ),
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
