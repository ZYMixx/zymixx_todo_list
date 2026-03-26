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

  // Отпускание/отмена касания (нужно для mobile-логики удержания).
  final StreamController<void> _pointerUpController =
      StreamController<void>.broadcast();

  Stream<Offset> get cursorPositionStream =>
      _cursorPositionController.stream.asBroadcastStream();

  Stream<Offset> get pointerDownStream =>
      _pointerDownController.stream.asBroadcastStream();

  Stream<void> get pointerUpStream =>
      _pointerUpController.stream.asBroadcastStream();

  void updateCursorPosition(Offset position) {
    _cursorPositionController.add(position);
  }

  void updatePointerDown(Offset position) {
    _pointerDownController.add(position);
  }

  void notifyPointerUp() {
    _pointerUpController.add(null);
  }

  // Метод для закрытия контроллера при завершении использования
  void dispose() {
    _cursorPositionController.close();
    _pointerDownController.close();
    _pointerUpController.close();
  }
}
