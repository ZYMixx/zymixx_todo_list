import 'dart:async';

import 'package:flutter/material.dart';
import 'package:keyboard_event/keyboard_event.dart';

abstract class ServiceBackgroundKeyListener {
  static List<CodeCallBack> userCallBacks = [];
  static late KeyboardEvent keyboardEvent;
  static bool listenIsOn = false;

  static Future<void> initPlatformState() async {
    keyboardEvent = KeyboardEvent();
    try {
      await KeyboardEvent.init();
    } catch (e) {
      print(e);
    }
  }

  static addUserCallBacks(
      {required String codeKey, bool? needAltDown, required VoidCallback callBack}) {
    userCallBacks.add(CodeCallBack(
        codeKey: codeKey.toUpperCase(), callBack: callBack, needAltDown: needAltDown ?? false));
  }

  static startListening() {
    keyboardEvent.startListening((keyEvent) {
      checkUserCode(keyEvent);
    });
  }

  static stopListening() {
    keyboardEvent.cancelListening();
  }

  static clearUserCallBacks() {
    userCallBacks = [];
  }

  static checkUserCode(dynamic keyEvent) {
    //print('cheak ${keyEvent}');
    //print('keyEvent.vkName ${keyEvent.vkName}');
    for (var item in userCallBacks) {
      if (keyEvent.isReleased && keyEvent.vkName == item.codeKey) {
        if (item.needAltDown && !keyEvent.isAltDown) {
          continue;
        }
        item.callBack.call();
      }
    }
  }
}

//LCONTROL LMENU  LSHIFT
//qqqqq1qqqqssqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq 1qqqqqqqqqqqqqqqqqqqq
class CodeCallBack {
  final String codeKey;
  final bool needAltDown;
  final VoidCallback callBack;

  const CodeCallBack({
    required this.codeKey,
    required this.callBack,
    this.needAltDown = false,
  });
}
