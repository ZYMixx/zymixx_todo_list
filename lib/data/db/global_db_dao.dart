import 'dart:async';

import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/app_database.dart';
import 'package:zymixx_todo_list/data/db/mapper_database.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class GlobalDbDao {
  AppDatabase get _db =>  Get.find<AppDatabase>();
  MapperDatabase _mapperDatabase = Get.find<MapperDatabase>();

  Stream<List<TodoItem>> get broadcastActiveTodoStream =>
      _broadcastActiveTodoStream ??= initActiveStream();
  Stream<List<TodoItem>>? _broadcastActiveTodoStream;

  final StreamController<List<TodoItem>> streamAllOtherEvent =
      StreamController<List<TodoItem>>();

  Stream<List<TodoItem>> initActiveStream() {
    int? lastUpdateTodoItemListSize;
    final query = (_db.select(_db.todoItemDB)
          ..where((tbl) =>
              tbl.category.equals(EnumTodoCategory.active.name) |
              tbl.category.equals(EnumTodoCategory.social.name)))
        .watch();
    final streamController = StreamController<List<TodoItem>>();
    query.listen((data) {
      if (lastUpdateTodoItemListSize == null || lastUpdateTodoItemListSize != data.length) {
        List<TodoItem> mappedList = _mapperDatabase.listToEntityTodoItem(data);
        streamController.add(mappedList);
        lastUpdateTodoItemListSize = mappedList.length;
      } else {
        List<TodoItem> mappedList = _mapperDatabase.listToEntityTodoItem(data);
        streamAllOtherEvent.add(mappedList);
      }
    });
    return streamController.stream.asBroadcastStream();
  }

  Future<List<TodoItem>> getActiveTodoItem() async =>
      _mapperDatabase.listToEntityTodoItem(await (_db.select(_db.todoItemDB)
            ..where((tbl) =>
                tbl.category.equals(EnumTodoCategory.active.name) |
                tbl.category.equals(EnumTodoCategory.social.name)))
          .get());

  Future<List<TodoItem>> getHistoryTodoItem() async =>
      _mapperDatabase.listToEntityTodoItem(await (_db.select(_db.todoItemDB)
            ..where((tbl) => tbl.category.equals(EnumTodoCategory.history.name)))
          .get());

  Future<List<TodoItem>> getAllTodoItem() async =>
      _mapperDatabase.listToEntityTodoItem(await (_db.select(_db.todoItemDB)).get());
}
