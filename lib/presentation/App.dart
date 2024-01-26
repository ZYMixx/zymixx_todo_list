import 'dart:async';

import 'package:flutter/material.dart';
import '../data/services/service_window_manager.dart';
import 'launch_screen.dart';

class App {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void start() async {
    navigatorKey = GlobalKey<NavigatorState>();
    runZonedGuarded(() {
      runApp(
        MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: ThemeData.light(),
            debugShowMaterialGrid: false,
            home: LaunchScreen()),
      );
    }, (error, stackTrace) {
      print('Error occurred: $error');
      print('Stack trace: $stackTrace');
    });
  }
}
