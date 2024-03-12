import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';

class AddItemButton extends StatelessWidget {
  const AddItemButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<AllItemControlBloc>().add(AddNewItemEvent());
      },
      onLongPress: () {
        Get.find<AllItemControlBloc>().add(DellAllItemEvent());
      },
      child: Container(
        width: ToolThemeData.itemWidth,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: MoveWindow(
          child: Center(
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
