import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/services/service_image_plugin_work.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/presentation/bloc/daily_todo_bloc.dart';

import '../../domain/todo_item.dart';

class AllItemControlBloc extends Bloc<ItemControlBlocEvent, ItemControlBlocState> {
  final DaoDatabase _daoDB;

  AllItemControlBloc()
      : _daoDB = DaoDatabase(),
        super(
          ItemControlBlocState(
            todoActiveItemList: [],
            todoDailyItemList: [],
            todoHistoryItemList: [],
          )
        ) {
    Log.i('init parent bloc');
    createDalyBloc();
    _initializeEventListeners();
  }

  void _initializeEventListeners() {
    GlobalDbDao.broadcastActiveTodoStream.listen((newList) {
      this.add(LoadAllItemEvent());
    });

    GlobalDbDao.streamAllOtherEvent.stream.listen((newList) {
      this.add(UpdateTodoListOnlyEvent());
    });

    on<UpdateTodoListOnlyEvent>(_onUpdateTodoListOnlyEvent);
    on<LoadAllItemEvent>(_onLoadAllItemEvent);
    on<LoadDailyItemEvent>(_onLoadDailyItemEvent);
    on<AddNewItemEvent>(_onAddNewItemEvent);
    on<AddNewDailyItemEvent>(_onAddNewDailyItemEvent);
    on<DellAllItemEvent>(_onDellAllItemEvent);
    on<DeleteItemEvent>(_onDeleteItemEvent);
    on<ChangeItemEvent>(_onChangeItemEvent);
  }

  void _onUpdateTodoListOnlyEvent(
      UpdateTodoListOnlyEvent event, Emitter<ItemControlBlocState> emit) async {
    state.todoActiveItemList = await _daoDB.getActiveTodoItems();
    state.todoDailyItemList = await _daoDB.getDailyTodoItems();
  }

  void _onLoadAllItemEvent(LoadAllItemEvent event, Emitter<ItemControlBlocState> emit) async {
    var itemList = await _daoDB.getActiveTodoItems();
    var todoDailyList = await _daoDB.getDailyTodoItems();
    var todoHistoryItemList = await _daoDB.getHistoryTodoItems();
    ServiceImagePluginWork.loadImageData();
    emit(state.copyWith(
        todoActiveItemList: itemList,
        todoDailyItemList: todoDailyList,
        todoHistoryItemList: todoHistoryItemList));
  }

  void _onLoadDailyItemEvent(LoadDailyItemEvent event, Emitter<ItemControlBlocState> emit) async {
    var todoDailyList = await _daoDB.getDailyTodoItems();
    emit(state.copyWith(todoDailyItemList: todoDailyList));
  }

  void _onAddNewItemEvent(AddNewItemEvent event, Emitter<ItemControlBlocState> emit) async {
    await _daoDB.insertEmptyItem(userDateTime: event.dateTime);
  }

  void _onAddNewDailyItemEvent(
      AddNewDailyItemEvent event, Emitter<ItemControlBlocState> emit) async {
    Map<String, dynamic> contentMap = {
      'prise': event.prise,
      'dailyDayList': event.dailyDayList,
      'period': event.period,
      '${DailyTodoBloc.delDataBaseKey}': false
    };
    await _daoDB.insertDailyItem(
      title: event.name ?? '',
      timer: event.timer,
      autoPauseSeconds: event.autoPauseSeconds,
      content: jsonEncode(contentMap),
    );
    var todoDailyList = await _daoDB.getDailyTodoItems();
    emit(state.copyWith(todoDailyItemList: todoDailyList));
  }

  void _onDellAllItemEvent(DellAllItemEvent event, Emitter<ItemControlBlocState> emit) async {
    // Ваш код обработки DellAllItemEvent
  }

  void _onDeleteItemEvent(DeleteItemEvent event, Emitter<ItemControlBlocState> emit) async {
    await _daoDB.deleteTodoItem(event.todoItem);
    this.add(LoadAllItemEvent());
  }

  void _onChangeItemEvent(ChangeItemEvent event, Emitter<ItemControlBlocState> emit) async {
    if (event.category != null) {
      await _daoDB.editTodoItemById(
          id: event.todoItem.id, isDone: false, category: event.category?.name);
    } else {
      await _daoDB.editTodoItemById(
          id: event.todoItem.id, isDone: false, category: EnumTodoCategory.active.name);
    }
    this.add(LoadAllItemEvent());
  }

  createDalyBloc() async {
    List<TodoItem> todayDailyList = await _daoDB.getTodayDailyTodoItems();
    if (todayDailyList.isNotEmpty) {
      return;
    }

    List<TodoItem> dailyList = (await _daoDB.getDailyTodoItems())
        .where((element) => jsonDecode(element.content)[DailyTodoBloc.delDataBaseKey] == false)
        .toList(growable: false);

    Set<String> uniqueDailyTitleList = dailyList.map((e) => e.title!).toSet();

    for (var uniqueTitle in uniqueDailyTitleList) {
      var dailyItem = dailyList.firstWhere((element) => element.title == uniqueTitle);
      var contentMap = jsonDecode(dailyItem.content);

      int period = contentMap['period'] ?? 0;
      List<int> dailyDayList = List<int>.from(contentMap['dailyDayList'] ?? []);

      if (shouldCreateDaily(period, dailyDayList, dailyList, dailyItem.title)) {
        _daoDB.insertDuplicateTodoItem(
          dailyItem.copyWith(
            targetDateTime: DateTime.now(),
            isDone: false,
            secondsSpent: 0,
          ),
        );
      }
    }
  }

  bool shouldCreateDaily(
      int period, List<int> dailyDayList, List<TodoItem> dailyList, String? title) {
    if (period > 0 && period <= 3) {
      DateTime now = DateTime.now();
      for (int i = 1; i <= period; i++) {
        DateTime pastDate = now.subtract(Duration(days: i));
        if (dailyList
            .any((item) => item.title == title && item.targetDateTime!.isSameDay(pastDate))) {
          return false;
        }
      }
    }
    int todayWeekday = DateTime.now().weekday;
    if (dailyDayList.isNotEmpty) {
      if (dailyDayList.contains(todayWeekday)) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  @override
  Future<void> close() async {}
}

//todoActiveItemList
class ItemControlBlocState {
  List<TodoItem> todoActiveItemList;
  List<TodoItem> todoDailyItemList;
  List<TodoItem> todoHistoryItemList;

  ItemControlBlocState({
    required this.todoActiveItemList,
    required this.todoDailyItemList,
    required this.todoHistoryItemList,
  }) {}

  ItemControlBlocState copyWith({
    List<TodoItem>? todoActiveItemList,
    List<TodoItem>? todoDailyItemList,
    List<TodoItem>? todoHistoryItemList,
  }) {
    return ItemControlBlocState(
      todoActiveItemList: todoActiveItemList ?? this.todoActiveItemList,
      todoDailyItemList: todoDailyItemList ?? this.todoDailyItemList,
      todoHistoryItemList: todoHistoryItemList ?? this.todoHistoryItemList,
    );
  }
}

class ItemControlBlocEvent {}

class LoadAllItemEvent extends ItemControlBlocEvent {}

class UpdateTodoListOnlyEvent extends ItemControlBlocEvent {}

class LoadDailyItemEvent extends ItemControlBlocEvent {}

class AddNewItemEvent extends ItemControlBlocEvent {
  EnumTodoCategory? category;
  DateTime? dateTime;

  AddNewItemEvent({
    this.category,
    this.dateTime,
  });
}

class AddNewDailyItemEvent extends ItemControlBlocEvent {
  String name;
  int prise;
  int timer;
  int autoPauseSeconds;
  List<int> dailyDayList;
  int period;

  AddNewDailyItemEvent({
    required this.name,
    required this.prise,
    required this.autoPauseSeconds,
    required this.timer,
    required this.dailyDayList,
    required this.period,
  });
}

class DeleteItemEvent extends ItemControlBlocEvent {
  TodoItem todoItem;

  DeleteItemEvent({
    required this.todoItem,
  });
}

class ChangeItemEvent extends ItemControlBlocEvent {
  TodoItem todoItem;
  EnumTodoCategory? category;

  ChangeItemEvent({
    required this.todoItem,
    this.category,
  });
}

class DellAllItemEvent extends ItemControlBlocEvent {}

//grp extension
extension StringExtension on String {
  String capStart() {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}

extension DateTimeExtension on DateTime {
  String getStringDate() {
    initializeDateFormatting('ru', null);
    String month = DateFormat.MMMM('ru').format(this);
    String day = DateFormat.d('ru').format(this);
    String dayOfWeek = DateFormat.E('ru').format(this);

    return '${month.capStart()} $day, ${dayOfWeek}.';
  }

  bool isSameDay(DateTime date) {
    if (date.day == this.day && date.month == this.month && date.year == this.year) {
      return true;
    } else {
      return false;
    }
  }
}
