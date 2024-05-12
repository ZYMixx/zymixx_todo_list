import 'dart:math';

import 'package:intl/intl.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class ServiceStatisticData {

  static Future<Map<String, List<TodoItem>>> requestWeekStat(List<TodoItem> todoItemList) async {
    List<TodoItem> list = (await GlobalDbDao.getHistoryTodoItem());
    Map<String, List<TodoItem>> weekMap = {};
    for (var todoItem in todoItemList) {
      DateTime date = todoItem.targetDateTime!;
      //DateTime day = DateTime(date.year, date.month, date.day);
      weekMap.putIfAbsent(calculateWeek(date), () => []).add(todoItem);
    }
    return weekMap;

  }
  
  static calculateDateHolder( Map<String, List<TodoItem>> weekMap){
    for (var weekStringKey in weekMap.keys){
      List<TodoItem> itemList = weekMap[weekStringKey]!;
      String weekName = weekStringKey;
      int todoItemCount = itemList.length;
      // int dailyFails = itemList;
      int storyItems;
      int weekScore;

    //  StatisticWeekHolder(weekName: weekName, todoItemCount: todoItemCount, dailyFails: dailyFails, storyItems: storyItems, weekScore: weekScore)
    }
    
  }

  static String calculateWeek(DateTime itemDate){
    DateTime monday = itemDate.subtract(Duration(days: itemDate.weekday - 1));
    DateTime sunday = itemDate.add(Duration(days: DateTime.daysPerWeek - itemDate.weekday));

    DateFormat dateFormat1 = DateFormat('dd', 'ru');
    DateFormat dateFormat2 = DateFormat('dd MMM', 'ru');

    String formattedMonday = dateFormat1.format(monday);
    String formattedSunday = dateFormat2.format(sunday);

    return '$formattedMonday-$formattedSunday';
  }



}

class StatisticWeekHolder{

  String weekName;
  int todoItemCount;
  int dailyFails;
  int storyItems;
  int weekScore;

  StatisticWeekHolder({
    required this.weekName,
    required this.todoItemCount,
    required this.dailyFails,
    required this.storyItems,
    required this.weekScore,
  });
}
