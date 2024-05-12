import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/action_screens/create_daily_widget.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/daily_todo_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/add_item_button.dart';

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
    List<TodoItem> dailyTodoList = context
        .select((AllItemControlBloc bloc) => bloc.state.todoDailyItemList)
        .where(
            (element) => element.targetDateTime != null && element.targetDateTime!.isSameDay(now))
        .toList();
    return Column(
      children: [
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
              onLongTapAction: () => Get.find<AllItemControlBloc>().add(DellAllItemEvent()),
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

  //final bool dailyTodoItem.isDone;
  //final String name;
  //final int itemId;
  //final int? timerSeconds;

  const DailyTodoItem({
    required this.dailyTodoItem
  });

  @override
  State<DailyTodoItem> createState() => _DailyTodoItemState();
}

class _DailyTodoItemState extends State<DailyTodoItem> {
  bool timerIsRun = false;
  int? remainTimer;

  @override
  void initState() {
    remainTimer = widget.dailyTodoItem.timerSeconds;
    Get.find<DailyTodoBloc>().checkOnActiveTimer(
        itemId: widget.dailyTodoItem.id, updateCallBack: secondUpdate);
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
    return Padding(
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
            context
                .read<DailyTodoBloc>()
                .add(DeleteDailyEvent(itemId: widget.dailyTodoItem.id,
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
                  Center(
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
              if (widget.dailyTodoItem.timerSeconds > 0) Padding(
                padding: const EdgeInsets.only(right: 60.0, top: 5),
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
                              : widget.dailyTodoItem.autoPauseSeconds == 60 ? Colors.yellowAccent
                              : Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    remainTimer == 0 ? '' : '$remainTimer',
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
              )
            ],
          ),
        ),
      ),
    );
  }
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
