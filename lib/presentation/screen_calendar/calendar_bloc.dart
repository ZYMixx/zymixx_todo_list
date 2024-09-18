import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/db/dao_database.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_show_overlay.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

import '../bloc_global/all_item_control_bloc.dart';
import '../screen_action/choose_date_widget.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final _daoDatabase = DaoDatabase();

  CalendarBloc() : super(CalendarState()) {
    on<SaveEvent>((event, emit) {
      _onSaveEvent(event, emit);
    });
    on<SelectDateEvent>((event, emit) {
      _onSelectDateEvent(event, emit);
    });
    on<ChangeTodoDateEvent>((event, emit) {
      _onChangeTodoDateEvent(event, emit);
    });
    on<DeleteCalendarItemEvent>((event, emit) async {
      await _daoDatabase.deleteTodoItem(event.todoItem);
      Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
    });
    on<DoneCalendarItemEvent>((event, emit) async {
      if (event.todoItem.category == EnumTodoCategory.social.name) {
        await _daoDatabase.insertTodoItem(
            event.todoItem.copyWith(isDone: true, category: EnumTodoCategory.history_social.name));
      } else {
        await _daoDatabase.insertTodoItem(
            event.todoItem.copyWith(isDone: true, category: EnumTodoCategory.history.name));
      }
      Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
    });
    on<SetStoryCalendarItemEvent>((event, emit) async {
      if (event.todoItem.category == EnumTodoCategory.social.name) {
        await _daoDatabase.insertTodoItem(event.todoItem..category = EnumTodoCategory.active.name);
      } else {
        await _daoDatabase.insertTodoItem(event.todoItem..category = EnumTodoCategory.social.name);
      }
      Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
    });
  }

  Future<void> _onSaveEvent(SaveEvent event, Emitter<CalendarState> emit) async {
    await _daoDatabase.insertTodoItem(event.todoItem);
    Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
  }

  Future<void> _onSelectDateEvent(SelectDateEvent event, Emitter<CalendarState> emit) async {
    Log.d('bloc info ${event.selectedDateTime}');
    emit(state.copyWith(selectedTodoItem: null, selectedDateTime: event.selectedDateTime));
  }

  Future<void> _onChangeTodoDateEvent(
      ChangeTodoDateEvent event, Emitter<CalendarState> emit) async {
    {
      DateTime? userInput = await Get.find<ToolShowOverlay>().showUserInputOverlay<DateTime>(
        context: event._context,
        child: ChooseDateWidget(),
      );
      if (userInput != null) {
        await _daoDatabase.insertTodoItem(event.todoItem..targetDateTime = userInput!);
        Get.find<AllItemControlBloc>().add(LoadAllItemEvent());
      }
    }
  }
}

class CalendarState {
  TodoItem? selectedTodoItem;
  DateTime? selectedDateTime;

  CalendarState({
    this.selectedTodoItem,
    this.selectedDateTime,
  });

  CalendarState copyWith({
    TodoItem? selectedTodoItem,
    DateTime? selectedDateTime,
  }) {
    return CalendarState(
      selectedTodoItem: selectedTodoItem ?? this.selectedTodoItem,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
    );
  }
}

class CalendarEvent {}

class SaveEvent extends CalendarEvent {
  TodoItem todoItem;

  SaveEvent({
    required this.todoItem,
  });
}

class DeleteCalendarItemEvent extends CalendarEvent {
  TodoItem todoItem;

  DeleteCalendarItemEvent({
    required this.todoItem,
  });
}

class DoneCalendarItemEvent extends CalendarEvent {
  TodoItem todoItem;

  DoneCalendarItemEvent({
    required this.todoItem,
  });
}

class SetStoryCalendarItemEvent extends CalendarEvent {
  TodoItem todoItem;

  SetStoryCalendarItemEvent({
    required this.todoItem,
  });
}

class SelectDateEvent extends CalendarEvent {
  DateTime selectedDateTime;

  SelectDateEvent({
    required this.selectedDateTime,
  });
}

class ChangeTodoDateEvent extends CalendarEvent {
  BuildContext _context;
  TodoItem todoItem;

  ChangeTodoDateEvent({
    required BuildContext context,
    required this.todoItem,
  }) : _context = context;
}
