import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:zymixx_todo_list/data/services/service_statistic_data.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/my_animated_card.dart';
import 'package:zymixx_todo_list/presentation/bloc_global/all_item_control_bloc.dart';

class CalendarScreenWidget extends StatelessWidget {
  final List<StatisticDayHolder> dayData;

  const CalendarScreenWidget({
    super.key,
    required this.dayData,
  });

  @override
  Widget build(BuildContext context) {
    DateRangePickerController _calendarController = DateRangePickerController();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MyAnimatedCard(
        intensity: 0.005,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 12.0,
            left: 12.0,
            top: 6.0,
          ),
          child: Material(
            color: Colors.transparent,
            elevation: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 0.7),
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 500,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0, left: 12.0, top: 12.0),
                    child: FractionallySizedBox(
                      heightFactor: 1.00,
                      widthFactor: 0.9,
                      child: SfDateRangePicker(
                        selectionMode: DateRangePickerSelectionMode.single,
                        view: DateRangePickerView.month,
                        initialDisplayDate: DateTime.now(),
                        selectionColor: ToolThemeData.mainGreenColor,
                        toggleDaySelection: true,
                        showActionButtons: false,
                        showNavigationArrow: true,
                        monthViewSettings: DateRangePickerMonthViewSettings(
                          viewHeaderHeight: 15,
                          firstDayOfWeek: 1,
                        ),
                        headerHeight: 25,
                        controller: _calendarController,
                        cellBuilder:
                            (BuildContext context, DateRangePickerCellDetails cellDetails) {
                          DateTime date = cellDetails.date;
                          var cellColor = Colors.white;
                          DateTime today = DateTime.now();
                          bool isToday = date.isSameDay(DateTime.now());
                          double dayScore = 0.0;
                          bool inactiveDay = false;
                          for (var targetDataItem in dayData) {
                            if (targetDataItem.dateTime.isSameDay(date)) {
                              dayScore = targetDataItem.dayScore;
                              inactiveDay = targetDataItem.isInactiveDay;
                            }
                          }
                          String titleDayScore = dayScore.toString();
                          if(inactiveDay) {
                            cellColor = Colors.grey[300]!;
                            titleDayScore = '—';
                          } else if (date.isBefore(today)) {
                            if (dayScore == 0){
                              inactiveDay = true;
                              titleDayScore = '—';
                              cellColor = Colors.grey[300]!;
                            } else if (dayScore < 1) {
                              cellColor = Colors.red[100]!;
                            } else if (dayScore < 1.5) {
                              cellColor = Colors.greenAccent[100]!;
                            } else if (dayScore < 2) {
                              cellColor = ToolThemeData.highlightGreenColor;
                            } else if (dayScore < 2.5) {
                              cellColor = ToolThemeData.mainGreenColor;
                            } else if (dayScore > 2.9) {
                              cellColor = ToolThemeData.specialItemColor;
                            }
                          }
                          if (_calendarController.view == DateRangePickerView.month) {
                            return Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: cellColor),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [Colors.white38, Colors.white24, Colors.white12],
                                      stops: [0.5, 0.4, 1.0],
                                    ),
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        border: isToday
                                            ? Border.all(
                                                width: 2, color: ToolThemeData.highlightColor)
                                            : Border.all(width: 0.75, color: Colors.black12),
                                        shape: BoxShape.rectangle),
                                    child: Center(
                                      child: Text(
                                        titleDayScore,
                                        style: TextStyle(
                                          color: isToday
                                              ? ToolThemeData.itemBorderColor
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: isToday ? FontStyle.italic : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (_calendarController.view == DateRangePickerView.year) {
                            bool isToMonth = date.month == today.month && date.year == today.year;
                            return Container(
                              width: cellDetails.bounds.width,
                              height: cellDetails.bounds.height,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: isToMonth
                                          ? Border.all(
                                              width: 1.5, color: ToolThemeData.highlightColor)
                                          : null,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                        child: Text(DateFormat('MMMM', 'ru')
                                            .format(cellDetails.date)
                                            .capStart()))),
                              ),
                            );
                          } else if (_calendarController.view == DateRangePickerView.decade) {
                            bool isToYear = date.year == today.year;
                            return Container(
                              width: cellDetails.bounds.width,
                              height: cellDetails.bounds.height,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: isToYear
                                          ? Border.all(
                                              width: 1.5, color: ToolThemeData.highlightColor)
                                          : null,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(child: Text(cellDetails.date.year.toString()))),
                              ),
                            );
                          } else {
                            final int yearValue = (cellDetails.date.year ~/ 10) * 10;
                            return Container(
                              width: cellDetails.bounds.width,
                              height: cellDetails.bounds.height,
                              alignment: Alignment.center,
                              child:
                                  Text(yearValue.toString() + ' - ' + (yearValue + 9).toString()),
                            );
                          }
                        },
                        onSelectionChanged: (args) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
