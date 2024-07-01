import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import '../../presentation/app.dart';

class ToolShowToast {
  void show(String message) {
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        margin: EdgeInsets.only(bottom: 30),
        backgroundColor: ToolThemeData.highlightGreenColor.withOpacity(0.9),
        duration: Duration(seconds: 2),
        elevation: 5,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showError(String message, {int? duration}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(App.navigatorKey.currentContext!).removeCurrentSnackBar();
      ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          margin: EdgeInsets.only(bottom: 30),
          duration: Duration(seconds: duration ?? 3),
          backgroundColor: ToolThemeData.itemBorderColor.withOpacity(0.8),
          elevation: 5,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void showWithCallBack(
      {required String message,
      required VoidCallback callback,
      Color? bgColor,
      String? labelCallback}) {
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          onPressed: () => callback.call(),
          label: labelCallback ?? 'Вернуть?',
          backgroundColor: Colors.white,
          textColor: Colors.black,
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        margin: EdgeInsets.only(bottom: 30),
        backgroundColor: bgColor ?? Colors.purple.withOpacity(0.9),
        duration: Duration(milliseconds: 3500),
        elevation: 5,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
