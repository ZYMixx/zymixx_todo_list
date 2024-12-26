import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/db_todo_item_getter.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';
import 'package:zymixx_todo_list/data/services/service_image_plugin_work.dart';
import 'package:zymixx_todo_list/data/services/service_stream_controller.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/screen_daily_todo/daily_todo_bloc.dart';

import '../bloc_global/all_item_control_bloc.dart';
import '../screen_action/choose_date_widget.dart';

enum TimeModEnum { timer, stopwatch, none }

class TodoItemBloc extends Bloc<TodoItemBlocEvent, TodoItemBlocState> {
  final _daoDatabase;
  late String timerIdentifier;
  late String stopwatchIdentifier;

  TodoItemBloc({required TodoItem todoItem, Key? key})
      : _daoDatabase = DaoDatabase(),
        timerIdentifier = "${todoItem.id.toString()}_timer",
        stopwatchIdentifier = "${todoItem.id.toString()}_stopwatch",
        super(TodoItemBlocState(todoItem: todoItem)) {
    _initialize();
  }

  void _initialize() {
    on<RequestChangeItemDateEvent>(_onChangeItemDateEvent);
    on<TimerSecondTickEvent>(_onTimerSecondTickEvent);
    on<StopStartTimerEvent>(_onStopStartTimerEvent);
    on<StopStartStopwatchEvent>(_onStopStartStopwatchEvent);
    on<StopwatchSecondTickEvent>(_onStopwatchSecondTickEvent);
    on<ChangeTimeModEvent>(_onChangeTimeModEvent);
    on<ChangeTimerEvent>(_onChangeTimerEvent);
    on<SaveItemChangeEvent>(_onSaveItemChangeEvent);
    on<DismissEvent>(_onDismissEvent);
    on<ChangeModEvent>(_onChangeModEvent);
    on<StopwatchResetTimeEvent>(_onStopwatchResetTimeEvent);
    on<SetItemDateEvent>(_onSetItemDateEvent);
    on<IncreaseItemDateEvent>(_onIncreaseItemDateEvent);
    on<SetAutoPauseSeconds>(_onSetAutoPauseSeconds);
    on<SetTodoItemImageEvent>(_onSetTodoItemImageEvent);
    on<SetTimerActiveEvent>(_onSetTimerActiveEvent);
    on<SetTimerNeedSongEvent>(_onSetTimerNeedSongEvent);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      resumeBloc();
    });
    if (state.todoItem.title == 'New Title') {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        this.add(ChangeModEvent(isChangeMod: true));
      });
    }
  }

  @override
  Future<void> close() async {
    Log.i('CALL CLOSE');
    // Get.find<ServiceStreamController>().removeStreamListener(identifier: timerIdentifier);
    // Get.find<ServiceStreamController>().removeStreamListener(identifier: stopwatchIdentifier);
    return super.close();
  }

  resumeBloc() async {
    Stream? timerStream = Get.find<ServiceStreamController>().resumeStreamListener(
      identifier: timerIdentifier,
      finishCallBack: _onTimerEnd,
      autoPauseSeconds: await state.dbTodoItemGetter.autoPauseSeconds,
    );
    Stream? stopwatchStream = Get.find<ServiceStreamController>().resumeStreamListener(
      identifier: stopwatchIdentifier,
      finishCallBack: _onTimerEnd,
      autoPauseSeconds: await state.dbTodoItemGetter.autoPauseSeconds,
    );
    if (timerStream != null) {
      this.add(ChangeTimeModEvent(timerMod: TimeModEnum.timer));
      var streamSubscription = timerStream.listen((event) {
        if (event) {
          this.add(TimerSecondTickEvent());
        }
      });
      Get.find<ServiceStreamController>()
          .addStreamListener(subscription: streamSubscription, identifier: timerIdentifier);
      this.add(SetTimerActiveEvent(isActive: true));
    }
    if (stopwatchStream != null) {
      this.add(ChangeTimeModEvent(timerMod: TimeModEnum.stopwatch));
      var streamSubscription = stopwatchStream.listen((event) {
        if (event) {
          this.add(StopwatchSecondTickEvent());
        }
      });
      Get.find<ServiceStreamController>().addStreamListener(
        subscription: streamSubscription,
        identifier: stopwatchIdentifier,
      );
      this.add(SetTimerActiveEvent(isActive: true));
    }
  }

  _onTimerEnd() {
    if (state.needTimerSong) {
      Get.find<ServiceAudioPlayer>().playTimerAlert();
    }
    this.add(SetTimerActiveEvent(isActive: false));
  }

  void _onChangeModEvent(ChangeModEvent event, Emitter<TodoItemBlocState> emit) {
    emit(state.copyWith(changeTextMod: event.isChangeMod));
  }

  void _onStopwatchResetTimeEvent(StopwatchResetTimeEvent event, Emitter<TodoItemBlocState> emit) {
    _daoDatabase.editTodoItemById(id: state.todoItemId, stopwatchSeconds: 0);
    emit(state.copyWith(todoItem: state.todoItem.copyWith(stopwatchSeconds: 0)));
  }

  void _onSetItemDateEvent(SetItemDateEvent event, Emitter<TodoItemBlocState> emit) async {
    await _daoDatabase.editTodoItemById(id: state.todoItemId, targetDateTime: event.userDateTime!);
    await Future.delayed(Duration.zero);
    emit(state.copyWith(todoItem: state.todoItem.copyWith(targetDateTime: event.userDateTime)));
  }

  void _onIncreaseItemDateEvent(
      IncreaseItemDateEvent event, Emitter<TodoItemBlocState> emit) async {
    DateTime tDate = (await state.dbTodoItemGetter.targetDateTime)!;
    DateTime increasedTargetDate = DateTime(tDate.year, tDate.month, tDate.day + 1);
    await _daoDatabase.editTodoItemById(id: state.todoItemId, targetDateTime: increasedTargetDate);
    emit(state.copyWith(todoItem: state.todoItem.copyWith(targetDateTime: increasedTargetDate)));
  }

  void _onSetAutoPauseSeconds(SetAutoPauseSeconds event, Emitter<TodoItemBlocState> emit) async {
    await _daoDatabase.editTodoItemById(
        id: state.todoItemId, autoPauseSeconds: event.autoPauseSeconds);
    await resumeBloc();
    emit(state.copyWith(
        todoItem: state.todoItem.copyWith(autoPauseSeconds: event.autoPauseSeconds)));
  }

  void _onSetTodoItemImageEvent(
      SetTodoItemImageEvent event, Emitter<TodoItemBlocState> emit) async {
    emit(state.copyWith(
        imageFile: Get.find<ServiceImagePluginWork>().checkFileExist(state.todoItem)));
  }

  void _onSetTimerActiveEvent(SetTimerActiveEvent event, Emitter<TodoItemBlocState> emit) async {
    emit(state.copyWith(isTimerActive: event.isActive));
  }

  void _onSetTimerNeedSongEvent(
      SetTimerNeedSongEvent event, Emitter<TodoItemBlocState> emit) async {
    if (Get.find<ServiceAudioPlayer>().ignoreTodoItemIdList.contains(state.todoItemId)) {
      Get.find<ServiceAudioPlayer>().ignoreTodoItemIdList.remove(state.todoItemId);
    } else {
      Get.find<ServiceAudioPlayer>().ignoreTodoItemIdList.add(state.todoItemId);
    }
    emit(state.copyWith());
    Log.i('state.needTimerSong', state.needTimerSong);
  }

  Future<void> _onChangeItemDateEvent(
      RequestChangeItemDateEvent event, Emitter<TodoItemBlocState> emit) async {
    {
      DateTime? userInput = await Get.find<ToolShowOverlay>().showUserInputOverlay<DateTime>(
        context: event.buildContext,
        child: ChooseDateWidget(),
      );
      if (userInput != null) {
        await _daoDatabase.editTodoItemById(id: state.todoItemId, targetDateTime: userInput!);
        await Future.delayed(Duration.zero);
        emit(state.copyWith(todoItem: state.todoItem.copyWith(targetDateTime: userInput)));
      } else {
        await Future.delayed(Duration.zero);
        event.restoreFocusCallBack?.call();
      }
    }
  }

  Future<void> _onTimerSecondTickEvent(
      TimerSecondTickEvent event, Emitter<TodoItemBlocState> emit) async {
    int remainSeconds = await state.dbTodoItemGetter.timerSeconds;
    emit(state.copyWith(todoItem: state.todoItem.copyWith(timerSeconds: remainSeconds)));
  }

  Future<void> _onStopStartTimerEvent(
      StopStartTimerEvent event, Emitter<TodoItemBlocState> emit) async {
    //
    var dailyList = Get.find<AllItemControlBloc>()
        .state
        .todoDailyItemList
        .where((element) =>
            element.targetDateTime != null && element.targetDateTime!.isSameDay(DateTime.now()))
        .toList();
    Log.i(
      'todoDailyItemList ${dailyList.length}',
    );
    for (var dailyItem in dailyList) {
      try {
        if (Get.find<DailyTodoBloc>().state.activeTimerIdentifier == null) {
          if (jsonDecode(dailyItem.content)['autoStart'] == true) {
            Get.find<DailyTodoBloc>().add(CompleteDailyEvent(
                isComplete: dailyItem.isDone,
                itemId: dailyItem.id,
                remainSeconds: dailyItem.timerSeconds ?? 0));
          }
        }
      } catch (e) {}
    }
    //
    if (Get.find<ServiceStreamController>().stopStream(timerIdentifier)) {
      this.add(SetTimerActiveEvent(isActive: false));
      return;
    }
    Future<bool> Function() callBack = () async {
      int remainSeconds = await state.dbTodoItemGetter.timerSeconds;
      int secondSpent = await state.dbTodoItemGetter.secondSpent;
      if (remainSeconds == 0) {
        Get.find<ServiceStreamController>().stopStream(timerIdentifier);
        return false;
      } else {
        _daoDatabase.editTodoItemById(
            id: state.todoItemId, timerSeconds: remainSeconds - 1, secondsSpent: secondSpent + 1);
        return true;
      }
    };
    Duration periodDuration = Duration(seconds: 1);
    Stream timerStream = Get.find<ServiceStreamController>().addStreamItem(
        identifier: timerIdentifier,
        callBack: callBack,
        autoPauseSeconds: await state.dbTodoItemGetter.autoPauseSeconds,
        finishCallBack: _onTimerEnd,
        periodDuration: periodDuration);
    StreamSubscription streamSubscription = timerStream.listen((event) {
      if (event) {
        this.add(TimerSecondTickEvent());
      }
    });
    Get.find<ServiceStreamController>()
        .addStreamListener(subscription: streamSubscription, identifier: timerIdentifier);
    this.add(SetTimerActiveEvent(isActive: true));
    Get.find<ServiceStreamController>()
        .stopStream(stopwatchIdentifier); //останавливаем секундомер если он был
  }

  Future<void> _onStopStartStopwatchEvent(
      StopStartStopwatchEvent event, Emitter<TodoItemBlocState> emit) async {
    var dailyList = Get.find<AllItemControlBloc>()
        .state
        .todoDailyItemList
        .where((element) =>
            element.targetDateTime != null && element.targetDateTime!.isSameDay(DateTime.now()))
        .toList();
    Log.i(
      'todoDailyItemList ${dailyList.length}',
    );
    for (var dailyItem in dailyList) {
      try {
        if (Get.find<DailyTodoBloc>().state.activeTimerIdentifier == null) {
          if (jsonDecode(dailyItem.content)['autoStart'] == true) {
            Get.find<DailyTodoBloc>().add(CompleteDailyEvent(
                isComplete: dailyItem.isDone,
                itemId: dailyItem.id,
                remainSeconds: dailyItem.timerSeconds ?? 0));
          }
        }
      } catch (e) {}
    }
    if (Get.find<ServiceStreamController>().stopStream(stopwatchIdentifier)) {
      this.add(SetTimerActiveEvent(isActive: false));
      return;
    }
    Future<bool> Function() callBack = () async {
      int crntSeconds = await state.dbTodoItemGetter.stopwatchSeconds;
      if (crntSeconds > 2400) {
        Get.find<ServiceStreamController>().stopStream(stopwatchIdentifier);
        _onTimerEnd();
        return false;
      } else {
        int secondSpent = await state.dbTodoItemGetter.secondSpent;
        _daoDatabase.editTodoItemById(
            id: state.todoItemId, stopwatchSeconds: crntSeconds + 1, secondsSpent: secondSpent + 1);
        return true;
      }
    };
    Duration periodDuration = Duration(seconds: 1);
    Stream timerStream = Get.find<ServiceStreamController>().addStreamItem(
        identifier: stopwatchIdentifier,
        callBack: callBack,
        finishCallBack: _onTimerEnd,
        autoPauseSeconds: await state.dbTodoItemGetter.autoPauseSeconds,
        periodDuration: periodDuration);
    StreamSubscription streamSubscription = timerStream.listen((event) {
      if (event) {
        this.add(StopwatchSecondTickEvent());
      }
    });
    Get.find<ServiceStreamController>()
        .addStreamListener(subscription: streamSubscription, identifier: stopwatchIdentifier);
    this.add(SetTimerActiveEvent(isActive: true));
    Get.find<ServiceStreamController>()
        .stopStream(timerIdentifier); //останавливаем таймер если он был
  }

  void _onStopwatchSecondTickEvent(
      StopwatchSecondTickEvent event, Emitter<TodoItemBlocState> emit) {
    int time = state.todoItem.stopwatchSeconds + 1;
    emit(state.copyWith(todoItem: state.todoItem.copyWith(stopwatchSeconds: time)));
  }

  void _onChangeTimeModEvent(ChangeTimeModEvent event, Emitter<TodoItemBlocState> emit) {
    emit(state.copyWith(timerMod: event.timerMod));
  }

  Future<void> _onChangeTimerEvent(ChangeTimerEvent event, Emitter<TodoItemBlocState> emit) async {
    int newTimer = state.todoItem.timerSeconds + event.changeNum;
    if (newTimer < 0) {
      newTimer = 0;
    }
    _daoDatabase.editTodoItemById(id: state.todoItemId, timerSeconds: newTimer);
    emit(state.copyWith(todoItem: state.todoItem.copyWith(timerSeconds: newTimer)));
  }

  Future<void> _onSaveItemChangeEvent(
      SaveItemChangeEvent event, Emitter<TodoItemBlocState> emit) async {
    if (state.imageFile != null) {
      if (state.todoItem.title != event.titleText) {
        //т.к. картинка привязана к title меняем её path
        try {
          final directory = state.imageFile!.parent;
          String newName = Get.find<ServiceImagePluginWork>()
              .validFileName(title: event.titleText, id: state.todoItemId);
          final newFilePath = '${directory.path}/$newName';
          Get.find<ServiceImagePluginWork>().filesList.remove(state.imageFile);
          state.imageFile = await state.imageFile!.rename(newFilePath);
          Get.find<ServiceImagePluginWork>().filesList.add(state.imageFile!);
          Log.e('Файл успешно переименован!');
        } catch (e) {
          Log.e('Ошибка при переименовании файла: $e');
        }
      }
    }
    if (!Get.find<ToolShowOverlay>().isOpen) {
      try {
        await _daoDatabase.editTodoItemById(
            id: state.todoItemId, title: event.titleText, content: event.descriptionText);
      } catch (e) {
        print(e);
      }
      emit(state.copyWith(todoItem: await state.dbTodoItemGetter.todoItem));
      this.add(ChangeModEvent(isChangeMod: event.setChangeMod));
    }
  }

  Future<void> _onDismissEvent(DismissEvent event, Emitter<TodoItemBlocState> emit) async {
    DateTime dateNow = DateTime.now();
    Get.find<ServiceStreamController>().removeStreamListener(identifier: timerIdentifier);
    Get.find<ServiceStreamController>().removeStreamListener(identifier: stopwatchIdentifier);
    if (dateNow.hour < 3) {
      dateNow = dateNow.copyWith(day: dateNow.day - 1);
    }
    if (event.direction == DismissDirection.startToEnd) {
      //right
      if (state.todoItem.category == EnumTodoCategory.social.name) {
        await _daoDatabase.editTodoItemById(
          id: state.todoItemId,
          category: EnumTodoCategory.history_social.name,
          isDone: true,
          targetDateTime: dateNow,
        );
      } else {
        if (state.todoItem.title == 'New Title') {
          await _daoDatabase.deleteTodoItem(state.todoItem);
          Get.find<ToolShowToast>().show('Пустой item удалён');
        } else {
          await _daoDatabase.editTodoItemById(
            id: state.todoItemId,
            category: EnumTodoCategory.history.name,
            isDone: true,
            targetDateTime: dateNow,
          );
        }
      }
    }
    if (event.direction == DismissDirection.endToStart) {
      //left
      TodoItem savedTodoItem = TodoItem.duplicate(todoItem: state.todoItem);
      await _daoDatabase.deleteTodoItem(state.todoItem);
      VoidCallback returnItemCallBack = () async {
        await _daoDatabase.insertTodoItem(savedTodoItem);
        Future.delayed(Duration.zero, () {
          Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
        });
      };
      Get.find<ToolShowToast>()
          .showWithCallBack(message: 'Задача удаленна.', callback: returnItemCallBack);
    }
    Future.delayed(Duration.zero, () {
      Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
    });
    if (state.imageFile != null) {
      Get.find<ServiceImagePluginWork>()
          .deleteImage(todoItem: state.todoItem, updateCallBack: () => ());
    }
    Log.i('diss miss end');
  }
}

//grp STATE

class TodoItemBlocState {
  int todoItemId;
  DbTodoItemGetter dbTodoItemGetter;
  TodoItem todoItem;
  TimeModEnum timerMod;
  bool changeTextMod;
  bool isTimerActive;
  bool needTimerSong;
  File? imageFile;

  TodoItemBlocState({
    this.timerMod = TimeModEnum.none,
    required this.todoItem,
    this.changeTextMod = false,
    this.isTimerActive = false,
    this.imageFile,
  })  : todoItemId = todoItem.id,
        needTimerSong =
            (!Get.find<ServiceAudioPlayer>().ignoreTodoItemIdList.contains(todoItem.id)),
        dbTodoItemGetter = DbTodoItemGetter(itemId: todoItem.id) {
    imageFile = Get.find<ServiceImagePluginWork>().checkFileExist(todoItem);
  }

  TodoItemBlocState copyWith({
    TodoItem? todoItem,
    TimeModEnum? timerMod,
    bool? changeTextMod,
    bool? isTimerActive,
    bool? needTimerSong,
    File? imageFile,
  }) {
    return TodoItemBlocState(
      todoItem: todoItem ?? this.todoItem,
      timerMod: timerMod ?? this.timerMod,
      changeTextMod: changeTextMod ?? this.changeTextMod,
      isTimerActive: isTimerActive ?? this.isTimerActive,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}

//grp EVENT

class TodoItemBlocEvent {}

class TimerSecondTickEvent extends TodoItemBlocEvent {}

class StopwatchSecondTickEvent extends TodoItemBlocEvent {}

class StopwatchResetTimeEvent extends TodoItemBlocEvent {}

class StopStartTimerEvent extends TodoItemBlocEvent {}

class StopStartStopwatchEvent extends TodoItemBlocEvent {}

class ChangeTimerEvent extends TodoItemBlocEvent {
  int changeNum;

  ChangeTimerEvent({
    required this.changeNum,
  });
}

class ChangeTimeModEvent extends TodoItemBlocEvent {
  TimeModEnum timerMod;

  ChangeTimeModEvent({required this.timerMod});
}

class DismissEvent extends TodoItemBlocEvent {
  DismissDirection direction;

  DismissEvent({required this.direction});
}

class SaveItemChangeEvent extends TodoItemBlocEvent {
  String titleText;
  String descriptionText;
  bool setChangeMod;

  SaveItemChangeEvent(
      {required this.titleText, required this.descriptionText, this.setChangeMod = false});
}

class ChangeModEvent extends TodoItemBlocEvent {
  bool isChangeMod;

  ChangeModEvent({required this.isChangeMod});
}

class RequestChangeItemDateEvent extends TodoItemBlocEvent {
  BuildContext buildContext;
  DateTime? userDateTime;
  Function? restoreFocusCallBack;

  RequestChangeItemDateEvent(
      {required this.buildContext, this.userDateTime, this.restoreFocusCallBack});
}

class SetItemDateEvent extends TodoItemBlocEvent {
  DateTime userDateTime;

  SetItemDateEvent({required this.userDateTime});
}

class IncreaseItemDateEvent extends TodoItemBlocEvent {
  IncreaseItemDateEvent();
}

class SetAutoPauseSeconds extends TodoItemBlocEvent {
  int autoPauseSeconds;

  SetAutoPauseSeconds({required this.autoPauseSeconds});
}

class SetTodoItemImageEvent extends TodoItemBlocEvent {
  SetTodoItemImageEvent();
}

class SetTimerActiveEvent extends TodoItemBlocEvent {
  bool isActive;

  SetTimerActiveEvent({required this.isActive});
}

class SetTimerNeedSongEvent extends TodoItemBlocEvent {
  SetTimerNeedSongEvent();
}
