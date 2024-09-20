import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/presentation/bloc_global/all_item_control_bloc.dart';
import '../../../data/tools/tool_logger.dart';
import '../../../domain/todo_item.dart';
import '../../app_widgets/my_animated_card.dart';
import '../calendar_bloc.dart';
import 'data_todo_item.dart';

class DayDataBlockWidget extends StatelessWidget {
  const DayDataBlockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var itemList = context.select((AllItemControlBloc bloc) => bloc.state.todoActiveItemList);
    DateTime? selectDate = context.select((CalendarBloc bloc) => bloc.state.selectedDateTime);
    List<TodoItem> todoTodoItemList = itemList.where((TodoItem todoItem) {
      if (todoItem.targetDateTime == null || selectDate == null) {
        return false;
      } else {
        return selectDate.isSameDay(todoItem.targetDateTime!);
      }
    }).toList();
    Log.i('call rebuild calendar item');
    todoTodoItemList = todoTodoItemList.reversed.toList();
    return Column(
      children: [
        MyAnimatedCard(
          intensity: 0.007,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
            child: InkWell(
              onTap: () {
                if (selectDate != null) {
                  Get.find<AllItemControlBloc>().add(AddNewItemEvent(dateTime: selectDate));
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: Center(
                  child: Text(
                    '${selectDate?.getStringDate() ?? 'no select'}',
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: ListView.builder(
              itemCount: todoTodoItemList.length,
              itemBuilder: (context, itemId) {
                return DataTodoItem(
                  todoItem: todoTodoItemList[itemId],
                  key: ValueKey(todoTodoItemList),
                );
              }),
        ),
      ],
    );
  }
}
