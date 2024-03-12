import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/services/service_background_key_listener.dart';
import '../data/services/service_get_time.dart';
import '../data/services/service_window_manager.dart';
import 'bloc/all_item_control_bloc.dart';
import 'launch_screen.dart';

class App {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void start() async {
    navigatorKey = GlobalKey<NavigatorState>();
    await _initGet();
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
    //_configWindows();
    //_setUpKeyListener();
  }

  static _configWindows() {
    ServiceWindowManager().init();
  }

  static _setUpKeyListener() async {
    await ServiceBackgroundKeyListener.initPlatformState();
    ServiceBackgroundKeyListener.addUserCallBacks(
      codeKey: '1',
      needAltDown: true,
      callBack: () {
        ServiceWindowManager().testHideBG();
      },
    );
    ServiceBackgroundKeyListener.startListening();
  }

  static _initGet() {
    Get.put<ServiceGetTime>(ServiceGetTime());
    Get.put<AllItemControlBloc>(AllItemControlBloc());
  }

}


