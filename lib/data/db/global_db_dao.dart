import 'dart:async';

import 'package:drift/drift.dart';
import 'package:zymixx_todo_list/data/db/app_database.dart';
import 'package:zymixx_todo_list/data/db/mapper_database.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

// делать разбивку на streamController для разных событий

class GlobalDbDao{
  static AppDatabase get _db => AppDatabase.instance;
  static  Stream<List<TodoItem>> get broadcastActiveTodoStream => _broadcastActiveTodoStream ??= initActiveStream();
  static  Stream<List<TodoItem>>? _broadcastActiveTodoStream;

  //static  Stream<List<TodoItem>> get broadcastDailyTodoStream => _broadcastDailyTodoStream ??= initDailyStream();
  //static  Stream<List<TodoItem>>? _broadcastDailyTodoStream;

  static Stream<List<TodoItem>> initActiveStream(){
    int? lastUpdateTodoItemListSize;

    // final query = (_db.select(_db.todoItemDB)..where((tbl) => ((tbl.category.equals(EnumTodoCategory.active.name)) | (tbl.category.equals(EnumTodoCategory.social.name))))).watch();;
    final query = (_db.select(_db.todoItemDB)
      ..where((tbl) =>
      tbl.category.equals(EnumTodoCategory.active.name) |
      tbl.category.equals(EnumTodoCategory.social.name)
      )).watch();
    final streamController = StreamController<List<TodoItem>>();
    query.listen((data) {
      if ( lastUpdateTodoItemListSize == null || lastUpdateTodoItemListSize != data.length ) {
        List<TodoItem> mappedList = MapperDatabase.listToEntityTodoItem(data);
        streamController.add(mappedList);
        lastUpdateTodoItemListSize =  mappedList.length;
      }
    });
    return streamController.stream.asBroadcastStream();
  }

  // static Stream<List<TodoItem>> initDailyStream(){
  //   List<TodoItem> dailyList = [];
  //   final query = (_db.select(_db.todoItemDB)..where((tbl) => tbl.category.equals(EnumTodoCategory.daily.name))).watch();;
  //   final streamController = StreamController<List<TodoItem>>();
  //   query.listen((data) {
  //     Log.i('DAILY EVENT');
  //     List<TodoItem> mappedList = MapperDatabase.listToEntityTodoItem(data);
  //     bool needUpdate = false;
  //     if (dailyList.length != mappedList.length){
  //       needUpdate = true
  //     } else {
  //       for (var i = 0; i < dailyList.length; i++) {
  //
  //       }
  //     }
  //     if (  ) {
  //       streamController.add(mappedList);
  //       lastUpdateTodoItemListSize =  mappedList.length;
  //     }
  //   });
  //   return streamController.stream.asBroadcastStream();
  // }

  static Future<List<TodoItem>> getActiveTodoItem() async =>
      MapperDatabase.listToEntityTodoItem(await (_db.select(_db.todoItemDB)..where((tbl) =>
      tbl.category.equals(EnumTodoCategory.active.name) |
      tbl.category.equals(EnumTodoCategory.social.name)
      )).get());


  // Future<List<TodoItem>> getDailyTodoItem() async =>
  //     MapperDatabase.listToEntityTodoItem(await (_db.select(_db.todoItemDB)..where((tbl) => tbl.category.equals(EnumTodoCategory.active.name))).get());

// static Future<Stream<List<TodoItem>>> getAllTodoItemStream() async {
  //   final query = _db.select(_db.todoItemDB).watch();
  //   final streamController = StreamController<List<TodoItem>>();
  //   int? lastUpdateTodoItemListSize;
  //   final subscription = query.listen((data) {
  //     List<TodoItem> mappedList = MapperDatabase.listToEntityTodoItem(data);
  //     if ( lastUpdateTodoItemListSize == null || lastUpdateTodoItemListSize != mappedList.length ) {
  //       streamController.add(mappedList);
  //       lastUpdateTodoItemListSize =  mappedList.length;
  //     }
  //   });
  //   streamController.onCancel = () {
  //    subscription.cancel();
  //   };
  //   return streamController.stream;
  // }
}