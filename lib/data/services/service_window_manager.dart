import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:flutter/widgets.dart';
import 'package:bitsdojo_window_platform_interface/bitsdojo_window_platform_interface.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_navigator.dart';
import 'package:zymixx_todo_list/presentation/app.dart';
import 'package:screen_retriever/screen_retriever.dart';

class ServiceWindowManager extends WindowListener {
  bool _isHided = false;
  static const double _appWidth = 420.0;
  static const double _appHeight = 720.0;
  List<AppPosition> appPrePositionList = [];
  int crntPosition = 0;
  double _prePositionPaddingY = 15.0;

  _setUpPrePosition() async {
    final monitors = await screenRetriever.getAllDisplays();
    appPrePositionList.clear();

    for (var i = 0; i < monitors.length; i++) {
      final monitor = monitors[i];
      final visiblePosition = monitor.visiblePosition;
      final visibleSize = monitor.visibleSize;
      final scaleFactor = (monitor.scaleFactor ?? 1.0).toDouble();

      final topLeftPosition = Offset(
        visiblePosition!.dx.toDouble() + (15 / scaleFactor), // Учитываем масштаб
        visiblePosition.dy.toDouble() + (_prePositionPaddingY / scaleFactor),
      );

      appPrePositionList.add(AppPosition(
        position: topLeftPosition,
        scale: scaleFactor,
      ));
      // Верхний правый угол с отступом от края
      Log.e('${visiblePosition.dx.toDouble()} + ((${visibleSize!.width} - $_appWidth))');
      Log.e('${visiblePosition.dx.toDouble() + ((visibleSize!.width - _appWidth))}');
      final topRightPosition = Offset(
        visiblePosition.dx.toDouble() + ((visibleSize!.width - _appWidth)) - (50 / scaleFactor),
        // Учитываем масштаб
        visiblePosition.dy.toDouble() + (_prePositionPaddingY / scaleFactor),
      );

      appPrePositionList.add(AppPosition(
        position: topRightPosition,
        scale: scaleFactor,
      ));
    }
    appPrePositionList.sort((a, b) => a.position.dx.compareTo(b.position.dx));
  }

  Future<double> _getCurrentScale() async {
    final windowPosition = await windowManager.getPosition();
    final monitors = await screenRetriever.getAllDisplays();
    final windowCenter = windowPosition;

    // Находим монитор, на котором находится центр окна
    for (var monitor in monitors) {
      final visiblePosition = monitor.visiblePosition;
      final visibleSize = monitor.visibleSize;
      final scaleFactor = monitor.scaleFactor ?? 2.0;

      final monitorRect = Rect.fromLTWH(
        visiblePosition!.dx.toDouble(),
        visiblePosition!.dy.toDouble(),
        visibleSize!.width.toDouble(),
        visibleSize!.height.toDouble(),
      );

      // Проверяем, находится ли центр окна в пределах текущего монитора
      if (monitorRect.contains(windowCenter)) {
        return scaleFactor.toDouble();
      }
    }
    return 1.0;
  }

  changeAppPosition(bool moveRight) async {
    await _setUpPrePosition();
    if (!moveRight) {
      if (crntPosition < appPrePositionList.length - 1) {
        crntPosition++;
      }
    } else {
      if (crntPosition > 0) {
        crntPosition--;
      }
    }

    double currentScaleFactor = await _getCurrentScale();
    //позиция криво работает только при переходе от одного монитора к другому
    //проверяем этот момент и делаем нужные поправки
    if (appPrePositionList[crntPosition].scale != currentScaleFactor) {
      var scalePos = Offset(
          appPrePositionList[crntPosition].position.dx *
              (appPrePositionList[crntPosition].scale / currentScaleFactor),
          appPrePositionList[crntPosition].position.dy *
              (appPrePositionList[crntPosition].scale / currentScaleFactor));
      await windowManager.setPosition(scalePos);
    } else {
      await windowManager.setPosition(appPrePositionList[crntPosition].position);
    }
  }

  init() {
    windowManager.setAsFrameless();
    windowManager.setAlwaysOnTop(true);
    windowManager.setResizable(false);
    windowManager.setBackgroundColor(Colors.transparent);
    windowManager.ensureInitialized();
    Future.delayed(Duration(milliseconds: 1000)).then((_) {
      windowManager.setAsFrameless();
      if (App.isRelease) {
        windowManager.setTitle('TodoList');
      }
      windowManager.setAlwaysOnTop(true);
      windowManager.setBackgroundColor(Colors.transparent);
      windowManager.setResizable(false);
      windowManager.ensureInitialized();
    });
  }

  onHideWindowPressed() {
      if (_isHided) {
        windowManager.show();
        _isHided = false;
      } else {
        windowManager.hide();
        _isHided = true;
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

  Future<void> position() async {
    const initialSize = Size(_appWidth, _appHeight);
    windowManager.setSize(initialSize);
  }

  Future<void> workModPosition() async {
    const workSize = Size(_appWidth, 45);
    windowManager.setSize(workSize);
  }
}

class AppPosition {
  final Offset position; // Позиция окна
  final double scale; // Масштаб

  AppPosition({
    required this.position,
    required this.scale,
  });
}
