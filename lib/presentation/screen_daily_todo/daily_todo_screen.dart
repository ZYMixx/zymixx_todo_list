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
        child: const DailyTodoWidget(),
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
              .isSameDay(now.subtract(const Duration(days: 1))))
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
                        style: const TextStyle(
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
    final bool hasPrize = (json['prize'] ?? json['prise'] ?? 0) != 0;
    final String? prizeValue =
    hasPrize ? (json['prize'] ?? json['prise']).toString() : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: MyAnimatedCard(
        intensity: isDone ? 0.002 : 0.005,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut, // Убрали отскоки, чтобы анимация не "вываливалась"
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isDone ? 18 : 14),
            gradient: isDone
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ToolThemeData.highlightGreenColor.withOpacity(0.95),
                ToolThemeData.highlightGreenColor.withOpacity(0.80),
              ],
            )
                : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.96),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: isDone
                    ? ToolThemeData.highlightGreenColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: isDone ? 12 : 6,
                offset: isDone ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(isDone ? 18 : 14),
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
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut, // Плавное изменение размера без багов расширения
              alignment: Alignment.topCenter,
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0, // Существенно уменьшили отступы
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Важно! Предотвращает дергание элементов по вертикали
                  children: [
                    // Статусный индикатор с морфингом
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.only(top: isDone ? 0 : 2.0), // Выравниваем полоску по тексту
                      width: isDone ? 24 : 4,
                      height: isDone ? 24 : 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: isDone
                            ? Colors.white
                            : ToolThemeData.itemBorderColor.withOpacity(0.95),
                        boxShadow: isDone
                            ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 3,
                          )
                        ]
                            : [],
                      ),
                      child: isDone
                          ? const Center(
                          child: Icon(Icons.check,
                              color: Colors.green, size: 16))
                          : null,
                    ),
                    const SizedBox(width: 10),

                    // Контент
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            style: TextStyle(
                              fontWeight:
                              isDone ? FontWeight.w800 : FontWeight.w700,
                              fontSize: isDone ? 15 : 16,
                              letterSpacing: -0.2,
                              color: isDone ? Colors.white : Colors.black87,
                              shadows: isDone
                                  ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.40),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ]
                                  : null,
                            ),
                            child: Text(
                              widget.dailyTodoItem.title,
                              maxLines: isDone ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Блок наград и дней (появляется/исчезает плавно)
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: (hasPrize || !isDone)
                                ? Padding(
                              padding: EdgeInsets.only(top: isDone ? 4.0 : 6.0),
                              child: Row(
                                children: [
                                  if (hasPrize)
                                    _AnimatedPrizeBadge(
                                      prize: prizeValue ?? '',
                                      isDone: isDone,
                                    ),
                                  if (!isDone &&
                                      _buildBottomLabel(json).isNotEmpty) ...[
                                    if (hasPrize) const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0, vertical: 2.0),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _buildBottomLabel(json).toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          letterSpacing: 0.5,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),

                    // Правая часть (Таймер) - Анимированное скрытие по ширине, чтобы не ломать высоту текста
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        axisAlignment: 1.0,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: isDone
                          ? const SizedBox.shrink()
                          : Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: _TimerSection(item: widget.dailyTodoItem),
                      ),
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

class _AnimatedPrizeBadge extends StatelessWidget {
  final String prize;
  final bool isDone;

  const _AnimatedPrizeBadge({required this.prize, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
          horizontal: isDone ? 6.0 : 6.0, vertical: isDone ? 2.0 : 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: isDone
            ? Colors.black.withOpacity(0.15)
            : Colors.black.withOpacity(0.05),
        border: isDone
            ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            prize,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDone ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.emoji_events,
            size: 14,
            color:
            isDone ? ToolThemeData.specialItemColor : Colors.orangeAccent,
          ),
        ],
      ),
    );
  }
}

class _TimerSection extends StatelessWidget {
  final TodoItem item;
  const _TimerSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyTodoBloc, DailyTodoState>(
      builder: (context, state) {
        String timerIdentifier = "${item.id}${AppData.dailyTimerIdentifier}";
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
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: _TimerDot(),
                  ),
              ],
            ),
            if (hasTimer)
              Padding(
                padding: const EdgeInsets.only(top: 4.0), // Уменьшили отступ таймера
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0), // Уменьшили внутренний отступ
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.black.withOpacity(0.05),
                  ),
                  child: Text(
                    Get.find<ToolTimeStringConverter>()
                        .formatSecondsToTimeWithoutZero(item.timerSeconds),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TimerDot extends StatelessWidget {
  const _TimerDot();

  @override
  Widget build(BuildContext context) {
    final DailyTodoItem? dailyTodoItem =
    context.findAncestorWidgetOfExactType<DailyTodoItem>();
    if (dailyTodoItem == null) return const SizedBox.shrink();
    final item = dailyTodoItem.dailyTodoItem;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.9),
              width: 1.0,
            ),
            color: item.autoPauseSeconds == 0
                ? Colors.grey[400]
                : item.autoPauseSeconds == 60
                ? Colors.yellowAccent
                : ToolThemeData.highlightColor,
          ),
        ),
      ),
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
      duration: const Duration(milliseconds: 900),
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