import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/tools/tool_time_string_converter.dart';
import '../../domain/todo_item.dart';
import '../bloc/todo_item_bloc.dart';

class TodoItemWidget extends StatelessWidget {
  TodoItem intTodoItem;

  TodoItemWidget({Key? key, required this.intTodoItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoItemBloc(intTodoItem: intTodoItem),
      child: TodoItemBody(),
    );
  }
}

class TodoItemBody extends StatelessWidget {
  const TodoItemBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);

    return Dismissible(
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) {
        bloc.add(DismissEvent(direction: direction));
      },
      child: Container(
        width: 400,
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          border: Border.all(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: [
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: TitleWidget(),
            ),
            VerticalDivider(
              width: 6,
              thickness: 2,
              indent: 4,
              endIndent: 4,
              color: Colors.red,
            ),
            Flexible(flex: 1, child: TimerWorkWidget())
          ],
        ),
      ),
    );
  }
}

class TitleWidget extends StatefulWidget {
  const TitleWidget({Key? key}) : super(key: key);

  @override
  State<TitleWidget> createState() => _TitleWidgetState();
}

class _TitleWidgetState extends State<TitleWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);

    controller.text = bloc.state.todoItem.title ?? '';
    return Padding(
      padding: const EdgeInsets.only(left: 6.0, bottom: 4.0),
      child: Focus(
        onFocusChange: (focus) {
          if (!focus) {
            print('focus locc add Event ${controller.text.trim()}');
            bloc.add(LoseFocusEvent(titleText: controller.text.trim()));
          }
        },
        child: TextField(
          controller: controller,
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
  @override
  Widget build(BuildContext context) {
    TodoItemBloc bloc = context.select((TodoItemBloc bloc) => bloc);
    TimeModEnum timerMod = context.select((TodoItemBloc bloc) => bloc.state.timerMod);
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        Offset animateOffset;
        if (child is StopwatchWidget) {
          animateOffset = Offset(-0.4, 0.0);
        } else if (child is TimerWidget) {
          animateOffset = Offset(0.4, 0.0);
        } else {
          if (timerMod == TimeModEnum.timer) {
            animateOffset = Offset(-0.4, 0.0);
          } else {
            animateOffset = Offset(0.4, 0.0);
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
              fit: FlexFit.tight,
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
          InkWell(
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
          IconButton(
            onPressed: () {
              bloc.add(ResumeTimerEvent());
            },
            iconSize: 140,
            icon: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  timerString,
                ),
              ),
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
      onPressed: () {
        bloc.add(ResumeStopwatchEvent());
      },
      iconSize: 140,
      icon: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            stopwatchString,
          ),
        ),
      ),
    );
  }
}
