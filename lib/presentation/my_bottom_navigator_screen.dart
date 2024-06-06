import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zymixx_todo_list/data/services/service_window_manager.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/calendar_screen.dart';
import 'package:zymixx_todo_list/presentation/daily_todo_screen.dart';
import 'package:zymixx_todo_list/presentation/fortune_wheel_screen.dart';
import 'package:zymixx_todo_list/presentation/history_screen.dart';
import 'package:zymixx_todo_list/presentation/main_todo_list_screen.dart';
import 'package:zymixx_todo_list/presentation/statistic_screen.dart';

class MyBottomNavigatorScreen extends StatelessWidget {
  const MyBottomNavigatorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.0),
      child: Container(
        padding: EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 15.0,
              spreadRadius: 3.0,
              offset: Offset(5, 3),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.only(top: 5, left: 5, right: 4, bottom: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(14)),
            image: DecorationImage(
              image: AssetImage('assets/metal_frame.jpg'),
              repeat: ImageRepeat.repeatY,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 30.0,
                spreadRadius: 3.0,
                offset: Offset(7, 5),
              ),
            ],
          ),
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: MyBottomNavigatorWidget(),
            ),
          ),
        ),
      ),
    );
  }
}

class MyBottomNavigatorWidget extends StatefulWidget {
  const MyBottomNavigatorWidget({super.key});

  @override
  State<MyBottomNavigatorWidget> createState() => _MyBottomNavigatorWidgetState();
}

class _MyBottomNavigatorWidgetState extends State<MyBottomNavigatorWidget> {
  List<BottomNavigationBarItem> listNavigatorItem = [
    BottomNavigationBarItem(
        icon: Icon(Icons.work_history_outlined), label: 'work_history_outlined'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'calendar_month'),
    BottomNavigationBarItem(
        icon: Icon(Icons.data_thresholding_outlined), label: 'data_thresholding_outlined'),
    BottomNavigationBarItem(
        icon: InkWell(
          onSecondaryTap: (){
            ServiceWindowManager.onHideWindowPressed();
          },
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Center(
            child: SizedBox(
              height: 40,
              child: MoveWindow(
                onDoubleTap: () => windowManager.close(),
                child: Icon(Icons.history),
              ),
            ),
          ),
        ),
        label: 'history'), //последний элемент отвечает за движение/закрытие окна
  ];

  List<Widget> listScreens = [
    MainTodoListScreen(),
    CalendarScreen(),
    StatisticScreen(),
    HistoryScreen(),
    DailyTodoScreen(),
    FortuneWheelScreen(),
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
            if (index == selectedItemMenu && listScreens.length >= index + 5) {
              if (selectedItemColor != Colors.greenAccent) {
                activeScreen = listScreens[index + 4];
                selectedItemColor = Colors.greenAccent;
              } else {
                selectedItemColor = Colors.white;
                activeScreen = listScreens[index];
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
