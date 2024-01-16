import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../data/services/service_window_manager.dart';
import 'launch_screen.dart';

class App {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  //static late StreamSubscription<bool> keyboardSubscription;
  static void start() async {
    navigatorKey = GlobalKey<NavigatorState>();
    // var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    //  print('Keyboard visibility direct query: ${keyboardVisibilityController.isVisible}');

    // Subscribe
    // keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
    // print('Keyboard visibility update. Is visible: $visible');
    // });
    runZonedGuarded(() {
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData.light(),
          debugShowMaterialGrid: false,
          home: LaunchScreen(),
        ),
      );
      ServiceWindowManager().init();
    }, (error, stackTrace) {
      print('Error occurred: $error');
      print('Stack trace: $stackTrace');
    });
    VirtualWindowFrameInit();
  }
}
