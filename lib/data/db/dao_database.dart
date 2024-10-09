import 'dart:async';

import 'package:drift/drift.dart';
import 'package:get/get.dart' as GetX;
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_toast.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';

import 'app_database.dart';
import 'mapper_database.dart';
import '../../domain/todo_item.dart';

class DaoDatabase {
  AppDatabase db = GetX.Get.find<AppDatabase>();
  MapperDatabase _mapperDatabase = GetX.Get.find<MapperDatabase>();

  Future<List<TodoItem>> getActiveTodoItems() async =>
      _mapperDatabase.listToEntityTodoItem(await (db.select(db.todoItemDB)
            ..where(
              (tbl) =>
                  tbl.category.equals(EnumTodoCategory.active.name) |
                  tbl.category.equals(EnumTodoCategory.social.name),
            ))
          .get());

  Future<List<TodoItem>> getDailyTodoItems() async =>
      _mapperDatabase.listToEntityTodoItem(await (db.select(db.todoItemDB)
            ..where(
              (tbl) => tbl.category.equals(EnumTodoCategory.daily.name),
            ))
          .get());

  Future<List<TodoItem>> getTodayDailyTodoItems() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return _mapperDatabase.listToEntityTodoItem(await (db.select(db.todoItemDB)
          ..where((tbl) {
            return tbl.category.equals(EnumTodoCategory.daily.name) &
                tbl.targetDateTime.isBetweenValues(todayStart, todayEnd);
          }))
        .get());
  }

  Future<List<TodoItem>> getHistoryTodoItems() async =>
      _mapperDatabase.listToEntityTodoItem(await (db.select(db.todoItemDB)
            ..where((tbl) =>
                tbl.category.equals(EnumTodoCategory.history.name) |
                tbl.category.equals(EnumTodoCategory.history_social.name)))
          .get());

  Future<TodoItem?> getTodoItem({required int id}) async {
    TodoItemDBData? dbModel =
        await (db.select(db.todoItemDB)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    if (dbModel == null) {
      return null;
    }
    return _mapperDatabase.toEntityTodoItem(dbModel);
  }

  Future insertTodoItem(TodoItem todoItem) =>
      db.into(db.todoItemDB).insertOnConflictUpdate(_mapperDatabase.toDBTodoItem(todoItem));

  Future insertDuplicateTodoItem(TodoItem todoItem) async {
    Log.i('duplicate ${todoItem.toStringFull()}');
    await db.into(db.todoItemDB).insert(TodoItemDBCompanion.insert(
          id: Value<int?>(null),
          title: todoItem.title!,
          content: todoItem.content,
          category: Value(todoItem.category),
          timerSeconds: Value(todoItem.timerSeconds),
          stopwatchSeconds: Value(todoItem.stopwatchSeconds),
          secondsSpent: Value(todoItem.secondsSpent),
          isDone: Value(todoItem.isDone),
          targetDateTime: Value(todoItem.targetDateTime),
      autoPauseSeconds: Value(todoItem.autoPauseSeconds),
        ));
  }

  Future insertDailyItem(
      {required String title, int? timer, String? content, required int autoPauseSeconds}) async {
    DateTime today = DateTime.now();

    final todoDailyItem = TodoItemDBCompanion.insert(
      title: title,
      content: content ?? '',
      category: Value(EnumTodoCategory.daily.name),
      autoPauseSeconds: Value(autoPauseSeconds),
      timerSeconds: Value(timer ?? 0),
      targetDateTime: Value<DateTime?>(DateTime(today.year, today.month, today.day)),
    );
    await db.into(db.todoItemDB).insert(todoDailyItem);
  }

  Future insertEmptyItem({bool isDaily = false, DateTime? userDateTime}) async {
    DateTime finalDateTime;
    DateTime today = DateTime.now();
    if (userDateTime == null) {
      if (today.hour >= 22) {
        // создаём задачу на следующий день
        finalDateTime = DateTime(today.year, today.month, today.day + 1);
      } else {
        finalDateTime = today;
      }
    } else {
      finalDateTime = userDateTime;
    }
    final todoItem = TodoItemDBCompanion.insert(
      title: 'New Title',
      content: '',
      autoPauseSeconds: Value(15),
      category: Value(EnumTodoCategory.active.name),
      targetDateTime: Value<DateTime?>(finalDateTime),
    );
    await db.into(db.todoItemDB).insert(todoItem);
  }

  Future deleteTodoItem(TodoItem todoItem) =>
      db.delete(db.todoItemDB).delete(_mapperDatabase.toDBTodoItem(todoItem));

  Future<void> deleteTodoItemById({required int itemId}) async {
    TodoItemDBData? itemForDel =
        await (db.select(db.todoItemDB)..where((tbl) => tbl.id.equals(itemId))).getSingleOrNull();
    if (itemForDel != null) {
      db.delete(db.todoItemDB).delete(itemForDel);
    }
  }

  Future<void> updateContentByTitle({required String title, required String newContent}) async {
    List<TodoItemDBData> itemsToUpdate =
        await (db.select(db.todoItemDB)..where((tbl) => tbl.title.equals(title))).get();
    if (itemsToUpdate.isNotEmpty) {
      for (TodoItemDBData item in itemsToUpdate) {
        db.update(db.todoItemDB).replace(item.copyWith(
              content: newContent,
            ));
      }
    }
  }

  Future deleteAll() async {
    var list = await db.select(db.todoItemDB).get();
    try {
      for (var item in list) {
        db.delete(db.todoItemDB).delete(item);
      }
    } catch (e) {}
    Log.e('DELLETED ALL DATA!');
  }

  Future<void> editTodoItemById({
    required int id,
    String? title,
    String? content,
    String? category,
    int? timerSeconds,
    int? stopwatchSeconds,
    int? secondsSpent,
    int? autoPauseSeconds,
    bool? isDone,
    DateTime? targetDateTime,
  }) async {
    if ((title?.length ?? 0) > 60) {
      title = title!.substring(0, 60);
      GetX.Get.find<ToolShowToast>().showError('Длинный текст. Сократил до 60');
    }
    await db.update(db.todoItemDB)
      ..where((tbl) => tbl.id.equals(id))
      ..write(TodoItemDBCompanion(
        id: Value(id),
        title: title != null ? Value(title) : const Value.absent(),
        content: content != null ? Value(content) : const Value.absent(),
        category: category != null ? Value(category) : const Value.absent(),
        timerSeconds: timerSeconds != null ? Value(timerSeconds) : const Value.absent(),
        stopwatchSeconds: stopwatchSeconds != null ? Value(stopwatchSeconds) : const Value.absent(),
        isDone: isDone != null ? Value(isDone) : const Value.absent(),
        targetDateTime: targetDateTime != null ? Value(targetDateTime) : const Value.absent(),
        autoPauseSeconds: autoPauseSeconds != null ? Value(autoPauseSeconds) : const Value.absent(),
        secondsSpent: secondsSpent != null ? Value(secondsSpent) : const Value.absent(),
      ));
  }

  editTodoItem(TodoItem todoItem) {
    db.update(db.todoItemDB).replace(_mapperDatabase.toDBTodoItem(todoItem));
  }
}
