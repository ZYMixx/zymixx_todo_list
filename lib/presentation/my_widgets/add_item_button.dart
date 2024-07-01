import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_animated_card.dart';

class AddItemButton extends StatelessWidget {

  VoidCallback onTapAction;
  VoidCallback? onLongTapAction;
  VoidCallback? secondaryAction;
  Color? bgColor;

  AddItemButton({
    required this.onTapAction,
    this.onLongTapAction,
    this.secondaryAction,
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
          onLongTapAction?.call();
        },
        onSecondaryTap: () {
          secondaryAction?.call();
        },
        child: Container(
          width: ToolThemeData.itemWidth,
          height: 30,
          decoration: BoxDecoration(
            color: bgColor ?? ToolThemeData.mainGreenColor,
            border: Border.all(
              color: ToolThemeData.itemBorderColor,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }


}
