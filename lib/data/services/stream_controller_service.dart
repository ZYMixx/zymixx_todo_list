import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';

class StreamControllerService {
  static List<StreamItem> streamItemsList = [];
  static Map<String ,StreamSubscription> subList = {};

  static Stream<bool> addStreamItem<T extends Bloc>({
    required String identifier,
    required Future<bool> Function() callBack,
    required Function() finishCallBack,
    required Duration periodDuration,
    //required T blocListener,
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
        periodDuration: periodDuration);
    streamItemsList.add(newItem);
    return newItem._stream;
  }

  static Stream<bool>? resumeStreamListener({required String identifier}){
    for (var item in streamItemsList) {
      if (item.identifier == identifier) {
        return item._stream;
      }
    }
    return null;
  }

  static bool stopStream(String identifier){
    StreamItem? foundItem;
    for (var item in streamItemsList) {
      if (item.identifier == identifier) {
        foundItem = item;
      } else {
      }
    }
    if (foundItem != null){
      foundItem.stop();
      streamItemsList.remove(foundItem);
      return true;
    }
    return false;
  }

  static addListener({required StreamSubscription subscription, required String identifier}) async {
    if(subList[identifier] != null){
      await subList[identifier]?.cancel();
    }
    subList[identifier] = subscription;
  }

  static removeListener({required String identifier}) async {
    if(subList[identifier] != null){
      await subList[identifier]?.cancel();
    }
  }
}

class StreamItem<T extends Bloc> {
  String identifier;
  late Stream<bool> _stream;
  Duration periodDuration;
  bool isRun = true;
  Future<bool> Function() callBack;
  Function finishCallBack;
 // T? blocListener;
 // dynamic blocUpdateEvent;

  StreamItem({
    required this.identifier,
    required this.callBack,
    required this.finishCallBack,
    required this.periodDuration,
   // required this.blocListener,
   // required this.blocUpdateEvent,
  }) {
    _stream = callLoop().asBroadcastStream();
  }

  stop() {
    isRun = false;
  }

 // changeListener(T? blocListener){
 //   this.blocListener = blocListener;
 // }

  Stream<bool> callLoop() async* {
    while (isRun) {
      yield await Future.delayed(periodDuration).then((_) async {
        if (isRun) {
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
