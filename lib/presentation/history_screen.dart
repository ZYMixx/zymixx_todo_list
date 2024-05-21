import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_date_formatter.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_expansion_panel.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_radio_icon.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllItemControlBloc>(
        create: (_) => Get.find<AllItemControlBloc>(), child: HistoryScreenWidget());
  }
}

class HistoryScreenWidget extends StatefulWidget {
  const HistoryScreenWidget({Key? key}) : super(key: key);

  @override
  _HistoryScreenWidgetState createState() => _HistoryScreenWidgetState();
}

class _HistoryScreenWidgetState extends State<HistoryScreenWidget> {
  TodoItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    List<TodoItem> todoHistoryItemList =
        context.select((AllItemControlBloc bloc) => bloc.state.todoHistoryItemList);
    Map<DateTime, List<TodoItem>> groupedMap = groupItemsByDate(todoHistoryItemList);
    List<DateTime> dates = groupedMap.keys.toList()..sort((a, b) => b.compareTo(a));
    return ListView.builder(
      itemCount: dates.length,
      itemBuilder: (context, index) {
        DateTime date = dates[index];
        List<TodoItem> items = groupedMap[date]!;
        List<Widget> itemWidgets = items.map((item) => TodoHistoryItem(todoItem: item)).toList();
        return MyExpansionPanel(
          listWidget: itemWidgets,
          panelTitle:
              '${ToolDateFormatter.formatToMonthDayWeek(date) ?? 'No Date'}_ ${items.length} _ ${'77'} min',
          widgetHeight: 45,
        );
      },
    );
  }

  Map<DateTime, List<TodoItem>> groupItemsByDate(List<TodoItem> items) {
    Map<DateTime, List<TodoItem>> groupedItems = {};
    for (var item in items) {
      DateTime date = item.targetDateTime!;
      DateTime day = DateTime(date.year, date.month, date.day);
      groupedItems.putIfAbsent(day, () => []).add(item);
    }
    return groupedItems;
  }
}

class TodoHistoryItem extends StatefulWidget {
  final TodoItem todoItem;

  const TodoHistoryItem({super.key, required this.todoItem});

  @override
  State<TodoHistoryItem> createState() => _TodoHistoryItemState();
}

class _TodoHistoryItemState extends State<TodoHistoryItem> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    bool socialHistory = widget.todoItem.category == EnumTodoCategory.history_social.name;
    Log.i('${widget.todoItem.title} - ${widget.todoItem.category}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
      child: InkWell(
        onTap: () => setState(() {
          isClicked = !isClicked;
        }),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isClicked
                ? Colors.grey[200]
                : socialHistory
                    ? Colors.orangeAccent[100]
                    : Colors.blue[100],
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: isClicked
                      ? Text(
                          widget.todoItem.content!.length < 2
                              ? 'нет описания'
                              : widget.todoItem.content!,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Center(
                              child: Text(
                            widget.todoItem.title!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          )),
                        ),
                ),
                if (!isClicked && widget.todoItem.secondsSpent > 60)
                  Text(
                    '${(widget.todoItem.secondsSpent / 60).toInt()}',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (!isClicked && widget.todoItem.secondsSpent > 60) Text('-min'),
                if (!isClicked) SizedBox(width: 10),
                InkWell(
                  onTap: () => Get.find<AllItemControlBloc>()
                      .add(DeleteItemEvent(todoItem: widget.todoItem)),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red[900],
                  ),
                ),
                SizedBox(
                  width: 4,
                ),
                InkWell(
                  onTap: () => Get.find<AllItemControlBloc>().add(ChangeItemEvent(
                    todoItem: widget.todoItem,
                    category: socialHistory ? EnumTodoCategory.social : EnumTodoCategory.active,
                  )),
                  child: Icon(Icons.undo),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
