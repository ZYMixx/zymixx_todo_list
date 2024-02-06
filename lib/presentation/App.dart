import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/service_get_time.dart';
import '../data/services/service_window_manager.dart';
import 'bloc/all_item_control_bloc.dart';
import 'launch_screen.dart';

class App {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void start() async {
    navigatorKey = GlobalKey<NavigatorState>();
    await initGet();
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

initGet() {
  Get.put<ServiceGetTime>(ServiceGetTime());
  Get.put<AllItemControlBloc>(AllItemControlBloc());
}
