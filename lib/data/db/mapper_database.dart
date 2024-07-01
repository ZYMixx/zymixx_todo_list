import '../../domain/todo_item.dart';
import 'app_database.dart';

class MapperDatabase {
  TodoItemDBData toDBTodoItem(TodoItem todoEntity) {
    return TodoItemDBData.fromJson(todoEntity.toJson());
  }

  List<TodoItemDBData> listToDBTodoItem(List<TodoItem> entityList) =>
      entityList.map((e) => toDBTodoItem(e)).toList();

  TodoItem toEntityTodoItem(TodoItemDBData dbModel) {
    return TodoItem.fromJson(dbModel.toJson());
  }

  List<TodoItem> listToEntityTodoItem(List<TodoItemDBData> dbList) {
    return dbList.map((e) => toEntityTodoItem(e)).toList();
  }
}
