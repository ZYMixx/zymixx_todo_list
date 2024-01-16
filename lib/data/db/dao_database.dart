import 'app_database.dart';
import 'mapper_database.dart';
import '../../domain/todo_item.dart';

class DaoDatabase {
  AppDatabase db = AppDatabase.instance;

  Future<List<TodoItem>> getAllTodoItem() async =>
      MapperDatabase.listToEntityTodoItem(await db.select(db.todoItemDB).get());

  Future insertTodoItem(TodoItem todoItem) =>
      db.into(db.todoItemDB).insert(MapperDatabase.toDBTodoItem(todoItem));

  Future deleteTodoItem(TodoItem todoItem) =>
      db.delete(db.todoItemDB).delete(MapperDatabase.toDBTodoItem(todoItem));

  editTodoItem(TodoItem todoItem) {
    db.update(db.todoItemDB).replace(MapperDatabase.toDBTodoItem(todoItem));
  }
}
