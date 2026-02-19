import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/data/tools/tool_time_string_converter.dart';
import 'package:zymixx_todo_list/domain/app_data.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/add_item_button.dart';
import '../app_widgets/my_animated_card.dart';
import '../bloc_global/all_item_control_bloc.dart';
import 'daily_todo_bloc.dart';

class DailyTodoScreen extends StatelessWidget {
  const DailyTodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: Get.find<AllItemControlBloc>(),
      child: BlocProvider.value(
        value: Get.find<DailyTodoBloc>(),
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
    bool yesterdayDailyMod =
        context.select((DailyTodoBloc bloc) => bloc.state.yesterdayDailyMod);
    List<TodoItem> dailyTodoList;
    if (yesterdayDailyMod) {
      dailyTodoList = context
          .select((AllItemControlBloc bloc) => bloc.state.todoDailyItemList)
          .where((element) =>
              element.targetDateTime != null &&
              element.targetDateTime!
                  .isSameDay(now.subtract(Duration(days: 1))))
          .toList();
    } else {
      dailyTodoList = context
          .select((AllItemControlBloc bloc) => bloc.state.todoDailyItemList)
          .where((element) =>
              element.targetDateTime != null &&
              element.targetDateTime!.isSameDay(now))
          .toList();
    }
    dailyTodoList.sort((a, b) {
      if (!a.isDone && b.isDone) {
        return -1;
      } else if (a.isDone && !b.isDone) {
        return 1;
      } else {
        return 0;
      }
    });
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 0.8,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        yesterdayDailyMod
                            ? Icons.timelapse_outlined
                            : Icons.calendar_month_outlined,
                        color: Colors.white,
                        size: yesterdayDailyMod ? 22 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        yesterdayDailyMod
                            ? 'Вчерашние дейлики'
                            : 'Ежедневные задачи',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          letterSpacing: 0.1,
                          color: Colors.white,
                          shadows: ToolThemeData.defTextShadow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            itemCount: dailyTodoList.length,
            itemBuilder: (context, itemId) {
              return DailyTodoItem(
                dailyTodoItem: dailyTodoList[itemId],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: AddItemButton(
            onTapAction: () {
              context
                  .read<DailyTodoBloc>()
                  .add(RequestAddNewDailyEvent(context: context));
            },
            onLongTapAction: () => bloc.add(ChangeYesterdayModEvent()),
            secondaryAction: () => bloc.add(ChangeYesterdayModEvent()),
            bgColor: Colors.deepPurpleAccent,
            label: 'New daily',
            icon: Icons.calendar_month_outlined,
          ),
        ),
      ],
    );
  }
}

class DailyTodoItem extends StatefulWidget {
  final TodoItem dailyTodoItem;

  DailyTodoItem({required this.dailyTodoItem})
      : super(key: ValueKey('${dailyTodoItem.title}_${dailyTodoItem.id}'));

  @override
  State<DailyTodoItem> createState() => _DailyTodoItemState();
}

class _DailyTodoItemState extends State<DailyTodoItem> {
  bool timerIsRun = false;

  @override
  void initState() {
    Get.find<DailyTodoBloc>().checkOnActiveTimer(
        itemId: widget.dailyTodoItem.id, updateCallBack: secondUpdate);
    super.initState();
  }

  void secondUpdate(int second) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = widget.dailyTodoItem.isDone;
    final Map<String, dynamic> json =
        jsonDecode(widget.dailyTodoItem.content) as Map<String, dynamic>;
    final bool hasPrize = (json['prise'] ?? 0) != 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
      child: MyAnimatedCard(
        intensity: 0.005,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isDone
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ToolThemeData.highlightGreenColor.withOpacity(0.98),
                      ToolThemeData.highlightGreenColor.withOpacity(0.86),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.99),
                      Colors.white.withOpacity(0.94),
                    ],
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              context.read<DailyTodoBloc>().add(CompleteDailyEvent(
                  isComplete: !widget.dailyTodoItem.isDone,
                  itemId: widget.dailyTodoItem.id,
                  remainSeconds: widget.dailyTodoItem.timerSeconds));
            },
            onLongPress: () {
              context.read<DailyTodoBloc>().add(DeleteDailyEvent(
                  itemId: widget.dailyTodoItem.id,
                  context: context,
                  content: widget.dailyTodoItem.content,
                  title: widget.dailyTodoItem.title));
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: child,
                    ),
                  );
                },
                child: isDone
                    ? _CompletedDailyContent(
                        key: const ValueKey('completed'),
                        title: widget.dailyTodoItem.title,
                        hasPrize: hasPrize,
                        prize: hasPrize ? json['prise'].toString() : null,
                      )
                    : _ActiveDailyContent(
                        key: const ValueKey('active'),
                        item: widget.dailyTodoItem,
                        hasPrize: hasPrize,
                        prize: hasPrize ? json['prise'].toString() : null,
                        bottomLabel: _buildBottomLabel(json),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildBottomLabel(Map<String, dynamic> json) {
    final List<dynamic> days =
        (json['dailyDayList'] as List<dynamic>?) ?? <dynamic>[];
    final dynamic periodValue = json['period'];
    if (days.isNotEmpty) {
      return getWeekdayNames(days).join(', ');
    }
    if (periodValue != 0) {
      return '$periodValue';
    }
    return '';
  }
}

class _ActiveDailyContent extends StatelessWidget {
  final TodoItem item;
  final bool hasPrize;
  final String? prize;
  final String bottomLabel;

  const _ActiveDailyContent({
    super.key,
    required this.item,
    required this.hasPrize,
    required this.prize,
    required this.bottomLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Левая цветная полоса / индикатор статуса
        Container(
          width: 4,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: ToolThemeData.itemBorderColor.withOpacity(0.95),
          ),
        ),
        const SizedBox(width: 10),

        // Заголовок + приз + дни недели / период
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                  height: 1.25,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasPrize)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.black.withOpacity(0.04),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prize ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.emoji_events,
                            size: 18,
                            color: Colors.orangeAccent,
                          ),
                        ],
                      ),
                    ),
                  if (bottomLabel.isNotEmpty) ...[
                    if (hasPrize) const SizedBox(width: 8),
                    Text(
                      bottomLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Таймер и индикаторы
        BlocBuilder<DailyTodoBloc, DailyTodoState>(
          builder: (context, state) {
            String timerIdentifier =
                "${item.id}${AppData.dailyTimerIdentifier}";
            final bool hasTimer = item.timerSeconds > 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.activeTimerIdentifier == timerIdentifier)
                      const RunDailyIndicatorWidget(),
                    if (hasTimer)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.04),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.5),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.9),
                                  width: 1.3,
                                ),
                                color: item.autoPauseSeconds == 0
                                    ? Colors.grey[400]
                                    : item.autoPauseSeconds == 60
                                        ? Colors.yellowAccent
                                        : ToolThemeData.highlightColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (hasTimer)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.black.withOpacity(0.035),
                      ),
                      child: Text(
                        Get.find<ToolTimeStringConverter>()
                            .formatSecondsToTimeWithoutZero(item.timerSeconds),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CompletedDailyContent extends StatelessWidget {
  final String title;
  final bool hasPrize;
  final String? prize;

  const _CompletedDailyContent({
    super.key,
    required this.title,
    required this.hasPrize,
    required this.prize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  letterSpacing: -0.2,
                  height: 1.25,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              if (hasPrize)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withOpacity(0.16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            prize ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.emoji_events,
                            size: 20,
                            color: ToolThemeData.specialItemColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ],
                )
              else
                const Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class RunDailyIndicatorWidget extends StatefulWidget {
  const RunDailyIndicatorWidget({
    super.key,
  });

  @override
  State<RunDailyIndicatorWidget> createState() =>
      _RunDailyIndicatorWidgetState();
}

class _RunDailyIndicatorWidgetState extends State<RunDailyIndicatorWidget> {
  bool animationBool = false;

  @override
  Widget build(BuildContext context) {
    animationBool = !animationBool;
    return AnimatedContainer(
      duration: Duration(milliseconds: 900),
      transform: Matrix4.identity()..scale(animationBool ? 1.1 : 1.15),
      padding: EdgeInsets.only(
          right: animationBool ? 6 : 4, bottom: animationBool ? 2 : 4),
      child: Icon(Icons.directions_run,
          size: 16,
          color: animationBool ? Colors.black : Colors.deepPurple[800]),
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
