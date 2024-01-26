import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vec;
import 'package:window_manager/window_manager.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/todo_item_widget.dart';

class LaunchScreen extends StatelessWidget {
  LaunchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: TodoItemWidget(),
      ),
    );
  }
}
