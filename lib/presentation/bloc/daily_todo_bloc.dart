import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/db_todo_item_getter.dart';
import 'package:zymixx_todo_list/data/services/stream_controller_service.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_merge_json.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/presentation/action_screens/create_daily_widget.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_confirm_delete_dialog.dart';

class DailyTodoBloc extends Bloc<DailyTodoEvent, DailyTodoState> {
  final _daoDatabase = DaoDatabase();
  static String delDataBaseKey = 'wasRemoved';

  DailyTodoBloc() : super(DailyTodoState()) {
    on<CompleteDailyEvent>((event, emit) {
      if (event.remainSeconds != 0) {
        _onStopStartTimerEvent(event, emit);
      } else {
        _daoDatabase.editTodoItemById(id: event.itemId, isDone: event.isComplete);
        Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
      }
    });
    on<DeleteDailyEvent>((event, emit) async {
      deleteDailyItem(
          context: event._context,
          content: event.content,
          itemId: event.itemId,
          title: event.title);
    });
    on<ChangeYesterdayModEvent>((event, emit) async {
      emit(state.copyWith(yesterdayDailyMod: !state.yesterdayDailyMod));
    });
    on<RequestAddNewDailyEvent>((event, emit) async {
      //! MAP
      //'name': name,
      //'timer': timer,
      //'autoPauseSeconds': autoPauseSeconds,
      //'prise': prise,
      //'dailyDayList': dailyDayList,
      //'period': period,
      try {
        Map<String, dynamic> userInputDataMap = await ToolShowOverlay.showUserInputOverlay(
          context: event._context,
          child: CreateDailyWidget(),
        );
        Get.find<AllItemControlBloc>().add(AddNewDailyItemEvent(
          name: userInputDataMap['name'],
          timer: userInputDataMap['timer'] * 60,
          autoPauseSeconds: userInputDataMap['autoPauseSeconds'],
          prise: userInputDataMap['prise'],
          dailyDayList: userInputDataMap['dailyDayList'],
          period: userInputDataMap['period'],
        ));
      } catch (e) {
        Log.i('eror $e');
      }
    });
  }

  deleteDailyItem(
      {required BuildContext context,
      required String content,
      required int itemId,
      required String title}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyConfirmDeleteDialog(
          contentMessage: 'Удалить на сегодня или совсем?',
          labelOnConfirm: 'Сегодня',
          onConfirm: () async {
            await _daoDatabase.deleteTodoItemById(itemId: itemId);
            Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
          },
          labelOnCancel: 'Навсегда',
          onCancel: () async {
            String changedContent =
                ToolMergeJson.mergeJsonAndMap(content, {'${DailyTodoBloc.delDataBaseKey}': true});
            await _daoDatabase.updateContentByTitle(title: title, newContent: changedContent);
            await _daoDatabase.deleteTodoItemById(itemId: itemId);
            Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
          },
        );
      },
    );
  }

  Future<void> _onStopStartTimerEvent(
      CompleteDailyEvent completeEvent, Emitter<DailyTodoState> emit) async {
    String timerIdentifier = "${completeEvent.itemId.toString()}_timer";
    if (state.activeTimerIdentifier != null && timerIdentifier != state.activeTimerIdentifier) {
      StreamControllerService.stopStream(state.activeTimerIdentifier!);
      state.activeDailyItemGetter = null;
      state.activeTimerIdentifier = null;
      ToolShowToast.showError('Был остановлен другой активный Dealy.');
      return;
    }
    if (StreamControllerService.stopStream(timerIdentifier)) {
      return;
    }
    if (state.activeDailyItemGetter == null) {
      state.activeDailyItemGetter = DbTodoItemGetter(itemId: completeEvent.itemId);
      state.activeTimerIdentifier = timerIdentifier;
    }
    Future<bool> Function() callBack = () async {
      int remainSeconds = await state.activeDailyItemGetter?.timerSeconds ?? 0;
      if (remainSeconds == 0) {
        StreamControllerService.stopStream(timerIdentifier);
        return false;
      } else {
        _daoDatabase.editTodoItemById(id: completeEvent.itemId, timerSeconds: remainSeconds - 1);
        return true;
      }
    };
    Duration periodDuration = Duration(seconds: 1);
    Stream timerStream = StreamControllerService.addStreamItem(
        identifier: timerIdentifier,
        callBack: callBack,
        finishCallBack: () => _onDailyTimerEnd(itemId: completeEvent.itemId),
        autoPauseSeconds: await state.activeDailyItemGetter?.autoPauseSeconds ?? 0,
        periodDuration: periodDuration);
    StreamSubscription streamSubscription = timerStream.listen((event) async {
      if (event) {
        int remainSeconds = await state.activeDailyItemGetter?.timerSeconds ?? 0;
        completeEvent.timerUpdateCB?.call(remainSeconds);
      }
    });
    StreamControllerService.addListener(
        subscription: streamSubscription, identifier: timerIdentifier);
  }

  checkOnActiveTimer({required int itemId, required Function(int) updateCallBack}) {
    String timerIdentifier = "${itemId.toString()}_timer";
    Stream? timerStream = StreamControllerService.resumeStreamListener(identifier: timerIdentifier);
    if (timerStream != null) {
      if (state.activeDailyItemGetter == null) {
        state.activeDailyItemGetter = DbTodoItemGetter(itemId: itemId);
        state.activeTimerIdentifier = timerIdentifier;
      }
      var streamSubscription = timerStream.listen((event) async {
        if (event) {
          int remainSeconds = await state.activeDailyItemGetter?.timerSeconds ?? 0;
          updateCallBack.call(remainSeconds);
        }
      });
      StreamControllerService.addListener(
          subscription: streamSubscription, identifier: timerIdentifier);
      Log.i('resuscribe Timer');
    }
  }

  void _onDailyTimerEnd({required itemId}) {
    StreamControllerService.stopStream(state.activeTimerIdentifier!);
    state.activeDailyItemGetter = null;
    state.activeTimerIdentifier = null;
    this.add(CompleteDailyEvent(isComplete: true, itemId: itemId, remainSeconds: 0));
  }

  @override
  Future<void> close() async {
    emit(state);
  }
}

class DailyTodoState {
  DbTodoItemGetter? activeDailyItemGetter;
  String? activeTimerIdentifier;
  bool yesterdayDailyMod;

  DailyTodoState({
    this.activeDailyItemGetter,
    this.activeTimerIdentifier,
    this.yesterdayDailyMod = false,
  });

  DailyTodoState copyWith({
    DbTodoItemGetter? activeDailyItemGetter,
    String? activeTimerIdentifier,
    bool? yesterdayDailyMod,
  }) {
    return DailyTodoState(
      activeDailyItemGetter: activeDailyItemGetter ?? this.activeDailyItemGetter,
      activeTimerIdentifier: activeTimerIdentifier ?? this.activeTimerIdentifier,
      yesterdayDailyMod: yesterdayDailyMod ?? this.yesterdayDailyMod,
    );
  }
}

class DailyTodoEvent {}

class CompleteDailyEvent extends DailyTodoEvent {
  bool isComplete;
  int itemId;
  int remainSeconds;
  Function(int)? timerUpdateCB;

// если есть таймер то запускать его
  CompleteDailyEvent({
    required this.isComplete,
    required this.itemId,
    required this.remainSeconds,
    this.timerUpdateCB,
  });
}

class DeleteDailyEvent extends DailyTodoEvent {
  int itemId;
  String title;
  String content;
  BuildContext _context;

  DeleteDailyEvent({
    required this.itemId,
    required this.title,
    required this.content,
    required BuildContext context,
  }) : _context = context;
}

class ShowYesterdayChangeDailyEvent extends DailyTodoEvent {
  bool showYesterday;

  ShowYesterdayChangeDailyEvent({
    required this.showYesterday,
  });
}

class RequestAddNewDailyEvent extends DailyTodoEvent {
  BuildContext _context;

  RequestAddNewDailyEvent({
    required BuildContext context,
  }) : _context = context;
}

class ChangeDailyEvent extends DailyTodoEvent {
  ChangeDailyEvent();
}

class ChangeYesterdayModEvent extends DailyTodoEvent {
  ChangeYesterdayModEvent();
}
