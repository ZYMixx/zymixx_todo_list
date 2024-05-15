import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/mu_animated_card.dart';

class AddItemButton extends StatelessWidget {

  VoidCallback onTapAction;
  VoidCallback onLongTapAction;
  Color? bgColor;

  AddItemButton({
    required this.onTapAction,
    required this.onLongTapAction,
    this.bgColor,
  });
  @override
  Widget build(BuildContext context) {
    return MyAnimatedCard(
      intensity: 0.005,
      child: InkWell(
        onTap: () {
          onTapAction.call();
        },
        onLongPress: () {
          onLongTapAction.call();
        },
        child: Container(
          width: ToolThemeData.itemWidth,
          height: 30,
          decoration: BoxDecoration(
            color: bgColor ?? Colors.green,
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
      ),
    );
  }


}
