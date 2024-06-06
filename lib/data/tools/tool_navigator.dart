import 'package:flutter/material.dart';

import '../../presentation/App.dart';

class ToolNavigator {
  static void set(
      {required Widget screen, BuildContext? context, PageRootEnum root = PageRootEnum.fade}) {
    Navigator.pushAndRemoveUntil(
      context ?? App.navigatorKey.currentContext!,
      root.getRoute(screen),
      (route) => route.isFirst,
    );
  }

  static void pushReplacement(
      {required Widget screen, BuildContext? context, PageRootEnum root = PageRootEnum.fade}) {
    Navigator.pushReplacement(App.navigatorKey.currentContext!, root.getRoute(screen));
  }

  static void push(
      {required Widget screen, BuildContext? context, PageRootEnum root = PageRootEnum.fade}) {
    Navigator.push(
      context ?? App.navigatorKey.currentContext!,
      root.getRoute(
          screen
      ),
    );
  }

  static void pushSecond(
      {required Widget screen, BuildContext? context, PageRootEnum root = PageRootEnum.fade}) {
    Navigator.push(
      context ?? App.navigatorKey.currentContext!,
      root.getRoute(
        screen,
      ),
    );
  }

  static popAndReplace(
      {required Widget screen, BuildContext? context, PageRootEnum root = PageRootEnum.fade}) {
    Navigator.pop(App.navigatorKey.currentContext!);
    Navigator.of(App.navigatorKey.currentContext!).pushReplacement(root.getRoute(screen));
  }

  static void pop() {
    Navigator.pop(App.navigatorKey.currentContext!);
  }
}

enum PageRootEnum {
  fade,
  slide,
  alert,
  empty;

  Route getRoute(Widget widget) {
    switch (this) {
      case PageRootEnum.fade:
        return _createFadeRoute(widget);
      case PageRootEnum.slide:
        return _createSlideRoute(widget);
      case PageRootEnum.alert:
        return _createAlertRoute(widget);
      case PageRootEnum.empty:
        return _createEmptyRoute(widget);
    }
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

  static Route _createSlideRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      barrierDismissible: true,
      opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeIn;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: tween.animate(animation),
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

  static Route _createEmptyRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      barrierDismissible: true,
      opaque: true,
      transitionDuration: const Duration(milliseconds: 10),
      reverseTransitionDuration: const Duration(milliseconds: 10),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
