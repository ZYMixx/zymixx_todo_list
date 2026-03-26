import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

class CursorPositionService {
  // Универсальная позиция указателя (поддерживает и mouse/hover, и touch move).
  final StreamController<Offset> _cursorPositionController =
      StreamController<Offset>.broadcast();

  Stream<Offset> get cursorPositionStream =>
      _cursorPositionController.stream.asBroadcastStream();

  void updateCursorPosition(Offset position) {
    _cursorPositionController.add(position);
  }

  // Метод для закрытия контроллера при завершении использования
  void dispose() {
    _cursorPositionController.close();
  }
}
