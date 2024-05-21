import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/presentation/calendar_screen.dart';
import 'package:zymixx_todo_list/presentation/daily_todo_screen.dart';
import 'package:zymixx_todo_list/presentation/history_screen.dart';
import 'package:zymixx_todo_list/presentation/main_todo_list_screen.dart';
import 'package:zymixx_todo_list/presentation/statistic_screen.dart';

class MyBottomNavigatorScreen extends StatefulWidget {
  MyBottomNavigatorScreen({super.key});

  @override
  State<MyBottomNavigatorScreen> createState() => _MyBottomNavigatorScreenState();
}

class _MyBottomNavigatorScreenState extends State<MyBottomNavigatorScreen> {
  List<BottomNavigationBarItem> listNavigatorItem = [
    BottomNavigationBarItem(
        icon: Icon(Icons.work_history_outlined), label: 'work_history_outlined'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'calendar_month'),
    BottomNavigationBarItem(
        icon: Icon(Icons.data_thresholding_outlined), label: 'data_thresholding_outlined'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'history'),
  ];

  List<Widget> listScreens = [
    MainTodoListScreen(),
    CalendarScreen(),
    StatisticScreen(),
    HistoryScreen(),
    DailyTodoScreen(),
  ];

  Color selectedItemColor = Colors.white;
  int selectedItemMenu = 1;
  late Widget activeScreen = listScreens[selectedItemMenu];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedItemMenu,
        onTap: (index) {
          setState(() {
            if (index == 0 && selectedItemMenu == 0) {
              if (activeScreen == listScreens[0]) {
                activeScreen = listScreens[4];
                selectedItemColor = Colors.greenAccent;
              } else {
                selectedItemColor = Colors.white;
                activeScreen = listScreens[0];
              }
            } else {
              selectedItemColor = Colors.white;
              activeScreen = listScreens[index];
            }
            selectedItemMenu = index;
          });
        },
        backgroundColor: Colors.deepPurpleAccent,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 28,
        type: BottomNavigationBarType.fixed,
        items: listNavigatorItem,
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(animation),
            child: child,
          );
        },
        child: activeScreen,
      ),
    );
  }
}
