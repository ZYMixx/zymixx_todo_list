import 'package:flutter/material.dart';
import '../../presentation/App.dart';

class ToolShowToast {
  static void show(String message) {
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor: Colors.green.withOpacity(0.9),
        duration: Duration(seconds: 2),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showError(String message, {int? duration}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(App.navigatorKey.currentContext!).removeCurrentSnackBar();
      ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          duration: Duration(seconds: duration ?? 3),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  static void showWithCallBack({required String message, required  VoidCallback callback}) {
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).removeCurrentSnackBar();
    ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        action: SnackBarAction(onPressed: ()=>callback.call(), label: 'Вернуть?', backgroundColor: Colors.white, textColor: Colors.black,),
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        margin: EdgeInsets.only(bottom: 30),
        backgroundColor: Colors.purple.withOpacity(0.9),
        duration: Duration(milliseconds: 3500),
        elevation: 5,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
