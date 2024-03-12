import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';

import '../../data/services/service_get_time.dart';

enum TimeModEnum { timer, stopwatch, none }

class TodoItemBloc extends Bloc<TodoItemBlocEvent, TodoItemBlocState> {
  final _daoDatabase = DaoDatabase();

  TodoItemBloc({required TodoItem intTodoItem}) : super(TodoItemBlocState(todoItem: intTodoItem)) {
    //grp TimeEvent
    on<TimerSecondTickEvent>((event,  emit) => _onTimerSecondTickEvent(event, emit));
    on<ResumeTimerEvent>((event,emit) => _onResumeTimerEvent(event, emit));
    on<ResumeStopwatchEvent>((event,emit) => _onResumeStopwatchEvent(event, emit));
    on<StopwatchSecondTickEvent>((event,emit) => _onStopwatchSecondTickEvent(event, emit));
    on<ChangeTimeModEvent>((event,emit) => _onChangeTimeModEvent(event, emit));
    on<ChangeTimerEvent>((event,emit) => _onChangeTimerEvent(event, emit));
    on<LoseFocusEvent>((event,emit) => _onLoseFocusEvent(event, emit));
    on<DismissEvent>((event,emit) => _onDismissEvent(event, emit));
    on<ChangeModEvent>((event,emit) {emit(state.copyWith(changeTextMod: event.isChangeMod));});


  }

  _onTimerEnd() {
    ServiceAudioPlayer.playTimerAlert();
  }

  void _onTimerSecondTickEvent(TimerSecondTickEvent event, Emitter<TodoItemBlocState> emit) {
    int time = state.todoItem.timerSeconds - 1;
    if (time == 0) {
      if (state.isTimerRun) {
        state.subStreamTimer?.cancel();
        state.subStreamTimer = null;
        _onTimerEnd();
        emit(state.copyWith(todoItem: state.todoItem.copyWith(timerSeconds: time)));
        return;
      }
    }
    if (time < 0) {
      time = 0;
      state.subStreamTimer?.cancel();
      state.subStreamTimer = null;
      emit(state.copyWith(todoItem: state.todoItem.copyWith(timerSeconds: time)));
      return;
    }
    emit(state.copyWith(todoItem: state.todoItem.copyWith(timerSeconds: time)));
  }

  void _onResumeTimerEvent(ResumeTimerEvent event, Emitter<TodoItemBlocState> emit) {
    if (state.subStreamTimer != null) {
      state.subStreamTimer?.cancel();
      state.subStreamTimer = null;
    } else {
      var subscription = Get.find<ServiceGetTime>().secTickStream.listen((event) {
        add(TimerSecondTickEvent());
      });
      emit(state.copyWith(subStreamTimer: subscription));
    }
  }

  void _onResumeStopwatchEvent(ResumeStopwatchEvent event, Emitter<TodoItemBlocState> emit) {
    if (state.isTimerRun) {
      state.subStreamTimer?.cancel();
      state.subStreamTimer = null;
    } else {
      var subscription = Get.find<ServiceGetTime>().secTickStream.listen((event) {
        add(StopwatchSecondTickEvent());
      });
      emit(state.copyWith(subStreamTimer: subscription));
    }
  }

  void _onStopwatchSecondTickEvent(StopwatchSecondTickEvent event, Emitter<TodoItemBlocState> emit) {
    int time = state.todoItem.stopwatchSeconds + 1;
    emit(state.copyWith(todoItem: state.todoItem.copyWith(stopwatchSeconds: time)));
  }

  void _onChangeTimeModEvent(ChangeTimeModEvent event, Emitter<TodoItemBlocState> emit) {
    emit(state.copyWith(timerMod: event.timerMod));
  }

  void _onChangeTimerEvent(ChangeTimerEvent event, Emitter<TodoItemBlocState> emit) {
    int newTimer = state.todoItem.timerSeconds + event.changeNum;
    if (newTimer < 0) {
      newTimer = 0;
    }
    print('new timer $newTimer');
    emit(state.copyWith(todoItem: state.todoItem.copyWith(timerSeconds: newTimer)));
    }

  Future<void> _onLoseFocusEvent(LoseFocusEvent event, Emitter<TodoItemBlocState> emit) async {
    await _daoDatabase.insertTodoItem(state.todoItem.copyWith(title: event.titleText, content: event.descriptionText));
    emit(state.copyWith(todoItem: state.todoItem.copyWith(title: event.titleText, content: event.descriptionText)));
  }

  Future<void> _onDismissEvent(DismissEvent event, Emitter<TodoItemBlocState> emit) async {
    if (event.direction == DismissDirection.startToEnd) {
      //right
      await _daoDatabase.deleteTodoItem(state.todoItem);
    }
    if (event.direction == DismissDirection.endToStart) {
      //left
      await  _daoDatabase.deleteTodoItem(state.todoItem);
    }
    Log.i('diss miss end');

  }

}

//grp STATE

class TodoItemBlocState {
  TodoItem todoItem;
  TimeModEnum timerMod;
  StreamSubscription? subStreamTimer;
  bool changeTextMod;

  bool get isTimerRun => subStreamTimer == null ? false : !subStreamTimer!.isPaused;

  TodoItemBlocState({
    this.timerMod = TimeModEnum.none,
    required this.todoItem,
    this.subStreamTimer,
    this.changeTextMod = false,
  });

  TodoItemBlocState copyWith({
    TodoItem? todoItem,
    TimeModEnum? timerMod,
    StreamSubscription? subStreamTimer,
    bool? changeTextMod,
  }) {
    return TodoItemBlocState(
      todoItem: todoItem ?? this.todoItem,
      timerMod: timerMod ?? this.timerMod,
      subStreamTimer: subStreamTimer ?? this.subStreamTimer,
      changeTextMod: changeTextMod ?? this.changeTextMod,
    );
  }
}

//grp EVENT

class TodoItemBlocEvent {}

class TimerSecondTickEvent extends TodoItemBlocEvent {}

class StopwatchSecondTickEvent extends TodoItemBlocEvent {}

class ResumeTimerEvent extends TodoItemBlocEvent {}

class ResumeStopwatchEvent extends TodoItemBlocEvent {}

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
