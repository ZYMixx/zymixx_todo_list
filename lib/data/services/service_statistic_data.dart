import 'dart:math';

import 'package:intl/intl.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class ServiceStatisticData {
  static String weekKey = 'week_data';
  static String dayKey = 'day_data';

  static Future<Map<String, dynamic>> requestData() async {
    return {weekKey: await _requestWeekStat(), dayKey: await _requestDaysStat()};
  }

  static Future<List<StatisticWeekHolder>> _requestWeekStat() async {
    List<TodoItem> todoItemList = (await GlobalDbDao.getAllTodoItem());
    Map<String, List<TodoItem>> weekMap = {};
    for (var todoItem in todoItemList) {
      DateTime date = todoItem.targetDateTime!;
      weekMap.putIfAbsent(_calculateWeek(date), () => []).add(todoItem);
    }
    return _calculateWeekDateHolder(weekMap);
  }

  static Future<List<StatisticDayHolder>> _requestDaysStat() async {
    List<TodoItem> todoItemList = (await GlobalDbDao.getAllTodoItem());
    Map<String, List<TodoItem>> dayMap = {};
    for (var todoItem in todoItemList) {
      DateTime date = todoItem.targetDateTime!;
      dayMap.putIfAbsent(_calculateDayName(date), () => []).add(todoItem);
    }
    return _calculateDaysDateHolder(dayMap);
  }

  static int _storyCost = 30 * 60;
  static int _dailyPenalty = 15 * 60;
  static int _todoIndividualPrise = 4 * 60;
  static int _todoIndividualSinglePrise = 2 * 60;

  static List<StatisticWeekHolder> _calculateWeekDateHolder(Map<String, List<TodoItem>> weekMap) {
    List<StatisticWeekHolder> statisticHolderList = [];
    for (var weekStringKey in weekMap.keys) {
      List<TodoItem> itemList = weekMap[weekStringKey]!;
      String weekName = weekStringKey;
      int todoItemCount = 0;
      int dailyFails = 0;
      int storyItems = 0;
      int weekScore = 0;
      DateTime today = DateTime.now();
      for (var item in itemList) {
        if (item.category == EnumTodoCategory.daily.name &&
            !item.targetDateTime!.isSameDay(today) &&
            item.isDone == false) {
          dailyFails++;
          weekScore -= _dailyPenalty;
        }
        // дэйлики с наградой
        if (item.category == EnumTodoCategory.daily.name &&
            item.isDone == true &&
            item.content != '') {
          weekScore += (int.tryParse(item.content) ?? 0) * 60;
        }
        if (item.category == EnumTodoCategory.history_social.name) {
          storyItems++;
          weekScore += _storyCost;
        }
        if (item.category == EnumTodoCategory.history.name) {
          todoItemCount++;
          weekScore += item.secondsSpent;
          weekScore += _todoIndividualPrise;
          if (item.secondsSpent < 60){
            weekScore += _todoIndividualSinglePrise;
          }
        }
      }
      String scoreString = (weekScore / 3600).toStringAsFixed(1);
      double finalWeekScore = double.parse(scoreString);
      statisticHolderList.add(
        StatisticWeekHolder(
            weekName: weekName,
            todoItemCount: todoItemCount,
            dailyFails: dailyFails,
            storyItems: storyItems,
            weekScore: finalWeekScore),
      );
    }
    return statisticHolderList;
  }

  static List<StatisticDayHolder> _calculateDaysDateHolder(Map<String, List<TodoItem>> dayMap) {
    List<StatisticDayHolder> statisticDayHolderList = [];
    for (var dayStringKey in dayMap.keys) {
      List<TodoItem> itemList = dayMap[dayStringKey]!;
      String dayName = dayStringKey;
      int dayScore = 0;
      DateTime today = DateTime.now();
      for (var item in itemList) {
        if (item.category == EnumTodoCategory.daily.name &&
            !item.targetDateTime!.isSameDay(today) &&
            item.isDone == false) {
          //dayScore -= _dailyPenalty;
        }
        // дэйлики с наградой
        if (item.category == EnumTodoCategory.daily.name &&
            item.isDone == true &&
            item.content != '') {
          dayScore += (int.tryParse(item.content) ?? 0) * 60;
        }
        if (item.category == EnumTodoCategory.history_social.name) {
          dayScore += _storyCost;
        }
        if (item.category == EnumTodoCategory.history.name) {
          dayScore += item.secondsSpent;
          dayScore += _todoIndividualPrise;
          if (item.secondsSpent < 60){
            dayScore += _todoIndividualSinglePrise;
          }
        }
      }
      String scoreString = (dayScore / 3600).toStringAsFixed(1);
      double finalDayScore = double.parse(scoreString);
      statisticDayHolderList.add(
        StatisticDayHolder(dayName: dayName, dayScore: finalDayScore),
      );
    }
    return statisticDayHolderList;
  }

  static String _calculateWeek(DateTime itemDate) {
    DateTime monday = itemDate.subtract(Duration(days: itemDate.weekday - 1));
    DateTime sunday = itemDate.add(Duration(days: DateTime.daysPerWeek - itemDate.weekday));

    DateFormat dateFormat1 = DateFormat('dd', 'ru');
    DateFormat dateFormat2 = DateFormat('dd MMM', 'ru');

    String formattedMonday = dateFormat1.format(monday);
    String formattedSunday = dateFormat2.format(sunday);
    return '$formattedMonday-$formattedSunday';
  }

  static String _calculateDayName(DateTime itemDate) {
    DateFormat dateFormat = DateFormat('dd MMM', 'ru');
    String formattedMonday = dateFormat.format(itemDate);
    return '$formattedMonday';
  }
}

class StatisticWeekHolder {
  String weekName;
  int todoItemCount;
  int dailyFails;
  int storyItems;
  double weekScore;

  StatisticWeekHolder({
    required this.weekName,
    required this.todoItemCount,
    required this.dailyFails,
    required this.storyItems,
    required this.weekScore,
  });
}

class StatisticDayHolder {
  String dayName;
  double dayScore;

  StatisticDayHolder({
    required this.dayName,
    required this.dayScore,
  });
}

//grp Ext

extension HilightData on DateTime {
  bool isSameDay(DateTime date) {
    if (date.day == this.day && date.month == this.month && date.year == this.year) {
      return true;
    } else {
      return false;
    }
  }
}
