import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/presentation/app.dart';

class ToolNavigator {
  static void set<T extends Widget>(
      {required T screen, BuildContext? context, PageRootEnum root = PageRootEnum.fade}) {
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

  static Future<T?> push<T extends Widget>({
    required T screen,
    BuildContext? context,
    PageRootEnum root = PageRootEnum.fade,
  }) {
    return Navigator.push(
      context ?? App.navigatorKey.currentContext!,
      root.getRoute<T>(screen),
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

  Route<T> getRoute<T extends Widget>(T widget) {
    switch (this) {
      case PageRootEnum.fade:
        return _createFadeRoute<T>(widget);
      case PageRootEnum.slide:
        return _createSlideRoute<T>(widget);
      case PageRootEnum.alert:
        return _createAlertRoute<T>(widget);
      case PageRootEnum.empty:
        return _createEmptyRoute<T>(widget);
    }
  }

  static Route<T> _createFadeRoute<T extends Widget>(T widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      settings: RouteSettings(name: T.toString()),
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

  static Route<T> _createSlideRoute<T extends Object?>(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      settings: RouteSettings(name: T.toString()),
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

  static Route<T> _createAlertRoute<T extends Object?>(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      settings: RouteSettings(name: T.toString()),
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

  static Route<T> _createEmptyRoute<T extends Object?>(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      settings: RouteSettings(name: T.toString()),
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

class AppNavigatorObserver extends NavigatorObserver {
  Route? currentRoute;
  String? currentRouteName;
  List<String> routeNameStack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = route;
    currentRouteName = route.settings.name;  // Сохраняем имя текущего маршрута
    if (currentRouteName != null) {
      routeNameStack.add(currentRouteName!);  // Добавляем имя в стек
    }
    print('Navigated to: ${currentRouteName ?? route.runtimeType}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (currentRouteName != null) {
      routeNameStack.removeLast();  // Удаляем последнее имя из стека, если оно не null
    }
    currentRoute = previousRoute;
    currentRouteName = previousRoute?.settings.name;  // Обновляем текущее имя
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      routeNameStack.remove(route.settings.name);  // Удаляем имя из стека, если оно не null
    }
    print('Removed route: ${route.settings.name ?? route.runtimeType}');
    currentRoute = previousRoute;
    currentRouteName = previousRoute?.settings.name;  // Обновляем текущее имя
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null && newRoute != null) {
      int index = routeNameStack.indexOf(oldRoute.settings.name!);
      if (index != -1) {
        routeNameStack[index] = newRoute.settings.name!;  // Заменяем имя в стеке
      }
      print('Replaced route: ${oldRoute.settings.name ?? oldRoute.runtimeType} '
          'with: ${newRoute.settings.name ?? newRoute.runtimeType}');
    }
    currentRoute = newRoute;
    currentRouteName = newRoute?.settings.name;  // Обновляем текущее имя
  }

  // Метод для получения текущего стека имен
  List<String> getRouteNameStack() {
    return List.unmodifiable(routeNameStack);  // Возвращаем неизменяемую копию стека имен
  }

  // Метод для получения текущего маршрута
  Route? getCurrentRoute() {
    return currentRoute;
  }
}
