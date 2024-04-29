import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_date_formatter.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';

import '../../data/tools/tool_time_string_converter.dart';
import '../../domain/todo_item.dart';
import '../bloc/todo_item_bloc.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todoItem;

  TodoItemWidget({Key? key, required this.todoItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoItemBloc(todoItem: todoItem),
      child: TodoItemBody(),
    );
  }
}

class TodoItemBody extends StatefulWidget {
  const TodoItemBody({
    super.key,
  });

  @override
  State<TodoItemBody> createState() => _TodoItemBodyState();
}

class _TodoItemBodyState extends State<TodoItemBody> {
  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    bool isChangeTextMod = context.select((TodoItemBloc bloc) => bloc.state.changeTextMod);
    int lines = ((bloc.state.todoItem.content?.length ?? 100) / 38).toInt();
    DateTime? targetDateTime =
        context.select((TodoItemBloc bloc) => bloc.state.todoItem.targetDateTime);

    if (lines < 2) {
      lines = 2;
    }
    if (lines > 5) {
      lines = 5;
    }
    return AnimatedContainer(
      width: ToolThemeData.itemWidth,
      curve: Curves.easeInOut,
      //height: isChangeTextMod ? 300 : 100,
      height: isChangeTextMod
          ? (25 * lines).toDouble() + (ToolThemeData.itemHeight + 10)
          : (ToolThemeData.itemHeight),
      constraints: BoxConstraints(
        minHeight: isChangeTextMod
            ? (25 * lines).toDouble() + ToolThemeData.itemHeight
            : ToolThemeData.itemHeight,
      ),
      duration: Duration(milliseconds: 250),
      //ii
      child: Dismissible(
        key: UniqueKey(),
        background: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Opacity(
              opacity: 0.80,
              child: SizedBox(
                width: 35,
                child: Icon(
                  Icons.keyboard_double_arrow_right,
                  color: Colors.greenAccent,
                  size: 50,
                ),
              ),
            );
          },
          itemCount: 12, // Количество стрелок в узоре
        ),
        secondaryBackground: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(right: 30),
          reverse: true,
          itemBuilder: (context, index) {
            return Opacity(
              opacity: 0.85,
              child: SizedBox(
                width: 35,
                child: Icon(
                  Icons.keyboard_double_arrow_left,
                  color: Colors.redAccent,
                  size: 50,
                ),
              ),
            );
          },
          itemCount: 12, // Количество стрелок в узоре
        ),
        //right
        onDismissed: (DismissDirection direction) {
          bloc.add(DismissEvent(direction: direction));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: bloc.state.todoItem.category == EnumTodoCategory.social.name
                ? Colors.orangeAccent
                : Colors.blueAccent,
            gradient: bloc.state.todoItem.category == EnumTodoCategory.social.name
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.orangeAccent,
                      Colors.blueAccent,
                    ],
                    transform: GradientRotation(-0.04),
                    stops: [0.5, 1],
                  )
                : null,
            border: Border.all(
              color: Colors.red,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 12,
                fit: FlexFit.tight,
                child: GestureDetector(
                  onLongPress: () {},
                  onTap: () {},
                  child: isChangeTextMod ? TitleChangeWidget() : TitlePresentWidget(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 4),
                child: DecoratedBox(
                  decoration: ToolThemeData.defShadowBox,
                  child: ColoredBox(
                      color: targetDateTime?.getHighlightColor(targetDateTime) ?? Colors.black,
                      child: SizedBox(
                        width: 3,
                        height: double.infinity,
                      )),
                ),
              ),
              Flexible(flex: 6, child: TimerWorkWidget()),
              //SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class TitlePresentWidget extends StatelessWidget {
  const TitlePresentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var bloc = context.select((TodoItemBloc bloc) => bloc);
    String title = bloc.state.todoItem.title ?? 'no title';
    DateTime? targetDateTime =
        context.select((TodoItemBloc bloc) => bloc.state.todoItem.targetDateTime);
    return Stack(
      children: [
        Align(
            alignment: Alignment.bottomRight,
            child: Text(
              ToolDateFormatter.formatToMonthDay(targetDateTime) ?? '',
              style: TextStyle(
                color: bloc.state.todoItem.category == EnumTodoCategory.social.name
                    ? Colors.greenAccent
                    : Colors.black,
                fontWeight: bloc.state.todoItem.category == EnumTodoCategory.social.name
                    ? FontWeight.w700
                    : FontWeight.w600,
                fontSize: bloc.state.todoItem.category == EnumTodoCategory.social.name ? 13 : 11,
              ),
            )),
        InkWell(
          onTap: () {
            bloc.add(ChangeModEvent(isChangeMod: true));
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0, bottom: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                (' ' + (title.capitalizeFirst ?? '')) ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.5,
                    wordSpacing: -1.0,
                    height: 0.9,
                    shadows: ToolThemeData.defTextShadow),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TitleChangeWidget extends StatefulWidget {
  const TitleChangeWidget({Key? key}) : super(key: key);

  @override
  State<TitleChangeWidget> createState() => _TitleChangeWidgetState();
}

class _TitleChangeWidgetState extends State<TitleChangeWidget> {
  late TextEditingController _controllerTitle;
  late TextEditingController _controllerDescription;

  @override
  void initState() {
    super.initState();
    _controllerTitle = TextEditingController();
    _controllerDescription = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    _controllerTitle.text = bloc.state.todoItem.title ?? '';
    _controllerDescription.text = bloc.state.todoItem.content ?? '';
    DateTime? targetDateTime = bloc.state.todoItem.targetDateTime;
    String formattedTargetDateTime = ToolDateFormatter.formatToMonthDay(targetDateTime) ?? '';
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 4.0),
      child: Focus(
        onFocusChange: (focus) {
          if (focus) {
            _controllerTitle
              ..selection =
                  TextSelection(baseOffset: 0, extentOffset: _controllerTitle.text.length);
          }
          if (!focus) {
            print('focus locc add Event ${_controllerTitle.text.trim()}');
            Future.delayed(Duration.zero, () {
              bloc.add(
                LoseFocusEvent(
                  titleText: _controllerTitle.text.trim(),
                  descriptionText: _controllerDescription.text.trim(),
                ),
              );
              //bloc.add(ChangeModEvent(isChangeMod: false));
            });
          }
        },
        child: Column(
          children: [
            TextField(
              controller: _controllerTitle,
              autofocus: true,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                suffixIcon: Container(
                  width: 50,
                  height: 40,
                  alignment: Alignment.center,
                  child: InkWell(
                    focusNode: FocusNode(skipTraversal: true),
                    onTap: () => bloc.add(RequestChangeItemDateEvent(buildContext: context)),
                    onLongPress: () => bloc.add(SetItemDateEvent(userDateTime: DateTime.now())),
                    child: Text(
                      formattedTargetDateTime,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: ToolThemeData.defTextShadow,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all<Color>(Colors.black),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
                thickness: MaterialStateProperty.all<double>(5),
              ),
              child: TextField(
                controller: _controllerDescription,
                minLines: 2,
                maxLines: 5,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerWorkWidget extends StatefulWidget {
  const TimerWorkWidget({Key? key}) : super(key: key);

  @override
  State<TimerWorkWidget> createState() => _TimerWorkWidgetState();
}

class _TimerWorkWidgetState extends State<TimerWorkWidget> {
  TimeModEnum? lastTimeMod;

  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    TimeModEnum timerMod = context.select((TodoItemBloc bloc) => bloc.state.timerMod);
    String targetDataString =
        ToolDateFormatter.formatToMonthDay(bloc.state.todoItem.targetDateTime) ?? '';
    return Center(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          Offset animateOffset;
          if (child is StopwatchWidget) {
            animateOffset = Offset(-0.4, 0.0);
            lastTimeMod = TimeModEnum.stopwatch;
          } else if (child is TimerWidget) {
            animateOffset = Offset(0.4, 0.0);
            lastTimeMod = TimeModEnum.timer;
          } else {
            if (timerMod == TimeModEnum.timer) {
              animateOffset = Offset(-0.4, 0.0);
            } else {
              if (lastTimeMod == TimeModEnum.timer) {
                animateOffset = Offset(-0.4, 0.0);
                lastTimeMod = null;
              } else {
                animateOffset = Offset(0.4, 0.0);
                lastTimeMod = null;
              }
            }
          }
          var slideAnimation = Tween<Offset>(
            begin: animateOffset,
            end: Offset(0.0, 0.0),
          ).animate(animation);
          return FadeTransition(
              opacity: animation, child: SlideTransition(position: slideAnimation, child: child));
        },
        child: buildCrntWidget(bloc: bloc, timerMod: timerMod),
      ),
    );
  }

  Widget buildCrntWidget({required TodoItemBloc bloc, required TimeModEnum timerMod}) {
    switch (timerMod) {
      case TimeModEnum.timer:
        return TimerWidget();
      case TimeModEnum.stopwatch:
        return StopwatchWidget();
      case TimeModEnum.none:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.stopwatch));
                  });
                },
                icon: Icon(
                  Icons.timer,
                  color: Colors.black87,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.timer));
                  });
                },
                icon: Icon(
                  Icons.timelapse_outlined,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        );
    }
  }
}

class TimerWidget extends StatelessWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int timer = context.select((TodoItemBloc bloc) => bloc.state.todoItem.timerSeconds);
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    ToolTimeStringConverter.formatSecondsToTime(timer);
    String timerString = ToolTimeStringConverter.formatSecondsToTime(timer);
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: InkWell(
              onTap: () {
                bloc.add(ChangeTimerEvent(changeNum: -60));
              },
              onSecondaryTap: () {
                bloc.add(ChangeTimerEvent(changeNum: -300));
              },
              onLongPress: () {
                bloc.add(ChangeTimerEvent(changeNum: -3600));
              },
              child: Icon(
                Icons.remove,
                size: 16,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              bloc.add(StopStartTimerEvent());
            },
            onSecondaryTap: () {
              bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.none));
            },
            child: Row(
              children: [
                Text(
                  timerString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: ToolThemeData.defTextShadow,
                  ),
                ),
                Icon(
                  Icons.arrow_downward_outlined,
                  size: 14,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              bloc.add(ChangeTimerEvent(changeNum: 60));
            },
            onSecondaryTap: () {
              bloc.add(ChangeTimerEvent(changeNum: 300));
            },
            onLongPress: () {
              bloc.add(ChangeTimerEvent(changeNum: 3600));
            },
            child: Icon(
              Icons.add,
              size: 16,
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}

class StopwatchWidget extends StatelessWidget {
  const StopwatchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int stopwatch = context.select((TodoItemBloc bloc) => bloc.state.todoItem.stopwatchSeconds);
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    String stopwatchString = ToolTimeStringConverter.formatSecondsToTime(stopwatch);
    return IconButton(
      onPressed: null,
      icon: InkWell(
        onSecondaryTap: () {
          bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.none));
        },
        onTap: () {
          bloc.add(StopStartStopwatchEvent());
        },
        onLongPress: () {
          bloc.add(StopwatchResetTimeEvent());
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  stopwatchString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: ToolThemeData.defTextShadow,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_upward_outlined,
                size: 14,
                color: Colors.black,
              ),
              SizedBox(width: 3)
            ],
          ),
        ),
      ),
    );
  }
}

//grp Ext

extension HilightData on DateTime {
  bool isSameDay(DateTime date) {
    if (date.day == this.day && date.month == this.month && date.year == this.year) {
      return true;
    } else {
      return false;
    }
  }

  Color getHighlightColor(DateTime date) {
    DateTime today = DateTime.now();
    DateTime tomorrow = DateTime(today.year, today.month, today.day + 1);

    if (date.isSameDay(today)) {
      // Это сегодня
      return Colors.greenAccent[400]!;
    } else if (date.isSameDay(tomorrow)) {
      // Это завтра
      return Colors.orange;
    } else if (date.isBefore(today)) {
      // День уже прошёл
      return Colors.pinkAccent!;
    } else {
      // Это только ещё будет
      return Colors.grey;
    }
  }
}
