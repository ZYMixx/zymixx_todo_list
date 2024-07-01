import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';

import '../../presentation/app.dart';

class ToolShowOverlay {
  OverlayEntry? _overlayEntry;
  dynamic _completer;
  bool isOpen = false;

  Future<T?> showUserInputOverlay<T>({
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

  submitUserData(dynamic) {
    Log.i('submitUserData $dynamic');
    _completer?.complete(dynamic);
    _hideOverlay();
  }

  void _hideOverlay() {
    isOpen = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
