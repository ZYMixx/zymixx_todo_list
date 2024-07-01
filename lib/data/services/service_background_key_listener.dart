import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keyboard_event/keyboard_event.dart' as kEvent;
import 'package:zymixx_todo_list/data/services/service_window_manager.dart';
import 'package:zymixx_todo_list/data/tools/tool_navigator.dart';
import 'package:zymixx_todo_list/presentation/app.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/work_mod_screen.dart';
import 'package:get/get.dart';

class ServiceBackgroundKeyListener {
  List<CodeCallBack> userCallBacks = [];
  late kEvent.KeyboardEvent keyboardEvent;
  bool listenIsOn = false;
  int noActionSecondTimer = 0;
  Timer? _timerKeyLoop;
  bool _isShiftPressed = false;

  Future<void> initPlatformState() async {
    keyboardEvent = kEvent.KeyboardEvent();
    try {
      await kEvent.KeyboardEvent.init();
    } catch (e) {
      print(e);
    }
    _setUpKeyListener();
  }

  addUserCallBacks({
    required String codeKey,
    bool? needAltDown,
    bool? needShiftDown,
    required VoidCallback callBack,
  }) {
    userCallBacks.add(CodeCallBack(
      codeKey: codeKey.toUpperCase(),
      callBack: callBack,
      needAltDown: needAltDown,
      needShiftDown: needShiftDown,
    ));
  }

  startListening() {
    keyboardEvent.startListening((kEvent.KeyEvent keyEvent) {
      noActionSecondTimer = 0;
      if (keyEvent.vkName == 'LSHIFT') {
        _isShiftPressed = keyEvent.isKeyDown;
      }
      checkUserCode(keyEvent);
    });
    _timerKeyLoop = Timer.periodic(Duration(seconds: 1), (timer) {
      noActionSecondTimer += 1;
    });
  }

  stopListening() async => keyboardEvent.cancelListening();

  clearUserCallBacks() {
    userCallBacks = [];
  }

  checkUserCode(kEvent.KeyEvent keyEvent) {
    for (var item in userCallBacks) {
      if (keyEvent.isReleased && keyEvent.vkName == item.codeKey) {
        bool isAltCorrect = item.needAltDown == keyEvent.isAltDown;
        bool isShiftCorrect = item.needShiftDown == _isShiftPressed;
        bool requiredBoth = item.needAltDown && item.needShiftDown;

        if (!isAltCorrect || !isShiftCorrect) {
          continue;
        }
        if (requiredBoth) {
          if (!isAltCorrect && !isShiftCorrect) {
            continue;
          }
        }
        item.callBack.call();
      }
    }
  }

  _setUpKeyListener() async {
    Get.find<ServiceBackgroundKeyListener>().addUserCallBacks(
      codeKey: App.isRelease ? '1' : '4', // 1 3
      needAltDown: true,
      callBack: () async {
        await App.changeAppWorkMod();
      },
    );
    // переход в work-mod
    Get.find<ServiceBackgroundKeyListener>().addUserCallBacks(
      codeKey: App.isRelease ? 'Z' : 'X', //Z - X
      needAltDown: true,
      callBack: () async {
        Get.find<ServiceWindowManager>().onHideWindowPressed();
      },
    );
    // создаём новый туду-итем
    Get.find<ServiceBackgroundKeyListener>().addUserCallBacks(
      codeKey: App.isRelease ? 'S' : 'not implement',
      needAltDown: true,
      callBack: () async {
        Get.find<AllItemControlBloc>().add(AddNewItemEvent());
      },
    );
    //двигаем в лево
    Get.find<ServiceBackgroundKeyListener>().addUserCallBacks(
      codeKey: '3',
      needAltDown: true,
      needShiftDown: true,
      callBack: () async {
        Get.find<ServiceWindowManager>().changeAppPosition(true);
      },
    );
    //двигаем в право
    Get.find<ServiceBackgroundKeyListener>().addUserCallBacks(
      codeKey: '3',
      needAltDown: true,
      callBack: () async {
        Get.find<ServiceWindowManager>().changeAppPosition(false);
      },
    );
    await Get.find<ServiceBackgroundKeyListener>().startListening();
  }


}

class CodeCallBack {
  final String codeKey;
  final bool needAltDown;
  final bool needShiftDown;
  final VoidCallback callBack;

  const CodeCallBack({
    required this.codeKey,
    required this.callBack,
    bool? needAltDown,
    bool? needShiftDown,
  })  : needAltDown = needAltDown ?? false,
        needShiftDown = needShiftDown ?? false;
}
