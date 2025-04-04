import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:gap/gap.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import '../app_widgets/my_animated_card.dart';
import '../bloc_global/all_item_control_bloc.dart';
import 'calendar_bloc.dart';
import 'widgets/day_data_block_widget.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllItemControlBloc>(
        create: (_) => Get.find<AllItemControlBloc>(),
        child: BlocProvider(create: (_) => CalendarBloc(), child: CalendarScreenWidget()));
  }
}

class CalendarScreenWidget extends StatelessWidget {
  const CalendarScreenWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    DateRangePickerController _calendarController = DateRangePickerController();
    var itemList = context.select((AllItemControlBloc bloc) => bloc.state.todoActiveItemList);
    Set<DateTime> storyItemDateList = context
        .read<AllItemControlBloc>()
        .state
        .todoActiveItemList
        .where(
            (item) => item.targetDateTime != null && item.category == EnumTodoCategory.social.name)
        .map((e) => e.targetDateTime!)
        .toSet();
    Set<DateTime> setNotEmptyDate = context
        .read<AllItemControlBloc>()
        .state
        .todoActiveItemList
        .where((item) => item.targetDateTime != null)
        .map((e) => e.targetDateTime!)
        .toSet();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Gap(10),
          Flexible(
            flex: 4,
            child: MyAnimatedCard(
              intensity: 0.005,
              child: Material(
                elevation: 10,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 500,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                          //ii начало build
                          DateTime date = cellDetails.date;
                          var cellColor = Colors.white;
                          bool isStoryDay = false;
                          DateTime today = DateTime.now();
                          bool isToday = date.isSameDay(DateTime.now());
                          for (var targetData in setNotEmptyDate) {
                            if (targetData.isSameDay(date)) {
                              cellColor = Colors.redAccent;
                            }
                          }
                          for (var targetData in storyItemDateList) {
                            if (targetData.isSameDay(date)) {
                              isStoryDay = true;
                            }
                          }
                          if (_calendarController.view == DateRangePickerView.month) {
                            return Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: isStoryDay ? Colors.amber!.withOpacity(1) : null,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isStoryDay
                                        ? null
                                        : RadialGradient(
                                            colors: [
                                              Colors.white,
                                              Colors.white,
                                              cellColor.withOpacity(0.1)
                                            ],
                                            stops: [0.5, 0.4, 1.0],
                                          ),
                                  ),
                                  child: Stack(
                                    children: [
                                      if (date.isBefore(today) && !isToday)
                                        Placeholder(
                                          strokeWidth: 1,
                                          color: Colors.black26,
                                        ),
                                      DecoratedBox(
                                        decoration: BoxDecoration(
                                            border: isToday
                                                ? Border.all(
                                                    width: 2, color: ToolThemeData.highlightColor)
                                                : Border.all(width: 0.75, color: Colors.black12),
                                            shape: BoxShape.rectangle),
                                        child: Center(
                                          child: Text(
                                            date.day.toString(),
                                            style: TextStyle(
                                              color: isToday
                                                  ? ToolThemeData.itemBorderColor
                                                  : Colors.black,
                                              fontSize: isToday ? 17 : null,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: isToday ? FontStyle.italic : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                        onSelectionChanged: (args) {
                          context
                              .read<CalendarBloc>()
                              .add(SelectDateEvent(selectedDateTime: args.value));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Flexible(flex: 5, fit: FlexFit.loose, child: DayDataBlockWidget()),
        ],
      ),
    );
  }
}