import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:gap/gap.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/calendar_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_animated_card.dart';

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

class DayDataBlockWidget extends StatelessWidget {
  const DayDataBlockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var itemList = context.select((AllItemControlBloc bloc) => bloc.state.todoActiveItemList);
    DateTime? selectDate = context.select((CalendarBloc bloc) => bloc.state.selectedDateTime);
    List<TodoItem> todoTodoItemList = itemList.where((TodoItem todoItem) {
      if (todoItem.targetDateTime == null || selectDate == null) {
        return false;
      } else {
        return selectDate.isSameDay(todoItem.targetDateTime!);
      }
    }).toList();
    Log.i('call rebuild calendar item');
    Log.i('$todoTodoItemList');
    todoTodoItemList = todoTodoItemList.reversed.toList();
    return Column(
      children: [
        MyAnimatedCard(
          intensity: 0.007,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
            child: InkWell(
              onTap: () {
                if (selectDate != null) {
                  Get.find<AllItemControlBloc>().add(AddNewItemEvent(dateTime: selectDate));
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Center(
                  child: Text(
                    '${selectDate?.getStringDate() ?? 'no select'}',
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: ListView.builder(
              itemCount: todoTodoItemList.length,
              itemBuilder: (context, itemId) {
                return DataTodoItem(
                  todoItem: todoTodoItemList[itemId],
                  key: ValueKey(todoTodoItemList),
                );
              }),
        ),
      ],
    );
  }
}

class DataTodoItem extends StatefulWidget {
  const DataTodoItem({super.key, required this.todoItem});

  final TodoItem todoItem;

  @override
  State<DataTodoItem> createState() => _DataTodoItemState();
}

class _DataTodoItemState extends State<DataTodoItem> {
  late TextEditingController _controllerTitle;
  late TextEditingController _controllerDescription;
  late TodoItem tempTodoItem;

  @override
  void initState() {
    super.initState();
    _controllerTitle = TextEditingController();
    _controllerDescription = TextEditingController();
    _controllerTitle.text = widget.todoItem.title ?? '';
    _controllerDescription.text = widget.todoItem.content ?? '';
    tempTodoItem = widget.todoItem.copyWith();
    _controllerTitle.addListener(() {
      tempTodoItem = tempTodoItem.copyWith(title: _controllerTitle.text);
    });
    _controllerDescription.addListener(() {
      tempTodoItem = tempTodoItem.copyWith(content: _controllerDescription.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isStoryItem = widget.todoItem.category == EnumTodoCategory.social.name;
    return MyAnimatedCard(
      intensity: 0.003,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
        child: Container(
          padding: EdgeInsets.all(3),
          height: 140,
          decoration: BoxDecoration(
              color: isStoryItem ? ToolThemeData.specialItemColor : ToolThemeData.itemBorderColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                  offset: Offset(0, 0),
                ),
              ]),
          child: Row(
            children: [
              Flexible(
                flex: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: BorderDirectional(end: BorderSide(width: 1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                          offset: Offset(0, 0),
                        ),
                      ]),
                  child: Column(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0, right: 4),
                          child: TextField(
                              controller: _controllerTitle,
                              maxLines: 1,
                              decoration: InputDecoration(hintText: 'title'),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  letterSpacing: -0.5,
                                  wordSpacing: -1.0,
                                  height: 0.9,
                                  shadows: ToolThemeData.defTextShadow)),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0, right: 4),
                          child: TextField(
                              controller: _controllerDescription,
                              maxLines: 4,
                              decoration: InputDecoration(hintText: 'content'),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                letterSpacing: -0.5,
                                wordSpacing: -0.5,
                                height: 0.95,
                                shadows: [
                                  Shadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 0.1),
                                    blurRadius: 1.5,
                                  ),
                                ],
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.0,
                          spreadRadius: 1.0,
                          offset: Offset(0, 0),
                        ),
                      ]),
                      child: MyAnimatedCard(
                        intensity: 0.005,
                        child: Column(
                          children: [
                            Expanded(
                              child: MyAnimatedCard(
                                intensity: 0.005,
                                child: MaterialButton(
                                  focusNode: FocusNode(skipTraversal: true),
                                  onPressed: () {
                                    context
                                        .read<CalendarBloc>()
                                        .add(SaveEvent(todoItem: tempTodoItem));
                                  },
                                  color: ToolThemeData.mainGreenColor,
                                  child: Text('Save'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: MyAnimatedCard(
                                intensity: 0.005,
                                child: MaterialButton(
                                  focusNode: FocusNode(skipTraversal: true),
                                  onPressed: () {
                                    context.read<CalendarBloc>().add(ChangeTodoDateEvent(
                                          context: context,
                                          todoItem: tempTodoItem,
                                        ));
                                  },
                                  color: Colors.blueAccent,
                                  child: Text('Date'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: MyAnimatedCard(
                                intensity: 0.005,
                                child: DecoratedBox(
                                  decoration: isStoryItem
                                      ? BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              ToolThemeData.specialItemColor[200]!,
                                              Colors.purple[800]!
                                            ],
                                            stops: [0.5, 0.5],
                                            transform: GradientRotation(0.7),
                                          ),
                                        )
                                      : BoxDecoration(color: ToolThemeData.specialItemColor),
                                  child: MaterialButton(
                                    focusNode: FocusNode(skipTraversal: true),
                                    onPressed: () {
                                      context
                                          .read<CalendarBloc>()
                                          .add(SetStoryCalendarItemEvent(todoItem: tempTodoItem));
                                    },
                                    child: isStoryItem
                                        ? ShaderMask(
                                            blendMode: BlendMode.srcIn,
                                            shaderCallback: (bounds) => LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [Colors.purple[900]!, Colors.white],
                                              stops: [0.5, 0.5],
                                              transform: GradientRotation(0.7),
                                            ).createShader(
                                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                            ),
                                            child: Text(
                                              'Story',
                                              style: TextStyle(fontSize: 16, letterSpacing: 1.5),
                                            ),
                                          )
                                        : Text(
                                            'Story',
                                            style: TextStyle(fontSize: 16, letterSpacing: 1.5),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: MyAnimatedCard(
                                intensity: 0.005,
                                child: MaterialButton(
                                  focusNode: FocusNode(skipTraversal: true),
                                  onPressed: () {
                                    context
                                        .read<CalendarBloc>()
                                        .add(DoneCalendarItemEvent(todoItem: tempTodoItem));
                                  },
                                  color: ToolThemeData.highlightGreenColor,
                                  child: Text('Done'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: MyAnimatedCard(
                                intensity: 0.005,
                                child: MaterialButton(
                                  focusNode: FocusNode(skipTraversal: true),
                                  onPressed: () {
                                    context
                                        .read<CalendarBloc>()
                                        .add(DeleteCalendarItemEvent(todoItem: tempTodoItem));
                                  },
                                  color: Colors.red,
                                  child: Text('Delete'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
