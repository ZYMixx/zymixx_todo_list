import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/db_todo_item_getter.dart';
import 'package:zymixx_todo_list/data/services/service_image_plugin_work.dart';
import 'package:zymixx_todo_list/data/services/stream_controller_service.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';
import 'package:zymixx_todo_list/presentation/action_screens/choose_date_widget.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      resumeBloc();
    });
    if (state.todoItem.title == 'New Title') {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        this.add(ChangeModEvent(isChangeMod: true));
      });
    }
    on<RequestChangeItemDateEvent>(_onChangeItemDateEvent);
    on<TimerSecondTickEvent>(_onTimerSecondTickEvent);
    on<StopStartTimerEvent>(_onStopStartTimerEvent);
    on<StopStartStopwatchEvent>(_onStopStartStopwatchEvent);
    on<StopwatchSecondTickEvent>(_onStopwatchSecondTickEvent);
    on<ChangeTimeModEvent>(_onChangeTimeModEvent);
    on<ChangeTimerEvent>(_onChangeTimerEvent);
    on<LoseFocusEvent>(_onLoseFocusEvent);
    on<DismissEvent>(_onDismissEvent);
    on<ChangeModEvent>(_onChangeModEvent);
    on<StopwatchResetTimeEvent>(_onStopwatchResetTimeEvent);
    on<SetItemDateEvent>(_onSetItemDateEvent);
    on<IncreaseItemDateEvent>(_onIncreaseItemDateEvent);
    on<SetAutoPauseSeconds>(_onSetAutoPauseSeconds);
    on<SetTodoItemImageEvent>(_onSetTodoItemImageEvent);
    on<SetTimerActiveEvent>(_onSetTimerActiveEvent);
  }
  @override
  Future<void> close() async {
    StreamControllerService.removeListener(identifier: timerIdentifier);
    StreamControllerService.removeListener(identifier: stopwatchIdentifier);
    return super.close();
  }

  resumeBloc() async {
    Stream? timerStream = StreamControllerService.resumeStreamListener(identifier: timerIdentifier);
    Stream? stopwatchStream =
        StreamControllerService.resumeStreamListener(identifier: stopwatchIdentifier);
    if (timerStream != null) {
      this.add(ChangeTimeModEvent(timerMod: TimeModEnum.timer));
      var streamSubscription = timerStream.listen((event) {
        if (event) {
          this.add(TimerSecondTickEvent());
        }
      });
      StreamControllerService.addListener(
          subscription: streamSubscription, identifier: timerIdentifier);
      Log.i('resuscribe Timer');
      this.add(SetTimerActiveEvent(isActive: true));
    }
    if (stopwatchStream != null) {
      this.add(ChangeTimeModEvent(timerMod: TimeModEnum.stopwatch));
      var streamSubscription = stopwatchStream.listen((event) {
        if (event) {
          this.add(StopwatchSecondTickEvent());
        }
      });
      StreamControllerService.addListener(
          subscription: streamSubscription, identifier: stopwatchIdentifier);
      Log.i('resuscribe stopwatch');
      this.add(SetTimerActiveEvent(isActive: true));

    }
  }

  _onTimerEnd() {
    this.add(SetTimerActiveEvent(isActive: false));
    ServiceAudioPlayer.playTimerAlert();
  }

  void _onChangeModEvent(ChangeModEvent event, Emitter<TodoItemBlocState> emit) {
    emit(state.copyWith(changeTextMod: event.isChangeMod));
  }

  void _onStopwatchResetTimeEvent(StopwatchResetTimeEvent event, Emitter<TodoItemBlocState> emit) {
    _daoDatabase.editTodoItemById(id: state.todoItemId, stopwatchSeconds: 0);
    emit(state.copyWith(todoItem: state.todoItem.copyWith(stopwatchSeconds: 0)));
  }

  void _onSetItemDateEvent(SetItemDateEvent event, Emitter<TodoItemBlocState> emit) async {
    await _daoDatabase.editTodoItemById(
        id: state.todoItemId, targetDateTime: event.userDateTime!);
    emit(state.copyWith(todoItem: state.todoItem.copyWith(targetDateTime: event.userDateTime)));
  }

  void _onIncreaseItemDateEvent(IncreaseItemDateEvent event, Emitter<TodoItemBlocState> emit) async {
    DateTime tDate = (await state.dbTodoItemGetter.targetDateTime)!;
    DateTime increasedTargetDate = DateTime(tDate.year, tDate.month, tDate.day + 1);
    await _daoDatabase.editTodoItemById(
        id: state.todoItemId, targetDateTime: increasedTargetDate);
    emit(state.copyWith(todoItem: state.todoItem.copyWith(targetDateTime: increasedTargetDate)));
  }

  void _onSetAutoPauseSeconds(SetAutoPauseSeconds event, Emitter<TodoItemBlocState> emit) async {
    await _daoDatabase.editTodoItemById(
        id: state.todoItemId, autoPauseSeconds: event.autoPauseSeconds);
    emit(state.copyWith(todoItem: state.todoItem.copyWith(autoPauseSeconds: event.autoPauseSeconds)));
  }

  void _onSetTodoItemImageEvent(SetTodoItemImageEvent event, Emitter<TodoItemBlocState> emit) async {
    emit(state.copyWith(imageFile: ServiceImagePluginWork.checkFileExist(state.todoItem)));
  }

  void _onSetTimerActiveEvent(SetTimerActiveEvent event, Emitter<TodoItemBlocState> emit) async {
    emit(state.copyWith(isTimerActive: event.isActive));
  }

  Future<void> _onChangeItemDateEvent(
      RequestChangeItemDateEvent event, Emitter<TodoItemBlocState> emit) async {
    {
      DateTime? userInput = await ToolShowOverlay.showUserInputOverlay<DateTime>(
        context: event.buildContext,
        child: ChooseDateWidget(),
      );
      if (userInput != null) {
        await _daoDatabase.editTodoItemById(id: state.todoItemId, targetDateTime: userInput!);
        emit(state.copyWith(todoItem: state.todoItem.copyWith(targetDateTime: userInput)));
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
    if (StreamControllerService.stopStream(timerIdentifier)) {
      this.add(SetTimerActiveEvent(isActive: false));
      return;
    }
    Future<bool> Function() callBack = () async {
      int remainSeconds = await state.dbTodoItemGetter.timerSeconds;
      int secondSpent = await state.dbTodoItemGetter.secondSpent;
      if (remainSeconds == 0) {
        StreamControllerService.stopStream(timerIdentifier);
        return false;
      } else {
        _daoDatabase.editTodoItemById(id: state.todoItemId, timerSeconds: remainSeconds - 1, secondsSpent: secondSpent +1);
        return true;
      }
    };
    Duration periodDuration = Duration(seconds: 1);
    Stream timerStream = StreamControllerService.addStreamItem(
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
    StreamControllerService.addListener(
        subscription: streamSubscription, identifier: timerIdentifier);
    this.add(SetTimerActiveEvent(isActive: true));
    StreamControllerService.stopStream(stopwatchIdentifier); //останавливаем секундомер если он был
  }

  Future<void> _onStopStartStopwatchEvent(StopStartStopwatchEvent event, Emitter<TodoItemBlocState> emit) async {
    if (StreamControllerService.stopStream(stopwatchIdentifier)) {
      this.add(SetTimerActiveEvent(isActive: false));
      return;
    }
    Future<bool> Function() callBack = () async {
      int crntSeconds = await state.dbTodoItemGetter.stopwatchSeconds;
      if (crntSeconds > 2400) {
        StreamControllerService.stopStream(stopwatchIdentifier);
        _onTimerEnd();
        return false;
      } else {
        int secondSpent = await state.dbTodoItemGetter.secondSpent;
        _daoDatabase.editTodoItemById(id: state.todoItemId, stopwatchSeconds: crntSeconds + 1, secondsSpent: secondSpent+1);
        return true;
      }
    };
    Duration periodDuration = Duration(seconds: 1);
    Stream timerStream = StreamControllerService.addStreamItem(
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
    StreamControllerService.addListener(
        subscription: streamSubscription, identifier: stopwatchIdentifier);
    this.add(SetTimerActiveEvent(isActive: true));
    StreamControllerService.stopStream(timerIdentifier); //останавливаем таймер если он был
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
    print('new timer $newTimer');
    emit(state.copyWith(todoItem: state.todoItem.copyWith(timerSeconds: newTimer)));
  }

  Future<void> _onLoseFocusEvent(LoseFocusEvent event, Emitter<TodoItemBlocState> emit) async {
    if (!ToolShowOverlay.isOpen) {
      try {
        await _daoDatabase.editTodoItemById(
            id: state.todoItemId, title: event.titleText, content: event.descriptionText);
      } catch (e) {
        print(e);
      }
      emit(state.copyWith(todoItem: await state.dbTodoItemGetter.todoItem));
      this.add(ChangeModEvent(isChangeMod: false));
    }
  }

  Future<void> _onDismissEvent(DismissEvent event, Emitter<TodoItemBlocState> emit) async {
    DateTime dateNow = DateTime.now();
    if (dateNow.hour < 3){
      dateNow = dateNow.copyWith(day: dateNow.day - 1);
    }
    if (event.direction == DismissDirection.startToEnd) {
      //right
      if (state.todoItem.category == EnumTodoCategory.social.name){
        await _daoDatabase.editTodoItemById(
          id: state.todoItemId,
          category: EnumTodoCategory.history_social.name,
          isDone: true,
          targetDateTime: dateNow,
        );
      } else {
        await _daoDatabase.editTodoItemById(
          id: state.todoItemId,
          category: EnumTodoCategory.history.name,
          isDone: true,
          targetDateTime: dateNow,
        );
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
      ToolShowToast.showWithCallBack(message: 'Задача удаленна.', callback: returnItemCallBack);
    }
    Future.delayed(Duration.zero, () {
      Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
    });
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
  File? imageFile;

  TodoItemBlocState({
    this.timerMod = TimeModEnum.none,
    required this.todoItem,
    this.changeTextMod = false,
    this.isTimerActive = false,
    this.imageFile,
  })  : todoItemId = todoItem.id,
        dbTodoItemGetter = DbTodoItemGetter(itemId: todoItem.id) {
    imageFile = ServiceImagePluginWork.checkFileExist(todoItem);
  }

  TodoItemBlocState copyWith({
    TodoItem? todoItem,
    TimeModEnum? timerMod,
    bool? changeTextMod,
    bool? isTimerActive,
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

class LoseFocusEvent extends TodoItemBlocEvent {
  String titleText;
  String descriptionText;

  LoseFocusEvent({required this.titleText, required this.descriptionText});
}

class ChangeModEvent extends TodoItemBlocEvent {
  bool isChangeMod;

  ChangeModEvent({required this.isChangeMod});
}

class RequestChangeItemDateEvent extends TodoItemBlocEvent {
  BuildContext buildContext;
  DateTime? userDateTime;

  RequestChangeItemDateEvent({required this.buildContext, this.userDateTime});
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
