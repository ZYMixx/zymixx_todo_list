library bitsdojo_window_windows;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:flutter/widgets.dart';
import 'package:bitsdojo_window_platform_interface/bitsdojo_window_platform_interface.dart';

class ServiceWindowManager extends WindowListener {
  static final win = appWindow;
  static bool isIgnoreMouseEvent = false;

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
  void onWindowEvent(String eventName) {}

  @override
  void onWindowBlur() {}

  static changeFocus() {
    isIgnoreMouseEvent = !isIgnoreMouseEvent;
    windowManager.setIgnoreMouseEvents(isIgnoreMouseEvent);
    windowManager.ensureInitialized();
    print('im change');
  }

  forceHide() {
    windowManager.setIgnoreMouseEvents(true);
    windowManager.ensureInitialized();
  }

  forceShow() {
    windowManager.setIgnoreMouseEvents(true);
    windowManager.ensureInitialized();
  }

  @override
  void onWindowFocus() {
    // print('focus');
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
