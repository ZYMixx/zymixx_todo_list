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

  static void showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(App.navigatorKey.currentContext!).removeCurrentSnackBar();
      ScaffoldMessenger.of(App.navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
