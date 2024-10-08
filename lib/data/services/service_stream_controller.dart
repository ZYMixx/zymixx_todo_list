import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/services/service_background_key_listener.dart';

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
      {required String identifier, Function()? finishCallBack, int? autoPauseSeconds}) {
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
    StreamItem? foundItem;
    for (var item in streamItemsList) {
      if (item.identifier == identifier) {
        foundItem = item;
      } else {}
    }
    if (foundItem != null) {
      foundItem.stop();
      streamItemsList.remove(foundItem);
      return true;
    }
    return false;
  }

  addListener({required StreamSubscription subscription, required String identifier}) async {
    if (subList[identifier] != null) {
      await subList[identifier]?.cancel();
    }
    subList[identifier] = subscription;
  }

  removeListener({required String identifier}) async {
    if (subList[identifier] != null) {
      await subList[identifier]?.cancel();
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
    while (isRun) {
      yield await Future.delayed(periodDuration).then((_) async {
        if (isRun &&
            (autoPauseSeconds == 0 ||
                Get.find<ServiceBackgroundKeyListener>().noActionSecondTimer < autoPauseSeconds)) {
          if (!(await callBack.call())) {
            finishCallBack.call();
          }
          return true;
        } else {
          return false;
        }
      });
    }
  }
}
