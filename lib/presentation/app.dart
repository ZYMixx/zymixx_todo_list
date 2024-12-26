import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zymixx_todo_list/data/db/app_database.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/db/mapper_database.dart';
import 'package:zymixx_todo_list/data/flame/hover_observer.dart';
import 'package:zymixx_todo_list/data/flame/wall_bg_flame_widget.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';
import 'package:zymixx_todo_list/data/services/service_background_key_listener.dart';
import 'package:zymixx_todo_list/data/services/service_image_plugin_work.dart';
import 'package:zymixx_todo_list/data/services/service_shared_preferences.dart';
import 'package:zymixx_todo_list/data/services/service_statistic_data.dart';
import 'package:zymixx_todo_list/data/services/service_stream_controller.dart';
import 'package:zymixx_todo_list/data/services/service_system_tray.dart';
import 'package:zymixx_todo_list/data/tools/tool_date_formatter.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_merge_json.dart';
import 'package:zymixx_todo_list/data/tools/tool_navigator.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/data/tools/tool_time_string_converter.dart';
import '../data/services/service_window_manager.dart';
import 'bloc_global/all_item_control_bloc.dart';
import 'bloc_global/list_todo_screen_bloc.dart';
import 'screen_app_bottom_navigator/my_bottom_navigator_screen.dart';
import 'screen_black_box/black_box_bloc.dart';
import 'screen_daily_todo/daily_todo_bloc.dart';
import 'screen_work_mod/work_mod_screen.dart';

class App {
  static late final GlobalKey<NavigatorState> navigatorKey;
  static bool inWorkMod = false;
  static late final String directoryPath;
  static const bool isRelease = bool.fromEnvironment('dart.vm.product');
  static const platform = MethodChannel('ru.zymixx/zymixxWindowsChannel');

  static void start() async {
    navigatorKey = GlobalKey<NavigatorState>();
    directoryPath = await (await getApplicationSupportDirectory()).path;
    runZonedGuarded(() async {
      initializeDateFormatting('ru');
      WidgetsFlutterBinding.ensureInitialized();
      await _initGet();
      await _preventDoubleOpenApp();
      await _configWindows();
      await Get.find<ServiceBackgroundKeyListener>().initPlatformState();
      await Get.find<ServiceSystemTray>().initSystemTray();
      runApp(
        MaterialApp(
            navigatorObservers: [Get.find<AppNavigatorObserver>()],
            initialRoute: 'MainScreen',
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
            home: MyBottomNavigatorScreen()
        ),
      );
    }, (error, stackTrace) {
      Log.e("ZYYYYMIIIIXX");
      print('Error occurred: $error');
      if (error is InvalidDataException) {
        InvalidDataException e = error;
        Get.find<ToolShowToast>().showError(
          e.message.split('cannot be used for that because:')[1].trim(),
          duration: 4,
        );
      }
      print('Stack trace: $stackTrace');
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.dumpErrorToConsole(details);

        // Печать контекста и трассировки
        print('Caught error in widget tree: ${details.exceptionAsString()}');
        print('Widget context: ${details.context}');
        print('Element tree path:\n${WidgetInspectorService.instance?.toString()}');
      };
    });
    Timer.periodic(Duration(seconds: 1), (timer) async {});
  }


  static _initGet() async {
    // db
    Get.put<AppDatabase>(await createDatabase());
    Get.put<MapperDatabase>(MapperDatabase());
    Get.put<GlobalDbDao>(GlobalDbDao());
    //init services
    Get.put<ServiceAudioPlayer>(ServiceAudioPlayer());
    Get.put<ServiceBackgroundKeyListener>(ServiceBackgroundKeyListener());
    Get.put<ServiceImagePluginWork>(ServiceImagePluginWork());
    Get.put<ServiceSharedPreferences>(ServiceSharedPreferences());
    Get.put<ServiceStatisticData>(ServiceStatisticData());
    Get.put<ServiceStreamController>(ServiceStreamController());
    Get.put<ServiceSystemTray>(ServiceSystemTray());
    Get.put<ServiceWindowManager>(ServiceWindowManager());
    Get.put<CursorPositionService>(CursorPositionService());
    //init tools
    Get.put<ToolDateFormatter>(ToolDateFormatter());
    Get.put<ToolMergeJson>(ToolMergeJson());
    Get.put<ToolShowOverlay>(ToolShowOverlay());
    Get.put<ToolShowToast>(ToolShowToast());
    Get.put<ToolTimeStringConverter>(ToolTimeStringConverter());
    //init Singleton bloc
    Get.put<AllItemControlBloc>(AllItemControlBloc()..add(LoadAllItemEvent()));
    Get.put<ListTodoScreenBloc>(ListTodoScreenBloc());
    Get.put<AppNavigatorObserver>(AppNavigatorObserver());
    Get.put<DailyTodoBloc>(DailyTodoBloc());
    Get.put<BlackBoxBloc>(BlackBoxBloc()..add(LoadNotesEvent()));
    //Flame BG
    Get.put<WallBgFlameWidget>(WallBgFlameWidget());
    //Widgets
    Get.put<MyBottomNavigatorWidget>(MyBottomNavigatorWidget());


  }


  static _configWindows() {
    ServiceWindowManager().init();
  }

  static _preventDoubleOpenApp() async {
    if (isRelease) {
      bool isAlreadyExist = await platform.invokeMethod('preventDoubleOpenApp');
      if (isAlreadyExist) {
        exit(0);
      }
    }
  }

  static changeAppWorkMod() async {
     if (App.inWorkMod) {
       await Get.find<ServiceWindowManager>().position();
       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
         ToolNavigator.pop();
         Future.delayed(Duration(milliseconds: 70)).then((_) {
           // ждём пока закроются [[TodoItemBloc]]
           Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
           App.inWorkMod = false;
           Get.find<WallBgFlameWidget>().gameBounce.resumeEngine();

         });
       });
     } else {
       if (Get.find<AppNavigatorObserver>().currentRouteName == '/') {
         await Get.find<ServiceWindowManager>().workModPosition();
         ToolNavigator.set(screen: WorkModScreen(), root: PageRootEnum.empty);
         App.inWorkMod = true;
         Get.find<WallBgFlameWidget>().gameBounce.pauseEngine();
       }
     }
  }

}
