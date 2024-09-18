import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zymixx_todo_list/data/flame/hover_observer.dart';
import 'package:zymixx_todo_list/data/flame/wall_bg_flame_widget.dart';
import 'package:zymixx_todo_list/data/services/service_window_manager.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/presentation/app.dart';
import 'package:zymixx_todo_list/presentation/my_widgets/my_animated_card.dart';

import '../black_box_screen/black_box_screen.dart';
import '../calendar_screen/calendar_screen.dart';
import '../daily_todo_screen/daily_todo_screen.dart';
import '../fortune_wheel_screen/fortune_wheel_screen.dart';
import '../history_screen/history_screen.dart';
import '../main_todo_list_screen/main_todo_list_screen.dart';
import '../statistic_screen/statistic_screen.dart';

class MyBottomNavigatorScreen extends StatelessWidget {
  const MyBottomNavigatorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MyScreenBoxDecorationWidget(child: MyBottomNavigatorWidget());
  }
}

class MyScreenBoxDecorationWidget extends StatelessWidget {
  final Widget child;

  MyScreenBoxDecorationWidget({super.key, required this.child});


  void _updateCursorPosition(PointerHoverEvent event) {
    Get.find<CursorPositionService>().updateCursorPosition(event);
  }


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
          child: Listener(
            onPointerHover: _updateCursorPosition,
            child: Stack(
              children: [
                DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.0),
                    child: child,
                  ),
                ),
                // WallBgFlameWidget(),
              ],
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
        icon: MyAnimatedCard(
          intensity: 0.007,
          child: GestureDetector(
            onSecondaryTap: () async => App.changeAppWorkMod(),
            child: Center(child: Icon(Icons.work_history_outlined)),
          ),
        ),
        label: 'work_history_outlined'),
    BottomNavigationBarItem(
        icon: MyAnimatedCard(
            intensity: 0.007,
            child: GestureDetector(
                onSecondaryTap: () async =>
                    Get.find<ServiceWindowManager>().changeAppPosition(true),
                child: Center(child: Icon(Icons.calendar_month)))),
        label: 'calendar_month'),
    BottomNavigationBarItem(
        icon: MyAnimatedCard(
            intensity: 0.007,
            child: GestureDetector(
                onSecondaryTap: () async =>
                    Get.find<ServiceWindowManager>().changeAppPosition(false),
                child: Center(child: Icon(Icons.data_thresholding_outlined)))),
        label: 'data_thresholding_outlined'),
    BottomNavigationBarItem(
        icon: GestureDetector(
          onSecondaryTap: () {
            Get.find<ServiceWindowManager>().onHideWindowPressed();
          },
          child: MyAnimatedCard(
            intensity: 0.007,
            child: Center(
              child: SizedBox(
                height: 40,
                child: MoveWindow(
                  onDoubleTap: windowManager.close,
                  child: Container(
                    width: 80,
                    child: Icon(Icons.history),
                  ),
                ),
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
    BlackBoxScreen(),
  ];

  Color selectedItemColor = Colors.white;
  int selectedItemMenu = 1;
  late Widget activeScreen = listScreens[selectedItemMenu];



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 300,
          height: 500,
          child: ColoredBox(color: Colors.red),
        ),
        MyDefBgDecoration(
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: selectedItemMenu,
                onTap: (index) {
                  setState(() {
                    if (index == selectedItemMenu && listScreens.length >= index + 5) {
                      if (selectedItemColor != ToolThemeData.highlightGreenColor) {
                        activeScreen = listScreens[index + 4];
                        selectedItemColor = ToolThemeData.highlightGreenColor;
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
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Get.find<WallBgFlameWidget>().gameBounce.applyRandomMove();
                  });
                },
                backgroundColor: Colors.deepPurpleAccent,
                selectedItemColor: selectedItemColor,
                unselectedItemColor: Colors.black,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedIconTheme: IconThemeData(size: 31, shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1.0, 1.60),
                    blurRadius: 0.6,
                  ),
                ]),
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
                    alwaysIncludeSemantics: false,
                    opacity: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: activeScreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
