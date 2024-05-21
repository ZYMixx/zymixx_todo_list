import 'dart:async';

import 'package:drift/drift.dart';
import 'package:zymixx_todo_list/data/db/app_database.dart';
import 'package:zymixx_todo_list/data/db/mapper_database.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class GlobalDbDao {
  static AppDatabase get _db => AppDatabase.instance;

  static Stream<List<TodoItem>> get broadcastActiveTodoStream =>
      _broadcastActiveTodoStream ??= initActiveStream();
  static Stream<List<TodoItem>>? _broadcastActiveTodoStream;

  static final StreamController<List<TodoItem>> streamAllOtherEvent =
      StreamController<List<TodoItem>>();

  static Stream<List<TodoItem>> initActiveStream() {
    int? lastUpdateTodoItemListSize;
    final query = (_db.select(_db.todoItemDB)
          ..where((tbl) =>
              tbl.category.equals(EnumTodoCategory.active.name) |
              tbl.category.equals(EnumTodoCategory.social.name)))
        .watch();
    final streamController = StreamController<List<TodoItem>>();
    query.listen((data) {
      if (lastUpdateTodoItemListSize == null || lastUpdateTodoItemListSize != data.length) {
        List<TodoItem> mappedList = MapperDatabase.listToEntityTodoItem(data);
        streamController.add(mappedList);
        lastUpdateTodoItemListSize = mappedList.length;
      } else {
        List<TodoItem> mappedList = MapperDatabase.listToEntityTodoItem(data);
        streamAllOtherEvent.add(mappedList);
      }
    });
    return streamController.stream.asBroadcastStream();
  }

  static Future<List<TodoItem>> getActiveTodoItem() async =>
      MapperDatabase.listToEntityTodoItem(await (_db.select(_db.todoItemDB)
            ..where((tbl) =>
                tbl.category.equals(EnumTodoCategory.active.name) |
                tbl.category.equals(EnumTodoCategory.social.name)))
          .get());

  static Future<List<TodoItem>> getHistoryTodoItem() async =>
      MapperDatabase.listToEntityTodoItem(await (_db.select(_db.todoItemDB)
            ..where((tbl) => tbl.category.equals(EnumTodoCategory.history.name)))
          .get());

  static Future<List<TodoItem>> getAllTodoItem() async =>
      MapperDatabase.listToEntityTodoItem(await (_db.select(_db.todoItemDB)).get());
}
