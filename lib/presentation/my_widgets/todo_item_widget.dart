import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';

import '../../data/tools/tool_time_string_converter.dart';
import '../../domain/todo_item.dart';
import '../bloc/todo_item_bloc.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem intTodoItem;

  TodoItemWidget({Key? key, required this.intTodoItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoItemBloc(intTodoItem: intTodoItem),
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
    AllItemControlBloc allItemBloc = context.read<AllItemControlBloc>();
    return AnimatedContainer(
      width: ToolThemeData.itemWidth,
      curve: Curves.easeInOut,
      height: isChangeTextMod ? ToolThemeData.itemOpenHeight : ToolThemeData.itemHeight,
      duration: Duration(milliseconds: 250),
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) {
          bloc.add(DismissEvent(direction: direction));
          Future.delayed(Duration.zero, () {
            Log.i('srat reload');
            allItemBloc.add(LoadAllItemEvent());
          });
        },
        child: Container(
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
                flex: 5,
                fit: FlexFit.tight,
                child: GestureDetector(
                  onLongPress: (){},
                  onTap: (){},
                  child: isChangeTextMod ? TitleChangeWidget() : TitlePresentWidget(),
                ),
              ),
              VerticalDivider(
                width: 6,
                thickness: 2,
                indent: 4,
                endIndent: 4,
                color: Colors.red,
              ),
              Flexible(flex: 3, child: TimerWorkWidget())
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
    return InkWell(
      onTap: () {
        bloc.add(ChangeModEvent(isChangeMod: true));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 6.0, bottom: 4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
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
    return Padding(
        padding: const EdgeInsets.only(left: 6.0, bottom: 4.0),
        child: Focus(
          onFocusChange: (focus) {
            if (!focus) {
              print('focus locc add Event ${_controllerTitle.text.trim()}');
              Future.delayed(Duration.zero, () {
                bloc.add(LoseFocusEvent(titleText: _controllerTitle.text.trim(), descriptionText: _controllerDescription.text.trim(),),);
                bloc.add(ChangeModEvent(isChangeMod: false));
              });
            }
          },
          child: Column(
            children: [
              TextField(
                controller: _controllerTitle,
                autofocus: true,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              TextField(
                controller: _controllerDescription,
                maxLines: 4,
                minLines: 2,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ));
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
    return AnimatedSwitcher(
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
            if (lastTimeMod == TimeModEnum.timer ) {
              animateOffset = Offset(-0.4, 0.0);
              lastTimeMod= null;
            } else {
              animateOffset = Offset(0.4, 0.0);
              lastTimeMod= null;

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
            icon: InkWell(
              onSecondaryTap: (){
                bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.none));
              },
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    timerString,
                  ),
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
      icon: InkWell(
        onSecondaryTap: (){
          bloc.add(ChangeTimeModEvent(timerMod: TimeModEnum.none));
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              stopwatchString,
            ),
          ),
        ),
      ),
    );
  }
}
