import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/todo_item_widget.dart';

import '../domain/todo_item.dart';
import 'my_widgets/add_item_button.dart';

class LaunchScreen extends StatelessWidget {
  LaunchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
    });
    return BlocProvider(
        create: (_) {
          return Get.find<AllItemControlBloc>();
        },
        child: ItemBoxWidget());
  }
}

class ItemBoxWidget extends StatelessWidget {
  const ItemBoxWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<TodoItem> todoItemList =
        context.select((AllItemControlBloc bloc) => bloc.state.todoItemList);
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.builder(
          addAutomaticKeepAlives: false,
          itemCount: todoItemList.length + 1,
          itemBuilder: (context, itemId) {
            if (itemId == todoItemList.length) {
              return AddItemButton();
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TodoItemWidget(
                intTodoItem: todoItemList[itemId],
                key: ValueKey(todoItemList[itemId]),
              ),
            );
          },
        ));
  }
}
