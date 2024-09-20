import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import '../../data/tools/tool_show_overlay.dart';
import '../bloc_global/all_item_control_bloc.dart';
import '../screen_action/choose_date_widget.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final DaoDatabase _daoDatabase = DaoDatabase();

  CalendarBloc() : super(CalendarState()) {
    on<SaveEvent>(_onSaveEvent);
    on<SelectDateEvent>(_onSelectDateEvent);
    on<ChangeTodoDateEvent>(_onChangeTodoDateEvent);
    on<DeleteCalendarItemEvent>(_onDeleteCalendarItemEvent);
    on<DoneCalendarItemEvent>(_onDoneCalendarItemEvent);
    on<SetStoryCalendarItemEvent>(_onSetStoryCalendarItemEvent);
  }

  Future<void> _onSaveEvent(SaveEvent event, Emitter<CalendarState> emit) async {
    await _daoDatabase.insertTodoItem(event.todoItem);
    Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
  }

  Future<void> _onSelectDateEvent(SelectDateEvent event, Emitter<CalendarState> emit) async {
    emit(state.copyWith(selectedTodoItem: null, selectedDateTime: event.selectedDateTime));
  }

  Future<void> _onChangeTodoDateEvent(ChangeTodoDateEvent event, Emitter<CalendarState> emit) async {
    DateTime? userInput = await Get.find<ToolShowOverlay>().showUserInputOverlay<DateTime>(
      context: event.context,
      child: ChooseDateWidget(),
    );
    if (userInput != null) {
      await _daoDatabase.insertTodoItem(event.todoItem.copyWith(targetDateTime: userInput));
      Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
    }
  }

  Future<void> _onDeleteCalendarItemEvent(DeleteCalendarItemEvent event, Emitter<CalendarState> emit) async {
    await _daoDatabase.deleteTodoItem(event.todoItem);
    Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
  }

  Future<void> _onDoneCalendarItemEvent(DoneCalendarItemEvent event, Emitter<CalendarState> emit) async {
    final newCategory = event.todoItem.category == EnumTodoCategory.social.name
        ? EnumTodoCategory.history_social.name
        : EnumTodoCategory.history.name;
    await _daoDatabase.insertTodoItem(event.todoItem.copyWith(isDone: true, category: newCategory));
    Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
  }

  Future<void> _onSetStoryCalendarItemEvent(SetStoryCalendarItemEvent event, Emitter<CalendarState> emit) async {
    final newCategory = event.todoItem.category == EnumTodoCategory.social.name
        ? EnumTodoCategory.active.name
        : EnumTodoCategory.social.name;
    await _daoDatabase.insertTodoItem(event.todoItem.copyWith(category: newCategory));
    Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
  }
}

class CalendarState {
  final TodoItem? selectedTodoItem;
  final DateTime? selectedDateTime;

  CalendarState({this.selectedTodoItem, this.selectedDateTime});

  CalendarState copyWith({TodoItem? selectedTodoItem, DateTime? selectedDateTime}) {
    return CalendarState(
      selectedTodoItem: selectedTodoItem ?? this.selectedTodoItem,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
    );
  }
}

abstract class CalendarEvent {}

class SaveEvent extends CalendarEvent {
  final TodoItem todoItem;

  SaveEvent({required this.todoItem});
}

class DeleteCalendarItemEvent extends CalendarEvent {
  final TodoItem todoItem;

  DeleteCalendarItemEvent({required this.todoItem});
}

class DoneCalendarItemEvent extends CalendarEvent {
  final TodoItem todoItem;

  DoneCalendarItemEvent({required this.todoItem});
}

class SetStoryCalendarItemEvent extends CalendarEvent {
  final TodoItem todoItem;

  SetStoryCalendarItemEvent({required this.todoItem});
}

class SelectDateEvent extends CalendarEvent {
  final DateTime selectedDateTime;

  SelectDateEvent({required this.selectedDateTime});
}

class ChangeTodoDateEvent extends CalendarEvent {
  final BuildContext context;
  final TodoItem todoItem;

  ChangeTodoDateEvent({required this.context, required this.todoItem});
}
