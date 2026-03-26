import 'dart:ui';

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
import '../app_widgets/my_animated_card.dart';
import '../screen_black_box/black_box_screen.dart';
import '../screen_calendar/calendar_screen.dart';
import '../screen_daily_todo/daily_todo_screen.dart';
import '../screen_fortune_wheel/fortune_wheel_screen.dart';
import '../screen_history/history_screen.dart';
import '../screen_main_todo_list/main_todo_list_screen.dart';
import '../screen_statistic/statistic_screen.dart';

class MyBottomNavigatorScreen extends StatelessWidget {
  const MyBottomNavigatorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isDesktop) {
      return MyScreenBoxDecorationWidget(
          child: Get.find<MyBottomNavigatorWidget>());
    }
    return CursorPointerListenerWidget(child: Get.find<MyBottomNavigatorWidget>());
  }
}

class CursorPointerListenerWidget extends StatelessWidget {
  final Widget child;

  const CursorPointerListenerWidget({super.key, required this.child});

  void _updateCursorPosition(Offset position) {
    Get.find<CursorPositionService>().updateCursorPosition(position);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerHover: (event) => _updateCursorPosition(event.position),
      onPointerDown: (event) => _updateCursorPosition(event.position),
      onPointerMove: (event) => _updateCursorPosition(event.position),
      child: child,
    );
  }
}

class MyScreenBoxDecorationWidget extends StatelessWidget {
  final Widget child;

  MyScreenBoxDecorationWidget({super.key, required this.child});

  void _updateCursorPosition(Offset position) {
    Get.find<CursorPositionService>().updateCursorPosition(position);
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
            behavior: HitTestBehavior.opaque,
            onPointerHover: (event) => _updateCursorPosition(event.position),
            onPointerDown: (event) => _updateCursorPosition(event.position),
            onPointerMove: (event) => _updateCursorPosition(event.position),
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
  MyBottomNavigatorWidget({super.key});

  late _MyBottomNavigatorWidgetState state;

  @override
  State<MyBottomNavigatorWidget> createState() {
    state = _MyBottomNavigatorWidgetState();
    return state;
  }
}

class EdgeHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  final double edgeWidth;
  final double screenWidth;

  EdgeHorizontalDragGestureRecognizer({
    required this.edgeWidth,
    required this.screenWidth,
  });

  @override
  bool isPointerAllowed(PointerEvent event) {
    if (event is PointerDownEvent) {
      final double dx = event.position.dx;
      final bool isEdge = dx <= edgeWidth || dx >= (screenWidth - edgeWidth);
      if (!isEdge) return false;
    }
    return super.isPointerAllowed(event);
  }
}

class _MyBottomNavigatorWidgetState extends State<MyBottomNavigatorWidget> {
  List<BottomNavigationBarItem> listNavigatorItem = [
    BottomNavigationBarItem(
        icon: MyAnimatedCard(
          intensity: 0.007,
          child: GestureDetector(
            onSecondaryTap: () async {
              if (GetPlatform.isDesktop) App.changeAppWorkMod();
            },
            child: Center(child: Icon(Icons.work_history_outlined)),
          ),
        ),
        label: 'work_history_outlined'),
    BottomNavigationBarItem(
        icon: MyAnimatedCard(
            intensity: 0.007,
            child: GestureDetector(
                onSecondaryTap: () async {
                  if (GetPlatform.isDesktop) {
                    Get.find<ServiceWindowManager>().changeAppPosition(true);
                  }
                },
                child: Center(child: Icon(Icons.calendar_month)))),
        label: 'calendar_month'),
    BottomNavigationBarItem(
        icon: MyAnimatedCard(
            intensity: 0.007,
            child: GestureDetector(
                onSecondaryTap: () async {
                  if (GetPlatform.isDesktop) {
                    Get.find<ServiceWindowManager>().changeAppPosition(false);
                  }
                },
                child: Center(child: Icon(Icons.data_thresholding_outlined)))),
        label: 'data_thresholding_outlined'),
    BottomNavigationBarItem(
        icon: GestureDetector(
          onSecondaryTap: () {
            if (GetPlatform.isDesktop) {
              Get.find<ServiceWindowManager>().onHideWindowPressed();
            }
          },
          child: MyAnimatedCard(
            intensity: 0.007,
            child: Center(
              child: SizedBox(
                height: 40,
                child: GetPlatform.isDesktop
                    ? MoveWindow(
                        onDoubleTap: () {
                          if (GetPlatform.isDesktop) windowManager.close();
                        },
                        child: Container(
                          width: 80,
                          child: Icon(Icons.history),
                        ),
                      )
                    : Container(
                        width: 80,
                        child: Icon(Icons.history),
                      ),
              ),
            ),
          ),
        ),
        label: 'history'),
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

  int selectedItemMenu = 1;
  final List<bool> _altModeByTab = [false, false, false, false];
  bool _slideFromRight = true;
  bool _isFadeOnly = false;

  int get _currentPageIndex {
    if (selectedItemMenu <= 2 && _altModeByTab[selectedItemMenu]) {
      return selectedItemMenu + 4;
    }
    return selectedItemMenu;
  }

  Widget get activeScreen => listScreens[_currentPageIndex];

  void setSelectedTab(int index) {
    if (index < 0 || index > 3) return;
    _setTabFromTap(index);
  }

  void _setTabFromTap(int index) {
    setState(() {
      if (index == selectedItemMenu &&
          index <= 2 &&
          listScreens.length >= index + 5) {
        _altModeByTab[index] = !_altModeByTab[index];
        _isFadeOnly = true;
      } else {
        _slideFromRight = index > selectedItemMenu;
        _isFadeOnly = false;
        selectedItemMenu = index;
      }
    });
  }

  void _setTabFromSwipe(int newIndex) {
    if (newIndex < 0 || newIndex > 3) return;
    setState(() {
      _slideFromRight = newIndex > selectedItemMenu;
      _isFadeOnly = false;
      selectedItemMenu = newIndex;
    });
  }

  Color get _currentSelectedItemColor {
    final bool isAlt = selectedItemMenu <= 2 && _altModeByTab[selectedItemMenu];
    return isAlt ? ToolThemeData.highlightGreenColor : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double edgeWidth = 44;
    return MyDefBgDecoration(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: SafeArea(
          bottom: true,
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: selectedItemMenu,
                    onTap: (index) {
                      _setTabFromTap(index);
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        Get.find<WallBgFlameWidget>()
                            .gameBounce
                            .applyRandomMove();
                      });
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: _currentSelectedItemColor,
                    unselectedItemColor: Colors.white70,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    selectedIconTheme: const IconThemeData(
                      size: 31,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1.0, 1.60),
                          blurRadius: 0.6,
                        ),
                      ],
                    ),
                    selectedFontSize: 0,
                    unselectedFontSize: 0,
                    iconSize: 28,
                    type: BottomNavigationBarType.fixed,
                    items: listNavigatorItem,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: true,
          bottom: false,
          child: selectedItemMenu == 0
              ? AnimatedSwitcher(
                  duration: _isFadeOnly
                      ? const Duration(milliseconds: 75)
                      : const Duration(milliseconds: 260),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    if (_isFadeOnly) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                        child: child,
                      );
                    } else {
                      final bool isCurrent = child.key is ValueKey<int> &&
                          (child.key as ValueKey<int>).value ==
                              _currentPageIndex;

                      final Offset beginOffset = isCurrent
                          ? (_slideFromRight
                              ? const Offset(1.0, 0)
                              : const Offset(-1.0, 0))
                          : (_slideFromRight
                              ? const Offset(-1.0, 0)
                              : const Offset(1.0, 0));

                      final offsetAnimation = Tween<Offset>(
                        begin: beginOffset,
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ));
                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                          child: child,
                        ),
                      );
                    }
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentPageIndex),
                    child: activeScreen,
                  ),
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: (details) {
                    final double velocity = details.primaryVelocity ?? 0;
                    if (velocity.abs() < 200) return;
                    if (velocity < 0 && selectedItemMenu < 3) {
                      _setTabFromSwipe(selectedItemMenu + 1);
                    } else if (velocity > 0 && selectedItemMenu > 0) {
                      _setTabFromSwipe(selectedItemMenu - 1);
                    }
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      Get.find<WallBgFlameWidget>()
                          .gameBounce
                          .applyRandomMove();
                    });
                  },
                  child: AnimatedSwitcher(
                    duration: _isFadeOnly
                        ? const Duration(milliseconds: 75)
                        : const Duration(milliseconds: 260),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      if (_isFadeOnly) {
                        return FadeTransition(
                          opacity: CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                          child: child,
                        );
                      } else {
                        final bool isCurrent = child.key is ValueKey<int> &&
                            (child.key as ValueKey<int>).value ==
                                _currentPageIndex;

                        final Offset beginOffset = isCurrent
                            ? (_slideFromRight
                                ? const Offset(1.0, 0)
                                : const Offset(-1.0, 0))
                            : (_slideFromRight
                                ? const Offset(-1.0, 0)
                                : const Offset(1.0, 0));

                        final offsetAnimation = Tween<Offset>(
                          begin: beginOffset,
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ));
                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                            child: child,
                          ),
                        );
                      }
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentPageIndex),
                      child: activeScreen,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
