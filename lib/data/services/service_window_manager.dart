library bitsdojo_window_windows;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:flutter/widgets.dart';
import 'package:bitsdojo_window_platform_interface/bitsdojo_window_platform_interface.dart';

class ServiceWindowManager extends WindowListener {
  final win = appWindow;

  init() {
    setWindowsSize();
    setWindowOnTop();
    setListener();
    test();

    windowManager.ensureInitialized();
  }

  setListener() {
    windowManager.addListener(this);
  }

  @override
  void onWindowEvent(String eventName) {
    print(eventName);
  }

  @override
  void onWindowBlur() {
    print('blur');
    windowManager.setIgnoreMouseEvents(true);
    windowManager.ensureInitialized();
  }

  @override
  void onWindowFocus() {
    print('focus');
    windowManager.setIgnoreMouseEvents(false);
    windowManager.ensureInitialized();
  }

  setWindowsSize() {
    windowManager.setResizable(false);
    // windowManager.setAsFrameless();
  }

  setWindowOnTop() {
    windowManager.setAlwaysOnTop(true);
  }

  test() {
    const initialSize = Size(200, 180);
    win.size = initialSize;
    win.show();
  }
}

class Test extends BitsdojoWindowPlatform {}
