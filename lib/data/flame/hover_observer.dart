import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CursorPositionService {
  // Контроллер для управления потоками данных положения курсора
  final StreamController<PointerHoverEvent> _cursorPositionController = StreamController<PointerHoverEvent>.broadcast();

  // Метод для получения потока данных положения курсора
  Stream<PointerHoverEvent> get cursorPositionStream => _cursorPositionController.stream.asBroadcastStream();

  // Метод для обновления положения курсора
  void updateCursorPosition(PointerHoverEvent event) {
    _cursorPositionController.add(event);
  }

  // Метод для закрытия контроллера при завершении использования
  void dispose() {
    _cursorPositionController.close();
  }
}
