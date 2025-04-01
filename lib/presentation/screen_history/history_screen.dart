import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

import '../bloc_global/all_item_control_bloc.dart';

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
    Map<String, List<TodoItem>> groupedMap = groupItemsByWeek(todoHistoryItemList);
    List<String> weekKeys = groupedMap.keys.toList()
      ..sort((a, b) {
        DateTime dateA = _parseWeekKey(a); // Преобразуем ключ "Неделя" в дату
        DateTime dateB = _parseWeekKey(b);
        return dateB.compareTo(dateA); // Сортируем от новых к старым
      });

    return Scaffold(
      backgroundColor: Colors.transparent, // Темный фон для современного вида
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ListView.builder(
          itemCount: weekKeys.length,
          itemBuilder: (context, index) {
            String weekKey = weekKeys[index];
            List<TodoItem> items = groupedMap[weekKey]!;
            int socialCount =
                items.where((item) => item.category == EnumTodoCategory.history_social.name).length;
            int allSecondsSpent =
                items.fold(0, (previousValue, element) => previousValue + element.secondsSpent);
            List<Widget> itemWidgets =
                items.map((item) => TodoHistoryItem(todoItem: item)).toList();
            return Card(
              color: Color(0xFF2E2E4E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                backgroundColor: Colors.transparent,
                collapsedIconColor: Colors.white,
                title: Text(
                  weekKey.split('(').first.trim(), // Берем только визуальную часть
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  '${items.length} задач | ${(allSecondsSpent / 60).toInt()} мин | $socialCount story',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                children: itemWidgets,
              ),
            );
          },
        ),
      ),
    );
  }

  DateTime _parseWeekKey(String weekKey) {
    // Берем только внутренний формат (часть с годом)
    List<String> parts = weekKey.split('(');
    String internalKey = parts.last.replaceAll(')', '').trim().split(' - ').first;

    // Парсим внутренний формат с годом
    DateFormat fullDateFormat = DateFormat('dd MMM yyyy', 'ru');
    return fullDateFormat.parse(internalKey);
  }

  // Метод для группировки по неделям
  Map<String, List<TodoItem>> groupItemsByWeek(List<TodoItem> items) {
    Map<String, List<TodoItem>> groupedItems = {};
    for (var item in items) {
      DateTime date = item.targetDateTime!;
      String weekKey = _calculateWeek(date); // Группировка по неделям
      groupedItems.putIfAbsent(weekKey, () => []).add(item);
    }
    return groupedItems;
  }

  // Метод для вычисления начала и конца недели
  String _calculateWeek(DateTime itemDate) {
    DateTime monday = itemDate.subtract(Duration(days: itemDate.weekday - 1));
    DateTime sunday = monday.add(Duration(days: 6));

    // Форматы для внутреннего использования и отображения
    DateFormat fullDateFormat = DateFormat('dd MMM yyyy', 'ru'); // С годом
    DateFormat shortDateFormat = DateFormat('dd MMM', 'ru'); // Без года

    // Сохраняем ключ с годом для внутренней сортировки, но отображаем только день и месяц
    String formattedMonday = shortDateFormat.format(monday);
    String formattedSunday = shortDateFormat.format(sunday);

    return '$formattedMonday - $formattedSunday (${fullDateFormat.format(monday)} - ${fullDateFormat.format(sunday)})';
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
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
      child: InkWell(
        onTap: () => setState(() {
          isClicked = !isClicked;
        }),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isClicked
                ? Colors.grey[300]
                : socialHistory
                    ? ToolThemeData.specialItemColor
                    : Colors.blue[200],
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: isClicked
                      ? Text(
                          widget.todoItem.content!.isEmpty
                              ? 'Нет описания'
                              : widget.todoItem.content!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          widget.todoItem.title!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                ),
                if (!isClicked && widget.todoItem.secondsSpent > 60)
                  Text(
                    '${(widget.todoItem.secondsSpent / 60).toInt()} мин',
                    style: TextStyle(
                      color: ToolThemeData.highlightColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () => Get.find<AllItemControlBloc>()
                      .add(DeleteItemEvent(todoItem: widget.todoItem)),
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFFF5555),
                    size: 24,
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () => Get.find<AllItemControlBloc>().add(ChangeItemEvent(
                    todoItem: widget.todoItem,
                    category: socialHistory ? EnumTodoCategory.social : EnumTodoCategory.active,
                  )),
                  child: Icon(
                    Icons.undo,
                    color: Colors.black,
                    size: 24,
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
