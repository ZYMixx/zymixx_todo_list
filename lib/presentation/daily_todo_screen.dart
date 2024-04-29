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
        create: (_) => DailyTodoBloc(),
        child: DailyTodoWidget(),
      ),
    );
  }
}

class DailyTodoWidget extends StatelessWidget {
  const DailyTodoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    List<TodoItem> dailyTodoList =
        context.select((AllItemControlBloc bloc) => bloc.state.todoDailyItemList);
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: dailyTodoList.length,
            itemBuilder: (context, itemId) {
              return DailyTodoItem(
                isComplete: dailyTodoList[itemId].isDone,
                name: dailyTodoList[itemId]?.title ?? '',
                itemId: dailyTodoList[itemId].id,
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
                // ToolShowOverlay.showUserInputOverlay(
                //   context: context,
                //   child: CreateDailyWidget(),
                // );
                context.read<DailyTodoBloc>().add(RequestAddNewDailyEvent(context: context));
              },
              //onTapAction: () => Get.find<AllItemControlBloc>().add(AddNewItemEvent(category: EnumTodoCategory.daily)),
              onLongTapAction: () => Get.find<AllItemControlBloc>().add(DellAllItemEvent()),
              bgColor: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class DailyTodoItem extends StatelessWidget {
  final bool isComplete;
  final String name;
  final int itemId;

  const DailyTodoItem(
      {required bool this.isComplete, required String this.name, required int this.itemId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: isComplete ? Colors.greenAccent : Colors.white70,
          border: Border.all(
            width: 1.5,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: InkWell(
          onTap: () {
            context
                .read<DailyTodoBloc>()
                .add(CompleteDailyEvent(isComplete: !isComplete, itemId: itemId));
          },
          onLongPress: (){
            context
                .read<DailyTodoBloc>()
                .add(DeleteDailyEvent(itemId: itemId));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedScale(
                duration: Duration(milliseconds: 200),
                scale: isComplete ? 1.2 : 0,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 150),
                  opacity: isComplete ? 1 : 0,
                  child: Icon(
                    Icons.check_outlined,
                    color: Colors.purpleAccent,
                    size: 30,
                  ),
                ),
              ),
              Center(
                child: Text(
                  name,
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
                scale: isComplete ? 1.2 : 0,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 100),
                  opacity: isComplete ? 1 : 0,
                  child: Icon(
                    Icons.check_outlined,
                    color: Colors.purpleAccent,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
