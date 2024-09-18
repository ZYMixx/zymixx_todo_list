import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/db_todo_item_getter.dart';
import 'package:zymixx_todo_list/data/services/service_statistic_data.dart';
import 'package:zymixx_todo_list/data/services/service_stream_controller.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_merge_json.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/presentation/action_screens/create_daily_widget.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_confirm_delete_dialog.dart';

import '../bloc_global/all_item_control_bloc.dart';

class DailyTodoBloc extends Bloc<DailyTodoEvent, DailyTodoState> {
  final _daoDatabase = DaoDatabase();
  static String delDataBaseKey = 'wasRemoved';

  DailyTodoBloc() : super(DailyTodoState()) {
    _initializeEvents();
  }

  void _initializeEvents() {
    on<CompleteDailyEvent>(_onCompleteDailyEvent);
    on<DeleteDailyEvent>(_onDeleteDailyEvent);
    on<ChangeYesterdayModEvent>(_onChangeYesterdayModEvent);
    on<RequestAddNewDailyEvent>(_onRequestAddNewDailyEvent);
  }

  Future<void> _onCompleteDailyEvent(CompleteDailyEvent event, Emitter<DailyTodoState> emit) async {
    if (event.remainSeconds != 0) {
      await _onStopStartTimerEvent(event, emit);
    } else {
      await _daoDatabase.editTodoItemById(id: event.itemId, isDone: event.isComplete);
      Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
    }
  }

  Future<void> _onDeleteDailyEvent(DeleteDailyEvent event, Emitter<DailyTodoState> emit) async {
    await deleteDailyItem(
      context: event._context,
      content: event.content,
      itemId: event.itemId,
      title: event.title,
    );
  }

  void _onChangeYesterdayModEvent(ChangeYesterdayModEvent event, Emitter<DailyTodoState> emit) {
    emit(state.copyWith(yesterdayDailyMod: !state.yesterdayDailyMod));
  }

  Future<void> _onRequestAddNewDailyEvent(RequestAddNewDailyEvent event, Emitter<DailyTodoState> emit) async {
    try {
      Map<String, dynamic> userInputDataMap = await Get.find<ToolShowOverlay>().showUserInputOverlay(
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
      Log.i('error $e');
    }
  }

  Future<void> deleteDailyItem({
    required BuildContext context,
    required String content,
    required int itemId,
    required String title,
  }) async {
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
            String changedContent = Get.find<ToolMergeJson>().mergeJsonAndMap(content, {delDataBaseKey: true});
            await _daoDatabase.updateContentByTitle(title: title, newContent: changedContent);
            await _daoDatabase.deleteTodoItemById(itemId: itemId);
            Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
          },
        );
      },
    );
  }

  Future<void> _onStopStartTimerEvent(CompleteDailyEvent completeEvent, Emitter<DailyTodoState> emit) async {
    String timerIdentifier = "${completeEvent.itemId}_timer";
    if (state.activeTimerIdentifier != null && timerIdentifier != state.activeTimerIdentifier) {
      Get.find<ServiceStreamController>().stopStream(state.activeTimerIdentifier!);
      state.activeDailyItemGetter = null;
      state.activeTimerIdentifier = null;
      Get.find<ToolShowToast>().showError('Был остановлен другой активный Daily.');
      return;
    }

    if (Get.find<ServiceStreamController>().stopStream(timerIdentifier)) {
      return;
    }

    if (state.activeDailyItemGetter == null) {
      state.activeDailyItemGetter = DbTodoItemGetter(itemId: completeEvent.itemId);
      state.activeTimerIdentifier = timerIdentifier;
    }

    Future<bool> Function() callBack = () async {
      int remainSeconds = await state.activeDailyItemGetter?.timerSeconds ?? 0;
      if (remainSeconds == 0) {
        Get.find<ServiceStreamController>().stopStream(timerIdentifier);
        return false;
      } else {
        await _daoDatabase.editTodoItemById(id: completeEvent.itemId, timerSeconds: remainSeconds - 1);
        return true;
      }
    };

    Duration periodDuration = Duration(seconds: 1);
    Stream timerStream = Get.find<ServiceStreamController>().addStreamItem(
      identifier: timerIdentifier,
      callBack: callBack,
      finishCallBack: () => _onDailyTimerEnd(itemId: completeEvent.itemId),
      autoPauseSeconds: await state.activeDailyItemGetter?.autoPauseSeconds ?? 0,
      periodDuration: periodDuration,
    );
    StreamSubscription streamSubscription = timerStream.listen((event) async {
      if (event) {
        Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
      }
    });
    Get.find<ServiceStreamController>().addListener(subscription: streamSubscription, identifier: timerIdentifier);
  }

  void checkOnActiveTimer({required int itemId, required Function(int) updateCallBack}) {
    String timerIdentifier = "${itemId}_timer";
    Stream? timerStream = Get.find<ServiceStreamController>().resumeStreamListener(identifier: timerIdentifier);
    if (timerStream != null) {
      if (state.activeDailyItemGetter == null) {
        state.activeDailyItemGetter = DbTodoItemGetter(itemId: itemId);
        state.activeTimerIdentifier = timerIdentifier;
      }
      var streamSubscription = timerStream.listen((event) async {
        if (event) {
          Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
        }
      });
      Get.find<ServiceStreamController>().addListener(subscription: streamSubscription, identifier: timerIdentifier);
      Log.i('resubscribe Timer');
    }
  }

  void _onDailyTimerEnd({required int itemId}) {
    Get.find<ServiceStreamController>().stopStream(state.activeTimerIdentifier!);
    state.activeDailyItemGetter = null;
    state.activeTimerIdentifier = null;
    this.add(CompleteDailyEvent(isComplete: true, itemId: itemId, remainSeconds: 0));
  }

  @override
  Future<void> close() async {
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

// если есть таймер то запускать его
  CompleteDailyEvent({
    required this.isComplete,
    required this.itemId,
    required this.remainSeconds,
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
