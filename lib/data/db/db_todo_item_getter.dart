import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class DbTodoItemGetter {

  DaoDatabase _dao = DaoDatabase();

  int itemId;

  DbTodoItemGetter({
    required this.itemId,
  }){
  }

  int get id => _getId();
  Future<String?> get title => _getTitle();
  Future<String?> get content => _getContent();
  Future<String> get category => _getCategory();
  Future<int> get timerSeconds => _getTimerSeconds();
  Future<int> get stopwatchSeconds => _getStopwatchSeconds();
  Future<bool> get isDone => _getIsDone();
  Future<DateTime?> get targetDateTime => _getTargetDateTime();
  Future<TodoItem?> get todoItem => _getTodoItem();



  int _getId() {
    return itemId;
  }

  Future<TodoItem?> _getTodoItem() async {
    return await _dao.getTodoItem(id: itemId);
  }

  Future<String?> _getTitle() async {
    return (await _dao.getTodoItem(id: itemId))?.title;
  }

  Future<String?> _getContent() async {
    return (await _dao.getTodoItem(id: itemId))?.content;
  }

  Future<String> _getCategory() async {
    return (await _dao.getTodoItem(id: itemId))?.category ?? '';
  }

  Future<int> _getTimerSeconds() async {
    return (await _dao.getTodoItem(id: itemId))?.timerSeconds ?? 0;
  }

  Future<int> _getStopwatchSeconds() async {
    return (await _dao.getTodoItem(id: itemId))?.stopwatchSeconds ?? 0;
  }

  Future<bool> _getIsDone() async {
    return (await _dao.getTodoItem(id: itemId))?.isDone ?? false;
  }

  Future<DateTime?> _getTargetDateTime() async {
    return (await _dao.getTodoItem(id: itemId))?.targetDateTime;
  }


}