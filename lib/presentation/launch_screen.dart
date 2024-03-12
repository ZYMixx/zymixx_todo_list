import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/item_botton_navigator_bar.dart';
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
    double listViewHeight = (ToolThemeData.itemHeight + 8) * (todoItemList.length + 1);
    Log.i(listViewHeight);
    Log.i(todoItemList.length);
    return Scaffold(
      bottomNavigationBar: ItemBottomNavigatorBar(),
        backgroundColor: Colors.transparent,
        body: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: listViewHeight < 400 ? listViewHeight : 400,
            minWidth: ToolThemeData.itemWidth,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  addAutomaticKeepAlives: false,
                  itemCount: todoItemList.length ,
                  padding: EdgeInsets.only(bottom: 15),
                  itemBuilder: (context, itemId) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TodoItemWidget(
                        intTodoItem: todoItemList[itemId],
                        key: ValueKey(todoItemList[itemId]),
                      ),
                    );
                  },
                ),
              ),
          AddItemButton(),
            ],
          ),
        ));
  }
}
