import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/presentation/calendar_screen.dart';
import 'package:zymixx_todo_list/presentation/daily_todo_screen.dart';
import 'package:zymixx_todo_list/presentation/main_todo_list_screen.dart';

class MyBottomNavigatorScreen extends StatefulWidget {
  MyBottomNavigatorScreen({super.key});

  @override
  State<MyBottomNavigatorScreen> createState() => _MyBottomNavigatorScreenState();
}

class _MyBottomNavigatorScreenState extends State<MyBottomNavigatorScreen> {
  List<BottomNavigationBarItem> listNavigatorItem = [
    BottomNavigationBarItem(icon: Icon(Icons.work_history_outlined), label: 'test'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: '1'),
    BottomNavigationBarItem(icon: Icon(Icons.data_thresholding_outlined), label: '2'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: '3'),
  ];

  List<Widget> listScreens = [
    MainTodoListScreen(),
    CalendarScreen(),
    FlutterLogo(  ),
    Center(child: FlutterLogo(  )),
    DailyTodoScreen(),
  ];

  Color selectedItemColor = Colors.white;
  int selectedItemMenu = 1;

  late Widget activeScreen = listScreens[selectedItemMenu];

  dynamic testKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedItemMenu,
        onTap: (index) {
          setState(() {
            if (index == 0 && selectedItemMenu == 0){
              if (activeScreen == listScreens[0]){
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
        // Скрыть метки для выбранных элементов
        showUnselectedLabels: false,
        selectedFontSize: 0,
        // Размер шрифта для выбранных элементов
        unselectedFontSize: 0,
        // Размер шрифта для невыбранных элементов
        iconSize: 28,
        // Размер иконок на элементах навигации
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
