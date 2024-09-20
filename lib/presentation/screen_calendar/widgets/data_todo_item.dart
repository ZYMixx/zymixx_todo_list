import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';

import '../../../domain/enum_todo_category.dart';
import '../../../domain/todo_item.dart';
import '../../app_widgets/my_animated_card.dart';
import '../calendar_bloc.dart';

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
