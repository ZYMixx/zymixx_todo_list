import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class ListTodoScreenBloc extends Bloc<ListTodoEvent, ListTodoState>{

  ListTodoScreenBloc() : super(ListTodoState(primaryPositionList: [])) {

    //GlobalDbDao.getAllTodoItemStream().then((value) async {
    //  emit(state.copyWith(primaryPositionList: await state.initPositionList()));
    //});
    GlobalDbDao.broadcastActiveTodoStream.listen((newList) {
        if (newList.isNotEmpty) {
          this.add(NeedUpdateEvent(todoItemList: newList));
        }
      });

    on<NeedUpdateEvent>((event, emit) async {
      Log.i('call ned Update');
      Log.i('event.todoItemList ${event.todoItemList}');
      List<int> tempoPosList = [...state._primaryPositionList];
      for (var item in event.todoItemList){
        if (!tempoPosList.contains(item.id)) {
          tempoPosList.add(item.id);
        }
      }
      tempoPosList.removeWhere((element) => !event.todoItemList.map((e) => e.id).contains(element));
      Log.i('tempoPosList ${tempoPosList}');
      emit(await state.copyWith(primaryPositionList: tempoPosList));
    });
     on<ChangeTodayOnlyModEvent>((event, emit) async {
       emit(await state.copyWith(isShowTodayOnlyMod: event.isShowTodayOnlyMod));
     });

     on<ChangeOrderEvent>((event, emit) async {
       List<int> list = [...?state._primaryPositionList];
       var movedId = list[event.movedItemPos];
       list.removeAt(event.movedItemPos);
       list.insertAll(event.replacedItemPos , [movedId]);
       emit(await state.copyWith(primaryPositionList: list));
     });
  }

  @override
  Future<void> close() async {
  }

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
      var filteredTodoItemList = todoItemList?.where((e) =>
      e.targetDateTime?.isSameDay(DateTime.now()) ?? false).toList() ?? [];
      List<int> remainPosId = filteredTodoItemList.map((e) => e.id).toList();
      secondPosItemList = [..._primaryPositionList];
      return secondPosItemList..removeWhere((element) => !remainPosId.contains(element));
    } else {
      return _primaryPositionList;
    }
  }

  Future<List<int>> initPositionList() async {
    return (await GlobalDbDao.getActiveTodoItem()).map((e) => e.id).toList();
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

class ListTodoEvent{}

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
  int replacedItemPos;
  int movedItemPos;

  ChangeOrderEvent({
    required this.replacedItemPos,
    required this.movedItemPos,
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
  String getStringDate() {
    initializeDateFormatting('ru', null); // Инициализация локали для русского языка
    String month = DateFormat.MMMM('ru').format(this); // Получаем полное название месяца на русском
    String day = DateFormat.d('ru').format(this); // Получаем день месяца на русском
    String dayOfWeek = DateFormat.E('ru').format(this); // Получаем день недели на русском

    return '${month.capStart()} $day, ${dayOfWeek}.';
  }

  bool isSameDay(DateTime date) {
    if (date.day == this.day && date.month == this.month && date.year == this.year) {
      return true;
    } else {
      return false;
    }
  }
}