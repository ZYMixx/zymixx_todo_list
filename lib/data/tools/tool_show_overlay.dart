import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';

import '../../presentation/App.dart';

class ToolShowOverlay {
  static OverlayEntry? _overlayEntry;
  static dynamic _completer;
  static bool isOpen = false;

  static Future<T?> showUserInputOverlay<T>({
    required BuildContext context,
    required Widget child,
  }) async {
    isOpen = true;
    _completer = Completer<T?>();
    _overlayEntry = OverlayEntry(
      builder: (testContext) {
        return Scaffold(
          backgroundColor: Colors.black45,
          body: child,
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
    return _completer.future;
  }

  static submitUserData(dynamic) {
    Log.i('send $dynamic');
    _completer?.complete(dynamic);
    _hideOverlay();
  }

  static cancelUserData() {
    _hideOverlay();
  }

  static void _hideOverlay() {
    isOpen = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
