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
  static bool isHided = false;

  init() {
    windowManager.setAsFrameless();
    windowManager.setAlwaysOnTop(true);
    windowManager.setBackgroundColor(Colors.transparent);
    windowManager.ensureInitialized();
     Future.delayed(Duration(milliseconds: 1500)).then((_) {
       windowManager.setAsFrameless();
      windowManager.setAlwaysOnTop(true);
     windowManager.setBackgroundColor(Colors.transparent);
      windowManager.ensureInitialized();
     });
  }

  static onHideWindowPressed(){
    if (isHided){
      windowManager.show();
      isHided = false;
    } else {
      windowManager.hide();
      isHided = true;
    }
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

  static Future<void> position() async {
    const initialSize = Size(450, 720);
    //win.size = initialSize;
    windowManager.setSize(initialSize);

    //win.position = Offset(1450, 30);
   // win.show();
   // win.restore();
    //return  await windowManager.setResizable(false);
  }
  static Future<void> workModPosition() async {
    const initialSize = Size(440, 43);
    windowManager.setSize(initialSize);
  }
}

class Test extends BitsdojoWindowPlatform {}
