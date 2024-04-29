import '../../domain/todo_item.dart';
import 'app_database.dart';

class MapperDatabase {
  static TodoItemDBData toDBTodoItem(TodoItem todoEntity) {
    return TodoItemDBData.fromJson(todoEntity.toJson());
  }

  static List<TodoItemDBData> listToDBTodoItem(List<TodoItem> entityList) =>
      entityList.map((e) => toDBTodoItem(e)).toList();

  static TodoItem toEntityTodoItem(TodoItemDBData dbModel) {
    return TodoItem.fromJson(dbModel.toJson());
  }

  static List<TodoItem> listToEntityTodoItem(List<TodoItemDBData> dbList) {
    return dbList.map((e) => toEntityTodoItem(e)).toList();
  }
}
