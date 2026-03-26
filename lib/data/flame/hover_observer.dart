import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

class CursorPositionService {
  // Универсальная позиция указателя (поддерживает и mouse/hover, и touch move).
  final StreamController<Offset> _cursorPositionController =
      StreamController<Offset>.broadcast();

  // Тап/клик (onPointerDown) с позицией экрана.
  final StreamController<Offset> _pointerDownController =
      StreamController<Offset>.broadcast();

  Stream<Offset> get cursorPositionStream =>
      _cursorPositionController.stream.asBroadcastStream();

  Stream<Offset> get pointerDownStream =>
      _pointerDownController.stream.asBroadcastStream();

  void updateCursorPosition(Offset position) {
    _cursorPositionController.add(position);
  }

  void updatePointerDown(Offset position) {
    // Для диагностики: убедимся, что onPointerDown реально приходит.
    // Удалим/уберём после подтверждения.
    // ignore: avoid_print
    print('CursorPositionService.updatePointerDown: $position');
    _pointerDownController.add(position);
  }

  // Метод для закрытия контроллера при завершении использования
  void dispose() {
    _cursorPositionController.close();
    _pointerDownController.close();
  }
}
