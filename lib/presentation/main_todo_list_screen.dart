import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/list_todo_screen_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_radio_icon.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/todo_item_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../domain/todo_item.dart';
import 'my_widgets/add_item_button.dart';

class MainTodoListScreen extends StatefulWidget {
  MainTodoListScreen({Key? key}) : super(key: key);

  @override
  State<MainTodoListScreen> createState() => _MainTodoListScreenState();
}

class _MainTodoListScreenState extends State<MainTodoListScreen> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
    });
    return BlocProvider(
        create: (_) {
          return Get.find<AllItemControlBloc>();
        },
        child: BlocProvider(
            create: (_) {
              return Get.find<ListTodoScreenBloc>();
            },
            child: ItemBoxWidget()));
  }
}

class ItemBoxWidget extends StatelessWidget {
  const ItemBoxWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isShowTodayOnlyMod =
        context.select((ListTodoScreenBloc bloc) => bloc.state.isShowTodayOnlyMod);
    List<TodoItem> todoItemList =
        context.select((AllItemControlBloc bloc) => bloc.state.todoActiveItemList);
    List<int> posItemList =
        context.select((ListTodoScreenBloc bloc) => bloc.state.getPositionItemList(todoItemList));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: ToolThemeData.itemWidth,
        ),
        child: Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                onReorder: (oldItem, newItem) {
                  if (newItem < oldItem) {
                    Get.find<ListTodoScreenBloc>()
                        .add(ChangeOrderEvent(replacedItemPos: newItem, movedItemPos: oldItem));
                  } else {
                    Get.find<ListTodoScreenBloc>()
                        .add(ChangeOrderEvent(replacedItemPos: newItem - 1, movedItemPos: oldItem));
                  }
                },
                itemCount: posItemList.length,
                padding: EdgeInsets.only(bottom: 15),
                itemBuilder: (context, itemId) {
                  var orderedItem =
                      todoItemList.firstWhere((item) => item.id == posItemList[itemId]);
                  return todoItemList.isNotEmpty
                      ? BlocProvider(
                          create: (_) => Get.find<AllItemControlBloc>(),
                          key: ValueKey(orderedItem),
                          child: Material(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: TodoItemWidget(
                                todoItem: orderedItem,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text('No Deal'),
                        );
                },
              ),
            ),
            Container(
              height: 26,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyRadioIcon(
                    onSelect: () {
                      context.read<ListTodoScreenBloc>().add(ChangeTodayOnlyModEvent(true));
                    },
                    onDeselect: () {
                      context.read<ListTodoScreenBloc>().add(ChangeTodayOnlyModEvent(false));
                    },
                    iconData: Icons.today,
                    size: 26,
                    initStatus: isShowTodayOnlyMod,
                  )
                ],
              ),
            ),
            Opacity(
              opacity: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: AddItemButton(
                    onTapAction: () => Get.find<AllItemControlBloc>().add(AddNewItemEvent()),
                    onLongTapAction: () => Get.find<AllItemControlBloc>().add(DellAllItemEvent())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
