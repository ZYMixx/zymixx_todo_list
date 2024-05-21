library bitsdojo_window_windows;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:flutter/widgets.dart';
import 'package:bitsdojo_window_platform_interface/bitsdojo_window_platform_interface.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';

class ServiceWindowManager extends WindowListener {
  static final win = appWindow;
  static bool isIgnoreMouseEvent = false;
  static bool isHide = false;

  Future<void> testHideBG() async {
    Log.i('triger');
    if (isHide) {
      await windowManager.setIgnoreMouseEvents(false);
      isHide = false;
    } else {
      await windowManager.setIgnoreMouseEvents(true);
      await windowManager.setBackgroundColor(Colors.transparent);
      isHide = true;
    }
    await windowManager.ensureInitialized();
  }

  init() {
    //setWindowOnTop();
    //setListener();
    position();
    windowManager.ensureInitialized();
    //windowManager.setBackgroundColor(Colors.transparent);
    //windowManager.ensureInitialized();
    // Future.delayed(Duration(milliseconds: 500)).then((_) {
    // windowManager.setAsFrameless();
    //  windowManager.setAlwaysOnTop(true);
    //  windowManager.ensureInitialized();
    // });
  }

  setListener() {
    windowManager.addListener(this);
  }

  @override
  void onWindowEvent(String eventName) {}

  @override
  void onWindowBlur() {}

  setWindowOnTop() {
    windowManager.setAlwaysOnTop(true);
  }

  position() {
    const initialSize = Size(420, 600);
    win.size = initialSize;
    win.position = Offset(1450, 30);
    win.show();
    windowManager.setResizable(false);
  }
}

class Test extends BitsdojoWindowPlatform {}
