import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_time_string_converter.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/daily_todo_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/add_item_button.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/mu_animated_card.dart';

class DailyTodoScreen extends StatelessWidget {
  const DailyTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return Get.find<AllItemControlBloc>();
      },
      child: BlocProvider(
        create: (_) => Get.find<DailyTodoBloc>(),
        child: DailyTodoWidget(),
      ),
    );
  }
}

class DailyTodoWidget extends StatelessWidget {
  const DailyTodoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    DailyTodoBloc bloc = context.select((DailyTodoBloc bloc) => bloc);
    bool yesterdayDailyMod = context.select((DailyTodoBloc bloc) => bloc.state.yesterdayDailyMod);
    List<TodoItem> dailyTodoList;
    if (yesterdayDailyMod) {
      dailyTodoList = context
          .select((AllItemControlBloc bloc) => bloc.state.todoDailyItemList)
          .where((element) =>
              element.targetDateTime != null &&
              element.targetDateTime!.isSameDay(now.subtract(Duration(days: 1))))
          .toList();
    } else {
      dailyTodoList = context
          .select((AllItemControlBloc bloc) => bloc.state.todoDailyItemList)
          .where(
              (element) => element.targetDateTime != null && element.targetDateTime!.isSameDay(now))
          .toList();
    }
    return Column(
      children: [
        if (yesterdayDailyMod)
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Вчера',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                Baseline(
                  baseline: 40.0,
                  baselineType: TextBaseline.alphabetic,
                  child: Icon(
                    Icons.timelapse_outlined,
                    color: Colors.white,
                    size: 31,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: dailyTodoList.length,
            itemBuilder: (context, itemId) {
              return DailyTodoItem(
                dailyTodoItem: dailyTodoList[itemId],
              );
            },
          ),
        ),
        Opacity(
          opacity: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: AddItemButton(
              onTapAction: () {
                context.read<DailyTodoBloc>().add(RequestAddNewDailyEvent(context: context));
              },
              onLongTapAction: () => bloc.add(ChangeYesterdayModEvent()),
              bgColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class DailyTodoItem extends StatefulWidget {
  final TodoItem dailyTodoItem;

  const DailyTodoItem({required this.dailyTodoItem});

  @override
  State<DailyTodoItem> createState() => _DailyTodoItemState();
}

class _DailyTodoItemState extends State<DailyTodoItem> {
  bool timerIsRun = false;
  int? remainTimer;

  @override
  void initState() {
    remainTimer = widget.dailyTodoItem.timerSeconds;
    Get.find<DailyTodoBloc>()
        .checkOnActiveTimer(itemId: widget.dailyTodoItem.id, updateCallBack: secondUpdate);
    super.initState();
  }

  void secondUpdate(int second) {
    if (mounted) {
      setState(() {
        remainTimer = second;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyAnimatedCard(
      intensity: 0.005,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: widget.dailyTodoItem.isDone ? Colors.greenAccent : Colors.white70,
            border: Border.all(
              width: 1.5,
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: InkWell(
            onTap: () {
              context.read<DailyTodoBloc>().add(CompleteDailyEvent(
                  isComplete: !widget.dailyTodoItem.isDone,
                  itemId: widget.dailyTodoItem.id,
                  remainSeconds: remainTimer ?? 0,
                  timerUpdateCB: secondUpdate));
            },
            onLongPress: () {
              context.read<DailyTodoBloc>().add(DeleteDailyEvent(
                  itemId: widget.dailyTodoItem.id,
                  context: context,
                  title: widget.dailyTodoItem.title));
            },
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AnimatedScale(
                      duration: Duration(milliseconds: 200),
                      scale: widget.dailyTodoItem.isDone ? 1.2 : 0,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 150),
                        opacity: widget.dailyTodoItem.isDone ? 1 : 0,
                        child: Icon(
                          Icons.check_outlined,
                          color: Colors.purpleAccent,
                          size: 30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: (jsonDecode(widget.dailyTodoItem.content)['prise'] != 0)
                          ? EdgeInsets.only(top: widget.dailyTodoItem.isDone ? 12.0 : 2)
                          : EdgeInsets.zero,
                      child: Center(
                        child: Text(
                          widget.dailyTodoItem.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: -0.5,
                            wordSpacing: -1.0,
                            height: 0.9,
                          ),
                        ),
                      ),
                    ),
                    AnimatedScale(
                      duration: Duration(milliseconds: 200),
                      scale: widget.dailyTodoItem.isDone ? 1.2 : 0,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 100),
                        opacity: widget.dailyTodoItem.isDone ? 1 : 0,
                        child: Icon(
                          Icons.check_outlined,
                          color: Colors.purpleAccent,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.dailyTodoItem.timerSeconds > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: DecoratedBox(
                            position: DecorationPosition.background,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2.0,
                                  spreadRadius: 1.0,
                                  offset: Offset(0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.5),
                              child: CircleAvatar(
                                radius: 6.0,
                                backgroundColor: widget.dailyTodoItem.autoPauseSeconds == 0
                                    ? Colors.grey[400]
                                    : widget.dailyTodoItem.autoPauseSeconds == 60
                                        ? Colors.yellowAccent
                                        : Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          remainTimer == 0
                              ? ''
                              : '${ToolTimeStringConverter.formatSecondsToTimeWithoutZero(remainTimer ?? 0)}',
                          style: TextStyle(
                            fontSize: 21.1,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            shadows: timerIsRun
                                ? [
                                    Shadow(
                                      color: Colors.greenAccent,
                                      offset: Offset(1, 1.5),
                                      blurRadius: 1.6,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (jsonDecode(widget.dailyTodoItem.content)['prise'] != 0)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('( '),
                        Text(
                          jsonDecode(widget.dailyTodoItem.content)['prise'].toString(),
                          style: TextStyle(
                            fontSize: widget.dailyTodoItem.isDone ? 18 : 15,
                            fontWeight: FontWeight.w600,
                            color: widget.dailyTodoItem.isDone ? Colors.black : Colors.grey[800],
                            shadows: timerIsRun
                                ? [
                                    Shadow(
                                      color: Colors.greenAccent,
                                      offset: Offset(1, 1.5),
                                      blurRadius: 1.6,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        Icon(
                          Icons.emoji_events,
                          size: widget.dailyTodoItem.isDone ? 22 : 14,
                          color: widget.dailyTodoItem.isDone ? Colors.orangeAccent : Colors.black,
                        ),
                        Text(' )'),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${(jsonDecode(widget.dailyTodoItem.content)['dailyDayList'] as List<dynamic>).isNotEmpty ? getWeekdayNames(jsonDecode(widget.dailyTodoItem.content)['dailyDayList']) : jsonDecode(widget.dailyTodoItem.content)['period'] != 0 ? jsonDecode(widget.dailyTodoItem.content)['period'] : ''}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<String> getWeekdayNames(List<dynamic> weekdays) {
  List<String> weekdayNames = [
    'пн', // 1
    'вт', // 2
    'ср', // 3
    'чт', // 4
    'пт', // 5
    'сб', // 6
    'вск' // 7
  ];
  return weekdays.map((day) {
    if (day < 1 || day > 7) {
      throw ArgumentError('Day must be between 1 and 7');
    }
    return weekdayNames[day - 1];
  }).toList();
}

extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime date) {
    if (date.day == this.day && date.month == this.month && date.year == this.year) {
      return true;
    } else {
      return false;
    }
  }
}
