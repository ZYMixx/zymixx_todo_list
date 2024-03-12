import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';

import '../../domain/todo_item.dart';

class AllItemControlBloc extends Bloc<ItemControlBlocEvent, ItemControlBlocState> {
  final DaoDatabase _daoDB = DaoDatabase();
// fsdfe
  AllItemControlBloc() : super(ItemControlBlocState(todoItemList: [])) {
    on<LoadAllItemEvent>((event, emit) async {
      var itemList = await _daoDB.getAllTodoItem();
      emit(ItemControlBlocState(todoItemList: itemList));
    });
    on<AddNewItemEvent>((event, emit) async {
      await _daoDB.insertEmptyItem();
      var itemList = await _daoDB.getAllTodoItem();
      print('itemList $itemList');
      emit(ItemControlBlocState(todoItemList: itemList));
    });
    on<DellAllItemEvent>((event, emit) async {
      _daoDB.deleteAll();
    });
  }
}

class ItemControlBlocState {
  List<TodoItem> todoItemList;

  ItemControlBlocState({
    required this.todoItemList,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemControlBlocState &&
          runtimeType == other.runtimeType &&
          todoItemList == other.todoItemList;

  @override
  int get hashCode => todoItemList.hashCode;
}

class ItemControlBlocEvent {}

class LoadAllItemEvent extends ItemControlBlocEvent {}

class AddNewItemEvent extends ItemControlBlocEvent {}

class DeleteItemEvent extends ItemControlBlocEvent {}

class DellAllItemEvent extends ItemControlBlocEvent {}
