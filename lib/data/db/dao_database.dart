import 'dart:async';

import 'package:drift/drift.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';

import 'app_database.dart';
import 'mapper_database.dart';
import '../../domain/todo_item.dart';

class DaoDatabase {
  AppDatabase db = AppDatabase.instance;

  // Future<List<TodoItem>> getAllTodoItem() async =>
  //     MapperDatabase.listToEntityTodoItem(await db.select(db.todoItemDB).get());

  Future<List<TodoItem>> getActiveTodoItem() async =>
    MapperDatabase.listToEntityTodoItem(await (db.select(db.todoItemDB)..where((tbl) =>
    tbl.category.equals(EnumTodoCategory.active.name) |
    tbl.category.equals(EnumTodoCategory.social.name)
    )).get());

  Future<List<TodoItem>> getDailyTodoItem() async =>
      MapperDatabase.listToEntityTodoItem(await (db.select(db.todoItemDB)..where((tbl) => tbl.category.equals(EnumTodoCategory.daily.name))).get());


  // Future<Stream<List<TodoItem>>> getAllTodoItemStream() async {
  //   final query = db.select(db.todoItemDB).watch();
  //   final streamController = StreamController<List<TodoItem>>();
  //   final subscription = query.listen((data) {
  //     streamController.add(MapperDatabase.listToEntityTodoItem(data));
  //   });
  //   streamController.onCancel = () {
  //     subscription.cancel();
  //   };
  //   return streamController.stream;
  // }


  Future<TodoItem?> getTodoItem({required int id}) async {
    TodoItemDBData? dbModel = await (db.select(db.todoItemDB)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (dbModel == null){
      return null;
    }
    return MapperDatabase.toEntityTodoItem(dbModel);
  }
  
  Future insertTodoItem(TodoItem todoItem) =>
      db.into(db.todoItemDB).insertOnConflictUpdate(MapperDatabase.toDBTodoItem(todoItem));

  Future insertDailyItem({required String title, int? timer}) async {
    final todoDailyItem = TodoItemDBCompanion.insert(
      title: title,
      content: '',
      category: Value(EnumTodoCategory.daily.name),
      timerSeconds: Value(timer ?? 0),
    );
    await db.into(db.todoItemDB).insert(todoDailyItem);
  }

    Future insertEmptyItem({bool isDaily = false}) async {
      final todoItem = TodoItemDBCompanion.insert(
        title: 'New Title',
        content: '',
        category: Value(EnumTodoCategory.active.name),
        targetDateTime: Value<DateTime?>(DateTime.now()),
      );
      await db.into(db.todoItemDB).insert(todoItem);
  }

  Future deleteTodoItem(TodoItem todoItem) =>
      db.delete(db.todoItemDB).delete(MapperDatabase.toDBTodoItem(todoItem));

  Future<void> deleteTodoItemById({required int itemId}) async {
    TodoItemDBData? itemForDel = await (db.select(db.todoItemDB)..where((tbl) => tbl.id.equals(itemId))).getSingleOrNull();
    if(itemForDel != null) {
      db.delete(db.todoItemDB).delete(itemForDel);
    }
  }

  Future deleteAll() async {
    var list = await db.select(db.todoItemDB).get();
    try {
      for (var item in list) {
        db.delete(db.todoItemDB).delete(item);
      }
    } catch (e) {}
    print('dell aall data');
  }

  Future<void> editTodoItemById({
    required id,
    String? title,
    String? content,
    String? category,
    int? timerSeconds,
    int? stopwatchSeconds,
    bool? isDone,
    DateTime? targetDateTime,
  }) async {
    if ((title?.length ?? 0) > 60 ){
      title = title!.substring(0, 60);
      ToolShowToast.showError('Длинный текс. Сократил до 60');
    }
      await db.update(db.todoItemDB)
        ..where((tbl) => tbl.id.equals(id))
        ..write(TodoItemDBCompanion(
          id: Value(id),
          title: title != null ? Value(title) : const Value.absent(),
          content: content != null ? Value(content) : const Value.absent(),
          category: category != null ? Value(category) : const Value.absent(),
          timerSeconds: timerSeconds != null ? Value(timerSeconds) : const Value.absent(),
          stopwatchSeconds: stopwatchSeconds != null ? Value(stopwatchSeconds) : const Value
              .absent(),
          isDone: isDone != null ? Value(isDone) : const Value.absent(),
          targetDateTime: targetDateTime != null ? Value(targetDateTime) : const Value.absent(),
        ));

  }


  editTodoItem(TodoItem todoItem) {
    db.update(db.todoItemDB).write(MapperDatabase.toDBTodoItem(todoItem));
  }
}
