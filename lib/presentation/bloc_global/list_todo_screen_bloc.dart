import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class ListTodoScreenBloc extends Bloc<ListTodoEvent, ListTodoState> {
  final DaoDatabase _daoDB = DaoDatabase();

  ListTodoScreenBloc() : super(ListTodoState(primaryPositionList: [])) {
    Get.find<GlobalDbDao>().broadcastActiveTodoStream.listen((newList) {
      this.add(NeedUpdateEvent(todoItemList: newList));
    });
    on<NeedUpdateEvent>((event, emit) async {
      Log.i('ListTodoScreenBloc - call ned Update');
      List<int> tempoPosList = [...state._primaryPositionList];
      for (var item in event.todoItemList) {
        if (!tempoPosList.contains(item.id)) {
          tempoPosList.add(item.id);
        }
      }
      tempoPosList.removeWhere((element) => !event.todoItemList.map((e) => e.id).contains(element));
      emit(await state.copyWith(primaryPositionList: tempoPosList));
    });
    on<ChangeTodayOnlyModEvent>((event, emit) async {
      emit(await state.copyWith(isShowTodayOnlyMod: event.isShowTodayOnlyMod));
    });
    on<ChangeOrderEvent>((event, emit) async {
      List<int> list = [...state._primaryPositionList];
      int replacePos = list.indexWhere((element) => element == event.replacedItemId);
      list.removeWhere((element) => element == event.movedItemId);
      list.insertAll(replacePos, [event.movedItemId]);
      emit(await state.copyWith(primaryPositionList: list));
    });
    on<SetSpinWinnerEvent>((event, emit) async {
      await _daoDB.editTodoItemById(id: event.movedItemId, targetDateTime: DateTime.now());
      List<int> list = [...state._primaryPositionList];
      list.remove(event.movedItemId);
      list.insert(0, event.movedItemId);
      emit(await state.copyWith(primaryPositionList: list));
    });
  }

  @override
  Future<void> close() async {}
}

class ListTodoState {
  List<int> _primaryPositionList;
  bool isShowTodayOnlyMod;

  ListTodoState({
    this.isShowTodayOnlyMod = false,
    required List<int> primaryPositionList,
  }) : _primaryPositionList = primaryPositionList;

  List<int> getPositionItemList(List<TodoItem> todoItemList) {
    if (isShowTodayOnlyMod) {
      List<int>? secondPosItemList;
      var filteredTodoItemList = todoItemList
              ?.where((e) => e.targetDateTime?.isSameDay(DateTime.now()) ?? false)
              .toList() ??
          [];
      List<int> remainPosId = filteredTodoItemList.map((e) => e.id).toList();
      secondPosItemList = [..._primaryPositionList];
      var x = secondPosItemList..removeWhere((element) => !remainPosId.contains(element));
      return x;
    } else {
      return _primaryPositionList;
    }
  }

  Future<List<int>> initPositionList() async {
    return (await Get.find<GlobalDbDao>().getActiveTodoItem()).map((e) => e.id).toList();
  }

  ListTodoState copyWith({
    List<int>? primaryPositionList,
    bool? isShowTodayOnlyMod,
  }) {
    return ListTodoState(
      primaryPositionList: primaryPositionList ?? this._primaryPositionList,
      isShowTodayOnlyMod: isShowTodayOnlyMod ?? this.isShowTodayOnlyMod,
    );
  }
}

class ListTodoEvent {}

class NeedUpdateEvent extends ListTodoEvent {
  List<TodoItem> todoItemList;

  NeedUpdateEvent({
    required this.todoItemList,
  });
}

class ChangeTodayOnlyModEvent extends ListTodoEvent {
  bool isShowTodayOnlyMod;

  ChangeTodayOnlyModEvent(
    this.isShowTodayOnlyMod,
  );
}

class ChangeOrderEvent extends ListTodoEvent {
  int replacedItemId;
  int movedItemId;

  ChangeOrderEvent({
    required this.replacedItemId,
    required this.movedItemId,
  });
}

class SetSpinWinnerEvent extends ListTodoEvent {
  int movedItemId;

  SetSpinWinnerEvent({
    required this.movedItemId,
  });
}

//grp extension
extension StringExtension on String {
  String capStart() {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }

}


extension DateTimeExtension on DateTime {
  bool isSameDay(DateTime date) {
    if (date.day == this.day && date.month == this.month && date.year == this.year) {
      return true;
    } else {
      return false;
    }
  }
}