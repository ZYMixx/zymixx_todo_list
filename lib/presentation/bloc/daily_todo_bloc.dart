import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/presentation/App.dart';
import 'package:zymixx_todo_list/presentation/action_screens/create_daily_widget.dart';
import 'package:zymixx_todo_list/presentation/bloc/all_item_control_bloc.dart';

class DailyTodoBloc extends Bloc<DailyTodoEvent, DailyTodoState> {

  final _daoDatabase = DaoDatabase();


  DailyTodoBloc() : super(DailyTodoState()) {
    // on<DailyTodoEvent>((event, emit) {
    //   print('do some thing');
    // });
    on<CompleteDailyEvent>((event, emit) {
      _daoDatabase.editTodoItemById(id: event.itemId, isDone: event.isComplete);
      Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
    });
    on<DeleteDailyEvent>((event, emit) async {
      await _daoDatabase.deleteTodoItemById(itemId: event.itemId);
      Get.find<AllItemControlBloc>().add(LoadDailyItemEvent());
    });
    on<RequestAddNewDailyEvent>((event, emit) async {
      //{'name' : name, 'timer': timer}
      Map<String, dynamic> userInputDataMap = await ToolShowOverlay.showUserInputOverlay(
        context: event._context,
        child: CreateDailyWidget(),
      );
      Get.find<AllItemControlBloc>().add(AddNewDailyItemEvent(name: userInputDataMap['name'], timer: userInputDataMap['timer']));
    });
  }
}

class DailyTodoState {}

class DailyTodoEvent {}

class CompleteDailyEvent extends DailyTodoEvent  {
  bool isComplete;
  int itemId;
// если есть таймер то запускать его
  CompleteDailyEvent({
    required this.isComplete,
    required this.itemId,
  });
}

class DeleteDailyEvent extends DailyTodoEvent  {
  int itemId;
  DeleteDailyEvent({
    required this.itemId,
  });
}

class ShowYesterdayChangeDailyEvent extends DailyTodoEvent  {
  bool showYesterday;

  ShowYesterdayChangeDailyEvent({
    required this.showYesterday,
  });
}

class RequestAddNewDailyEvent extends DailyTodoEvent  {
  BuildContext _context;

  RequestAddNewDailyEvent({
    required BuildContext context,
  }) : _context = context;
}

class ChangeDailyEvent extends DailyTodoEvent  {
  ChangeDailyEvent();
}

