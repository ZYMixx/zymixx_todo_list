import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';

import '../../domain/todo_item.dart';

class AllItemControlBloc extends Bloc<ItemControlBlocEvent, ItemControlBlocState> {
  final DaoDatabase _daoDB = DaoDatabase();
// fsdfe
  AllItemControlBloc() : super(ItemControlBlocState(todoActiveItemList: [], todoDailyItemList: [])) {
    Log.i('init parent bloc');
    GlobalDbDao.broadcastActiveTodoStream.listen((newList) {
          this.add(LoadAllItemEvent());
      });
    on<LoadAllItemEvent>((event, emit) async {
      var itemList = await _daoDB.getActiveTodoItem();
      var todoDailyList = await _daoDB.getDailyTodoItem();
      emit(state.copyWith(todoActiveItemList: itemList, todoDailyItemList: todoDailyList));
    });
    on<LoadDailyItemEvent>((event, emit) async {
      var todoDailyList = await _daoDB.getDailyTodoItem();
      emit(state.copyWith( todoDailyItemList: todoDailyList));
    });
    on<AddNewItemEvent>((event, emit) async {
        await _daoDB.insertEmptyItem();
    });
    on<AddNewDailyItemEvent>((event, emit) async {
      await _daoDB.insertDailyItem(title: event.name ?? '', timer: event.timer);
      var todoDailyList = await _daoDB.getDailyTodoItem();
      emit(state.copyWith(todoDailyItemList: todoDailyList));

    });
    on<DellAllItemEvent>((event, emit) async {
    });

  }

  @override
  Future<void> close() async {
  }
}
//todoActiveItemList
class ItemControlBlocState {
  List<TodoItem> todoActiveItemList;
  List<TodoItem> todoDailyItemList;

  ItemControlBlocState({
    required this.todoActiveItemList,
    required this.todoDailyItemList,
  }) {}

  ItemControlBlocState copyWith({
    List<TodoItem>? todoActiveItemList,
    List<TodoItem>? todoDailyItemList,
  }) {
    return ItemControlBlocState(
      todoActiveItemList: todoActiveItemList ?? this.todoActiveItemList,
      todoDailyItemList: todoDailyItemList ?? this.todoDailyItemList,
    );
  }
}

class ItemControlBlocEvent {}

class LoadAllItemEvent extends ItemControlBlocEvent {}

class LoadDailyItemEvent extends ItemControlBlocEvent {}

class AddNewItemEvent extends ItemControlBlocEvent {
  EnumTodoCategory? category;
  AddNewItemEvent({
    this.category,
  });
}
class AddNewDailyItemEvent extends ItemControlBlocEvent {
  String? name;
  int? timer;

  AddNewDailyItemEvent({
    required this.name,
    this.timer,
  });
}


class DeleteItemEvent extends ItemControlBlocEvent {}

class DellAllItemEvent extends ItemControlBlocEvent {}
