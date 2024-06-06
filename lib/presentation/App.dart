import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';
import 'package:zymixx_todo_list/data/services/service_background_key_listener.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_navigator.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/presentation/bloc/daily_todo_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/list_todo_screen_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_bottom_navigator_screen.dart';
import 'package:zymixx_todo_list/presentation/work_mod_screen.dart';
import '../data/services/service_window_manager.dart';
import 'bloc/all_item_control_bloc.dart';

class App {
  static late GlobalKey<NavigatorState> navigatorKey;
  static bool inWorkMod = false;
  static const bool isRelease = bool.fromEnvironment('dart.vm.product');


  static void start() async {
    navigatorKey = GlobalKey<NavigatorState>();
    runZonedGuarded(() async {
      initializeDateFormatting('ru');
      WidgetsFlutterBinding.ensureInitialized();
      await _initGet();
      await _setUpKeyListener();
      await _configWindows();
      await _initSystemTray();
      runApp(
        MaterialApp(
            debugShowCheckedModeBanner: true,
            navigatorKey: navigatorKey,
            theme: ThemeData.light(),
            debugShowMaterialGrid: false,
            localizationsDelegates: [
              ...GlobalMaterialLocalizations.delegates,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('ru'),
            ],
            home: MyBottomNavigatorScreen()),
      );
    }, (error, stackTrace) {
      print('Error occurred: $error');
      if (error is InvalidDataException) {
        InvalidDataException e = error as InvalidDataException;
        ToolShowToast.showError(e.message.split('cannot be used for that because:')[1].trim(),
            duration: 4);
      }
      print('Stack trace: $stackTrace');
    });
  }

  static _configWindows() {
    ServiceWindowManager().init();
  }

  static _setUpKeyListener() async {
    await ServiceBackgroundKeyListener.initPlatformState();
    ServiceBackgroundKeyListener.addUserCallBacks(
      codeKey: isRelease ? '1' : '3', // 1 3
      needAltDown: true,
      callBack: () async {
        if (App.inWorkMod) {
          await ServiceWindowManager.position();
          ToolNavigator.pop();
          App.inWorkMod = false;
        } else {
          await ServiceWindowManager.workModPosition();
          ToolNavigator.push(screen: WorkModScreen(), root: PageRootEnum.empty);
          App.inWorkMod = true;
        }
      },
    );
    ServiceBackgroundKeyListener.addUserCallBacks(
      codeKey: isRelease ? 'Z' : 'S', //Z - S
      needAltDown: true,
      callBack: () async {
        ServiceWindowManager.onHideWindowPressed();
      },
    );
    ServiceBackgroundKeyListener.addUserCallBacks(
      codeKey: isRelease ? 'X' : 'not implement',
      needAltDown: true,
      callBack: () async {
        Get.find<AllItemControlBloc>().add(AddNewItemEvent());
      },
    );
    await ServiceBackgroundKeyListener.startListening();
  }

  static Future<void> _initSystemTray() async {
    String path = 'C:\\Users\\ZYMixx\\AndroidStudioProjects\\zymixx_todo_list\\assets\\app_icon.ico';
    final SystemTray systemTray = SystemTray();
    await systemTray.initSystemTray(
      iconPath: path,
    );
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => windowManager.show()),
      MenuItemLabel(label: 'Hide', onClicked: (menuItem) => windowManager.hide()),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => windowManager.close()),
    ]);
    await systemTray.setContextMenu(menu);
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? windowManager.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : windowManager.show();
      }
    });
  }

  static _initGet() {
    Get.put<AllItemControlBloc>(AllItemControlBloc()..add(LoadAllItemEvent()));
    Get.put<ListTodoScreenBloc>(ListTodoScreenBloc());
    Get.put<DailyTodoBloc>(DailyTodoBloc());
  }
}

