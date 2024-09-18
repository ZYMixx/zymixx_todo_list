import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zymixx_todo_list/data/db/global_db_dao.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/bloc_global/all_item_control_bloc.dart';

class ServiceStatisticData {
  String weekKey = 'week_data';
  String dayKey = 'day_data';

  Future<Map<String, dynamic>> requestData() async {
    List<TodoItem> todoItemList = (await Get.find<GlobalDbDao>().getAllTodoItem());
    todoItemList.sort((a, b) => b.targetDateTime!.compareTo(a.targetDateTime!));
    return {
      weekKey: await _requestWeekStat(todoItemList),
      dayKey: await _requestDaysStat(todoItemList)
    };
  }

  Future<List<StatisticWeekHolder>> _requestWeekStat(List<TodoItem> todoItemList) async {
    Map<String, List<TodoItem>> weekMap = {};
    var now = DateTime.now();
    for (var todoItem in todoItemList) {
      DateTime date = todoItem.targetDateTime!;
      if (date.isAfter(now)) {
        continue;
      }
      weekMap.putIfAbsent(_calculateWeek(date), () => []).add(todoItem);
    }
    return _calculateWeekDateHolder(weekMap);
  }

  Future<List<StatisticDayHolder>> _requestDaysStat(List<TodoItem> todoItemList) async {
    Map<String, List<TodoItem>> dayMap = {};
    Map<String, bool> mondayMap = {};
    var now = DateTime.now();

    for (var todoItem in todoItemList) {
      DateTime date = todoItem.targetDateTime!;
      if (date.isAfter(now)) {
        continue;
      }
      dayMap.putIfAbsent(_calculateDayName(date), () => []).add(todoItem);
      mondayMap.putIfAbsent(_calculateDayName(date), () => date.weekday == 1);
    }
    return _calculateDaysDateHolder(dayMap, mondayMap);
  }

  int _storyCost = 60 * 60;
  int _dailyPenalty = 15 * 60;
  int _todoIndividualPrise = 5 * 60;
  int _todoIndividualSinglePrise = 3 * 60;

  List<StatisticWeekHolder> _calculateWeekDateHolder(Map<String, List<TodoItem>> weekMap) {
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
        int? prise;
        try {
          dynamic data = jsonDecode(item.content);
          if (data is Map<String, dynamic> && data.containsKey('prise')) {
            prise = data['prise'];
          }
        } catch (e) {}
        if (item.category == EnumTodoCategory.daily.name &&
            !item.targetDateTime!.isSameDay(today) &&
            item.isDone == false) {
          dailyFails++;
          weekScore -= _dailyPenalty;
        }
        // дэйлики с наградой
        if (item.category == EnumTodoCategory.daily.name && item.isDone == true && prise != null) {
          weekScore += (prise) * 60;
        }
        if (item.category == EnumTodoCategory.history_social.name) {
          storyItems++;
          weekScore += _storyCost;
        }
        if (item.category == EnumTodoCategory.history.name) {
          todoItemCount++;
          weekScore += item.secondsSpent;
          weekScore += _todoIndividualPrise;
          if (item.secondsSpent < 60) {
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

  List<StatisticDayHolder> _calculateDaysDateHolder(
      Map<String, List<TodoItem>> dayMap, Map<String, bool> mondayMap) {
    List<StatisticDayHolder> statisticDayHolderList = [];
    for (var dayStringKey in dayMap.keys) {
      List<TodoItem> itemList = dayMap[dayStringKey]!;
      String dayName = dayStringKey;
      int dayScore = 0;
      DateTime today = DateTime.now();
      late DateTime itemDay;
      for (var item in itemList) {
        int? prise;
        itemDay = item.targetDateTime!;
        try {
          dynamic data = jsonDecode(item.content);
          if (data is Map<String, dynamic> && data.containsKey('prise')) {
            prise = data['prise'];
          }
        } catch (e) {}
        if (item.category == EnumTodoCategory.daily.name &&
            !itemDay!.isSameDay(today) &&
            item.isDone == false) {
          dayScore -= _dailyPenalty;
        }
        // дэйлики с наградой
        if (item.category == EnumTodoCategory.daily.name && item.isDone == true && prise != null) {
          dayScore += prise * 60;
        }
        if (item.category == EnumTodoCategory.history_social.name) {
          dayScore += _storyCost;
        }
        if (item.category == EnumTodoCategory.history.name) {
          dayScore += item.secondsSpent;
          dayScore += _todoIndividualPrise;
          if (item.secondsSpent < 60) {
            dayScore += _todoIndividualSinglePrise;
          }
        }
      }
      String scoreString = (dayScore / 3600).toStringAsFixed(1);
      double finalDayScore = double.parse(scoreString);
      statisticDayHolderList.add(
        StatisticDayHolder(
            dayName: dayName,
            dayScore: finalDayScore,
            isMonday: mondayMap[dayName]!,
            dateTime: itemDay),
      );
    }
    return statisticDayHolderList;
  }

  String _calculateWeek(DateTime itemDate) {
    DateTime monday = itemDate.subtract(Duration(days: itemDate.weekday - 1));
    DateTime sunday = itemDate.add(Duration(days: DateTime.daysPerWeek - itemDate.weekday));

    DateFormat dateFormat1 = DateFormat('dd', 'ru');
    DateFormat dateFormat2 = DateFormat('dd MMM', 'ru');

    String formattedMonday = dateFormat1.format(monday);
    String formattedSunday = dateFormat2.format(sunday);
    return '$formattedMonday-$formattedSunday';
  }

  String _calculateDayName(DateTime itemDate) {
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
  bool isMonday;
  DateTime dateTime;

  StatisticDayHolder({
    required this.dayName,
    required this.dayScore,
    required this.isMonday,
    required this.dateTime,
  });
}
