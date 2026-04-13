import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/services/service_background_key_listener.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';

class ServiceStreamController {
  List<StreamItem> streamItemsList = [];
  Map<String, StreamSubscription> subList = {};

  Stream<bool> addStreamItem<T extends Bloc>({
    required String identifier,
    required Future<bool> Function() callBack,
    required Function() finishCallBack,
    required Duration periodDuration,
    required int autoPauseSeconds,
  }) {
    for (var item in streamItemsList) {
      if (item.identifier == identifier) {
        return item._stream;
      }
    }
    StreamItem newItem = StreamItem(
        identifier: identifier,
        callBack: callBack,
        finishCallBack: finishCallBack,
        autoPauseSeconds: autoPauseSeconds,
        periodDuration: periodDuration);
    streamItemsList.add(newItem);
    return newItem._stream;
  }

  bool isOtherTodoItemRun(String identifier) {
    for (var stream in streamItemsList) {
      if (stream.identifier.contains(identifier)) {
        continue;
      }
      if (stream.isRun) {
        return true;
      }
    }
    return false;
  }

  Stream<bool>? resumeStreamListener(
      {required String identifier,
      Function()? finishCallBack,
      int? autoPauseSeconds}) {
    for (var item in streamItemsList) {
      if (item.identifier == identifier) {
        if (finishCallBack != null) {
          item.finishCallBack = finishCallBack;
        }
        if (autoPauseSeconds != null) {
          item.autoPauseSeconds = autoPauseSeconds;
        }
        return item._stream;
      }
    }
    return null;
  }

  bool stopStream(String identifier) {
    Log.w('stop stt te $streamItemsList');
    StreamItem? foundItem;
    for (var item in streamItemsList) {
      if (item.identifier == identifier) {
        foundItem = item;
        foundItem.stop();
        streamItemsList.remove(foundItem);

        return true;
      }
    }
    return false;
  }

  addStreamListener(
      {required StreamSubscription subscription,
      required String identifier}) async {
    if (subList[identifier] != null) {
      await subList[identifier]?.cancel();
    }
    subList[identifier] = subscription;
  }

  removeStreamListener({required String identifier}) async {
    stopStream(identifier);
    if (subList[identifier] != null) {
      await subList[identifier]?.cancel();
      await subList.remove(identifier);
    }
  }
}

class StreamItem<T extends Bloc> {
  String identifier;
  late Stream<bool> _stream;
  Duration periodDuration;
  bool isRun = true;
  int autoPauseSeconds;
  Future<bool> Function() callBack;
  Function finishCallBack;

  StreamItem({
    required this.identifier,
    required this.callBack,
    required this.finishCallBack,
    required this.periodDuration,
    required this.autoPauseSeconds,
  }) {
    _stream = callLoop().asBroadcastStream();
  }

  stop() {
    isRun = false;
  }

  Stream<bool> callLoop() async* {
    final DateTime startedAt = DateTime.now();
    int processedSeconds = 0;
    while (isRun) {
      await Future.delayed(periodDuration);
      if (!isRun) {
        break;
      }

      final int elapsedSeconds = DateTime.now().difference(startedAt).inSeconds;
      final int pendingTicks = max(0, elapsedSeconds - processedSeconds);

      if (pendingTicks == 0) {
        continue;
      }

      if (_isPausedByNoAction()) {
        yield false;
        continue;
      }

      bool emittedTick = false;
      for (int i = 0; i < pendingTicks; i++) {
        if (!isRun) {
          break;
        }
        processedSeconds += 1;
        emittedTick = true;
        if (!(await callBack.call())) {
          finishCallBack.call();
          yield true;
          return;
        }
      }

      if (emittedTick) {
        yield true;
      }
    }
  }

  bool _isPausedByNoAction() {
    // На мобильных клавиатурный idle-трекер неприменим: не ставим таймер на паузу.
    if (!GetPlatform.isDesktop) {
      return false;
    }
    if (autoPauseSeconds == 0) {
      return false;
    }
    return Get.find<ServiceBackgroundKeyListener>().noActionSecondTimer >=
        autoPauseSeconds;
  }
}
