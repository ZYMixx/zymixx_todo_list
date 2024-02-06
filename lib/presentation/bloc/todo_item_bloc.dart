import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';

import '../../data/services/service_get_time.dart';

enum TimeModEnum { timer, stopwatch, none }

class TodoItemBloc extends Bloc<TodoItemBlocEvent, TodoItemBlocState> {
  final _daoDatabase = DaoDatabase();

  @override
  void onEvent(TodoItemBlocEvent event) {
    //print('EVENT ${event}');
  }

  TodoItemBloc({required TodoItem intTodoItem}) : super(TodoItemBlocState(todoItem: intTodoItem)) {
    //TimeEvent

    on<TimerSecondTickEvent>((event, emit) {
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
    });
    on<ResumeTimerEvent>((event, emit) {
      if (state.subStreamTimer != null) {
        state.subStreamTimer?.cancel();
        state.subStreamTimer = null;
      } else {
        var subscription = Get.find<ServiceGetTime>().secTickStream.listen((event) {
          add(TimerSecondTickEvent());
        });
        emit(state.copyWith(subStreamTimer: subscription));
      }
    });
    on<ResumeStopwatchEvent>((event, emit) {
      if (state.isTimerRun) {
        state.subStreamTimer?.cancel();
        state.subStreamTimer = null;
      } else {
        var subscription = Get.find<ServiceGetTime>().secTickStream.listen((event) {
          add(StopwatchSecondTickEvent());
        });
        emit(state.copyWith(subStreamTimer: subscription));
      }
    });
    on<StopwatchSecondTickEvent>((event, emit) {
      int time = state.todoItem.stopwatchSeconds + 1;
      emit(state.copyWith(todoItem: state.todoItem.copyWith(stopwatchSeconds: time)));
    });
    on<ChangeTimeModEvent>((event, emit) {
      emit(state.copyWith(timerMod: event.timerMod));
    });
    on<ChangeTimerEvent>((event, emit) {
      int newTimer = state.todoItem.timerSeconds + event.changeNum;
      if (newTimer < 0) {
        newTimer = 0;
      }
      print('new timer $newTimer');
      emit(state.copyWith(todoItem: state.todoItem.copyWith(timerSeconds: newTimer)));
    });
    //db
    on<LoseFocusEvent>((event, emit) {
      _daoDatabase.insertTodoItem(state.todoItem.copyWith(title: event.titleText));
    });
    on<DismissEvent>((event, emit) {
      if (event.direction == DismissDirection.startToEnd) {
        //right
      }
      if (event.direction == DismissDirection.endToStart) {
        //left
        _daoDatabase.deleteTodoItem(state.todoItem);
      }
    });
  }

  _onTimerEnd() {
    ServiceAudioPlayer.playTimerAlert();
  }
}

class TodoItemBlocState {
  TodoItem todoItem;
  TimeModEnum timerMod;
  StreamSubscription? subStreamTimer;

  bool get isTimerRun => subStreamTimer == null ? false : !subStreamTimer!.isPaused;

  TodoItemBlocState({
    this.timerMod = TimeModEnum.none,
    required this.todoItem,
    this.subStreamTimer,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItemBlocState &&
          runtimeType == other.runtimeType &&
          todoItem == other.todoItem &&
          timerMod == other.timerMod &&
          subStreamTimer == other.subStreamTimer;

  @override
  int get hashCode => todoItem.hashCode ^ timerMod.hashCode ^ subStreamTimer.hashCode;

  TodoItemBlocState copyWith({
    TodoItem? todoItem,
    TimeModEnum? timerMod,
    StreamSubscription? subStreamTimer,
  }) {
    return TodoItemBlocState(
      todoItem: todoItem ?? this.todoItem,
      timerMod: timerMod ?? this.timerMod,
      subStreamTimer: subStreamTimer ?? this.subStreamTimer,
    );
  }
}

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

  LoseFocusEvent({required this.titleText});
}
