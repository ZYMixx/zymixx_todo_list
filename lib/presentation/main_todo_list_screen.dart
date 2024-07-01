import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:zymixx_todo_list/data/tools/tool_date_formatter.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/list_todo_screen_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_animated_card.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/todo_item_widget.dart';
import '../domain/todo_item.dart';
import 'my_widgets/add_item_button.dart';

class MainTodoListScreen extends StatelessWidget {
  MainTodoListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    return Theme(
      data: ThemeData(canvasColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: ToolThemeData.itemWidth,
          ),
          child: Column(
            children: [
              posItemList.isNotEmpty
                  ? Expanded(
                      child: ReorderableListView.builder(
                        onReorder: (oldItem, newItem) {
                          if (newItem < oldItem) {
                            Get.find<ListTodoScreenBloc>().add(ChangeOrderEvent(
                                replacedItemId: posItemList[newItem],
                                movedItemId: posItemList[oldItem]));
                          } else {
                            Get.find<ListTodoScreenBloc>().add(ChangeOrderEvent(
                                replacedItemId: posItemList[newItem - 1],
                                movedItemId: posItemList[oldItem]));
                          }
                        },
                        itemCount: posItemList.length,
                        padding: EdgeInsets.only(bottom: 15),
                        itemBuilder: (context, itemId) {
                          var orderedItem;
                          if (todoItemList.isNotEmpty) {
                            orderedItem =
                                todoItemList.firstWhere((item) => item.id == posItemList[itemId]);
                          }
                          return BlocProvider(
                            create: (_) => Get.find<AllItemControlBloc>(),
                            key: ValueKey(orderedItem),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: TodoItemWidget(
                                todoItem: orderedItem,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Text(
                          isShowTodayOnlyMod ? 'Nothing To Do Today' : 'No Tasks At All',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                offset: Offset(2, 2.1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              DecoratedBox(
                decoration: BoxDecoration(color: Colors.black12),
                child: Container(
                  height: 26,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(width: 2, color: Colors.black26)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyAnimatedCard(
                        intensity: 0.005,
                        directionUp: false,
                        child: InkWell(
                          onTap: () => context
                              .read<ListTodoScreenBloc>()
                              .add(ChangeTodayOnlyModEvent(!isShowTodayOnlyMod)),
                          splashColor: Colors.transparent,
                          child: Text(
                            '${Get.find<ToolDateFormatter>().formatToMonthDayWeek(DateTime.now())}',
                            style: TextStyle(
                                color: isShowTodayOnlyMod
                                    ? ToolThemeData.mainGreenColor
                                    : Colors.grey[200],
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: Offset(1, 1.5),
                                    blurRadius: 2,
                                  ),
                                ]),
                          ),
                        ),
                      ),
                      MyAnimatedCard(
                        intensity: 0.005,
                        directionUp: false,
                        child: InkWell(
                          onTap: () => context
                              .read<ListTodoScreenBloc>()
                              .add(ChangeTodayOnlyModEvent(!isShowTodayOnlyMod)),
                          splashColor: Colors.transparent,
                          child: Icon(
                            Icons.today,
                            color: isShowTodayOnlyMod
                                ? ToolThemeData.mainGreenColor
                                : Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ColoredBox(
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4, right: 8, left: 8),
                  child: AddItemButton(
                      onTapAction: () => Get.find<AllItemControlBloc>().add(AddNewItemEvent()),
                      onLongTapAction: () =>
                          Get.find<AllItemControlBloc>().add(DellAllItemEvent())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
