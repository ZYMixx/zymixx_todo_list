import 'package:flutter/material.dart';

import '../../presentation/App.dart';

class ToolNavigator {
  static void set(Widget screen) {
    Navigator.pushAndRemoveUntil(
        App.navigatorKey.currentContext!, _createFadeRoute(screen), (route) => route.isFirst);
  }

  static void pushReplacement(Widget screen) {
    Navigator.pushReplacement(App.navigatorKey.currentContext!, _createFadeRoute(screen));
  }

  static void push(Widget screen) {
    Navigator.push(
      App.navigatorKey.currentContext!,
      _createFadeRoute(
        screen,
      ),
    );
  }

  static popAndReplace(Widget screen) async {
    Navigator.pop(App.navigatorKey.currentContext!);
    Navigator.of(App.navigatorKey.currentContext!).pushReplacement(_createFadeRoute(screen));
  }

  static void pushAlert(Widget screen) {
    Navigator.push(
      App.navigatorKey.currentContext!,
      _createAlertRoute(screen),
    );
  }

  static void pop() {
    Navigator.pop(App.navigatorKey.currentContext!);
  }

  static Route _createFadeRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      barrierDismissible: true,
      opaque: false,
      transitionDuration: const Duration(milliseconds: 150),
      reverseTransitionDuration: const Duration(milliseconds: 100),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static Route _createAlertRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      barrierDismissible: true,
      opaque: false,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 0.04);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
