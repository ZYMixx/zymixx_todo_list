import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:zymixx_todo_list/data/services/service_background_key_listener.dart';
import 'package:zymixx_todo_list/data/services/service_statistic_data.dart';
import 'package:zymixx_todo_list/data/tools/tool_date_formatter.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/presentation/bloc/daily_todo_bloc.dart';
import 'package:zymixx_todo_list/presentation/bloc/list_todo_screen_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_bottom_navigator_screen.dart';
import '../data/services/service_get_time.dart';
import '../data/services/service_window_manager.dart';
import 'bloc/all_item_control_bloc.dart';

class App {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void start() async {
    navigatorKey = GlobalKey<NavigatorState>();
    runZonedGuarded(() async {
      initializeDateFormatting('ru');
      WidgetsFlutterBinding.ensureInitialized();
      await _initGet();
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
      if ( error is InvalidDataException) {
        InvalidDataException e = error as InvalidDataException;
        ToolShowToast.showError(
            e.message.split('cannot be used for that because:')[1].trim(), duration: 4);
      }
      print('Stack trace: $stackTrace');
    });
    //_configWindows();
    //_setUpKeyListener();
    // ServiceStatisticData.requestWeekStat();

  }

  static _configWindows() {
    ServiceWindowManager().init();
  }

//  static _setUpKeyListener() async {
//    await ServiceBackgroundKeyListener.initPlatformState();
//    ServiceBackgroundKeyListener.addUserCallBacks(
//      codeKey: '1',
//      needAltDown: true,
//      callBack: () {
//        ServiceWindowManager().testHideBG();
//      },
//    );
//    ServiceBackgroundKeyListener.startListening();
//  }

  static _initGet() {
    Get.put<ServiceGetTime>(ServiceGetTime());
    Get.put<AllItemControlBloc>(AllItemControlBloc()..add(LoadAllItemEvent()));
    Get.put<ListTodoScreenBloc>(ListTodoScreenBloc());
    Get.put<DailyTodoBloc>(DailyTodoBloc());
  }

}


