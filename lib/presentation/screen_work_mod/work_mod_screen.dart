import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

import '../bloc_global/all_item_control_bloc.dart';
import '../bloc_global/list_todo_screen_bloc.dart';
import '../screen_main_todo_list/widgets/todo_item_widget.dart';

const platform = MethodChannel('ru.zymixx/zymixxWindowsChannel');

class WorkModScreen extends StatelessWidget {
  const WorkModScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkModWidget();
  }
}

Future<void> setIgnore(bool ignore) async {
  return await windowManager.setIgnoreMouseEvents(ignore);
}

class WorkModWidget extends StatefulWidget {
  @override
  _WorkModWidgetState createState() => _WorkModWidgetState();
}

class _WorkModWidgetState extends State<WorkModWidget> {
  Offset _position = Offset.zero;
  Color _backgroundColor = Colors.transparent;
  Color splashColor = Colors.blueAccent.withOpacity(0.9);
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    AllItemControlBloc allBloc = Get.find<AllItemControlBloc>();
    List<int> idList =
        Get.find<ListTodoScreenBloc>().state.getPositionItemList(allBloc.state.todoActiveItemList);
    TodoItem? todoItem;
    if (idList.isNotEmpty) {
      todoItem =
          allBloc.state.todoActiveItemList.firstWhere((element) => element.id == idList.last);
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapDown: _onPress,
            child: MouseRegion(
              onEnter: _onEnter,
              onHover: _onHover,
              onExit: _onExit,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 70),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  gradient: RadialGradient(
                    center: Alignment(
                      (_position.dx / constraints.maxWidth) * 2 - 1,
                      (_position.dy / constraints.maxHeight) * 2 - 1,
                    ),
                    radius: 1.7,
                    colors: [
                      _backgroundColor,
                      _backgroundColor,
                      splashColor,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: IgnorePointer(
                  child: todoItem != null
                      ? TodoItemWidget(
                          todoItem: todoItem,
                          bgColor: Colors.transparent,
                        )
                      : Center(
                          child: Text('no any todo to show'),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onEnter(PointerEvent details) {
    mouseExitScreen = false;
    setState(() {
      _position = details.localPosition;
      _backgroundColor = Colors.transparent;
      isHovered = true;
    });
  }

  bool mouseExitScreen = false;

  void _onHover(PointerEvent details) {
    setState(() {
      _position = details.localPosition;
    });
  }

  void _onExit(PointerEvent details) {
    mouseExitScreen = true;
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      if (isHovered && mouseExitScreen) {
        setState(() {
          _backgroundColor = splashColor;
          isHovered = false;
        });
      }
    });
  }

  Timer? _timer;

  _onPress(TapDownDetails details) async {
    await setIgnore(true);
    await platform.invokeMethod('simulateMouseClick');
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 500), () async {
      await setIgnore(false);
    });
  }
}
