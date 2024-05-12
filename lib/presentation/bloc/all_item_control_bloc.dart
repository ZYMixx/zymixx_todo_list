import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/presentation/bloc/daily_todo_bloc.dart';

import '../../domain/todo_item.dart';

class AllItemControlBloc extends Bloc<ItemControlBlocEvent, ItemControlBlocState> {
  final DaoDatabase _daoDB = DaoDatabase();

// fsdfe
  AllItemControlBloc()
      : super(ItemControlBlocState(
            todoActiveItemList: [], todoDailyItemList: [], todoHistoryItemList: [])) {
    Log.i('init parent bloc');
    createDalyBloc();
    GlobalDbDao.broadcastActiveTodoStream.listen((newList) {
      this.add(LoadAllItemEvent());
    });
    GlobalDbDao.streamAllOtherEvent.stream.listen((newList) {
      this.add(UpdateTodoListOnlyEvent());
    });
    on<UpdateTodoListOnlyEvent>((event, emit) async {
      state.todoActiveItemList = await _daoDB.getActiveTodoItems();
      state.todoDailyItemList = await _daoDB.getDailyTodoItems();
    });
    on<LoadAllItemEvent>((event, emit) async {
      var itemList = await _daoDB.getActiveTodoItems();
      var todoDailyList = await _daoDB.getDailyTodoItems();
      var todoHistoryItemList = await _daoDB.getHistoryTodoItems();
      Log.i('itemList $itemList');
      Log.i('todoDailyList ${todoDailyList.length} $todoDailyList');
      Log.i('todoHistoryItemList $todoHistoryItemList');
      // for (var item in itemList){
      //   await _daoDB.editTodoItemById(id: item.id, secondsSpent: 0);
      // }
       //for (var item in todoDailyList){
       //  await _daoDB.editTodoItemById(id: item.id, secondsSpent: 0);
       //  await _daoDB.deleteTodoItemById(itemId: item.id);
       //}
      // for (var item in todoHistoryItemList){
      //   await _daoDB.editTodoItemById(id: item.id, secondsSpent: 0);
      // }
      emit(state.copyWith(
          todoActiveItemList: itemList,
          todoDailyItemList: todoDailyList,
          todoHistoryItemList: todoHistoryItemList));
    });
    on<LoadDailyItemEvent>((event, emit) async {
      var todoDailyList = await _daoDB.getDailyTodoItems();
      emit(state.copyWith(todoDailyItemList: todoDailyList));
    });
    on<AddNewItemEvent>((event, emit) async {
      await _daoDB.insertEmptyItem(userDateTime: event.dateTime);
    });
    on<AddNewDailyItemEvent>((event, emit) async {
      await _daoDB.insertDailyItem(title: event.name ?? '', timer: event.timer, autoPauseSeconds: event.autoPauseSeconds);
      var todoDailyList = await _daoDB.getDailyTodoItems();
      emit(state.copyWith(todoDailyItemList: todoDailyList));
    });
    on<DellAllItemEvent>((event, emit) async {});
    on<DeleteItemEvent>((event, emit) async {
      Log.i('try to delite');
      await _daoDB.deleteTodoItem(event.todoItem);
      this.add(LoadAllItemEvent());
    });
    on<ChangeItemEvent>((event, emit) async {
      await _daoDB.editTodoItemById(
          id: event.todoItem.id, isDone: false, category: EnumTodoCategory.active.name);
      this.add(LoadAllItemEvent());
    });
  }

  createDalyBloc() async {
    List<TodoItem> todayDailyList = await _daoDB.getTodayDailyTodoItems();
    Log.e('$todayDailyList getTodayDailyTodoItems');
    if (todayDailyList.isNotEmpty) {
      return;
    }
    List<TodoItem> dailyList = (await _daoDB.getDailyTodoItems())
        .where((element) => element.content != DailyTodoBloc.delDataBaseKey).toList(growable: false);
    Set<String> uniqueDailyTitleList = dailyList.map((e) => e.title!).toSet();
    for (var uniqueTitle in uniqueDailyTitleList) {
      var dailyItem = dailyList.firstWhere((element) => element.title == uniqueTitle);
      _daoDB.insertDuplicateTodoItem(dailyItem.copyWith(targetDateTime: DateTime.now(), isDone: false, secondsSpent: 0));
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
  String? name;
  int? timer;
  int autoPauseSeconds;

  AddNewDailyItemEvent({
    required this.name,
    required this.autoPauseSeconds,
    this.timer,
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

  ChangeItemEvent({
    required this.todoItem,
  });
}

class DellAllItemEvent extends ItemControlBlocEvent {}
