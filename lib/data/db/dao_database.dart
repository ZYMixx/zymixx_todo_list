import 'package:drift/drift.dart';

import 'app_database.dart';
import 'mapper_database.dart';
import '../../domain/todo_item.dart';

class DaoDatabase {
  AppDatabase db = AppDatabase.instance;

  Future<List<TodoItem>> getAllTodoItem() async =>
      MapperDatabase.listToEntityTodoItem(await db.select(db.todoItemDB).get());

  Future insertTodoItem(TodoItem todoItem) =>
      db.into(db.todoItemDB).insertOnConflictUpdate(MapperDatabase.toDBTodoItem(todoItem));

  Future insertEmptyItem() async {
    final todoItem = TodoItemDBCompanion.insert(title: 'test t', content: 'test c');
    await db.into(db.todoItemDB).insert(todoItem);
  }

  Future deleteTodoItem(TodoItem todoItem) =>
      db.delete(db.todoItemDB).delete(MapperDatabase.toDBTodoItem(todoItem));

  Future deleteAll() async {
    var list = await db.select(db.todoItemDB).get();
    try {
      for (var item in list) {
        db.delete(db.todoItemDB).delete(item);
      }
    } catch (e) {}
    print('dell aall data');
  }

  editTodoItem(TodoItem todoItem) {
    db.update(db.todoItemDB).replace(MapperDatabase.toDBTodoItem(todoItem));
  }
}
