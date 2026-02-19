import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
import 'package:zymixx_todo_list/presentation/app_widgets/wave_shimmer_overlay.dart';
import 'package:zymixx_todo_list/presentation/screen_fortune_wheel/widgets/card_spin_item_widget.dart';
import 'dart:async';
import 'dart:math' as math;

import '../bloc_global/all_item_control_bloc.dart';
import '../bloc_global/list_todo_screen_bloc.dart';

class FortuneWheelScreen extends StatelessWidget {
  const FortuneWheelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<TodoItem> todoItemsList = Get.find<AllItemControlBloc>()
        .state
        .todoActiveItemList
        .where((e) => e.category == EnumTodoCategory.active.name)
        .toList();
    return FortuneWheel(
      itemsList: todoItemsList,
    );
  }
}

class FortuneWheel extends StatefulWidget {
  final List<TodoItem> itemsList;

  FortuneWheel({required this.itemsList});

  @override
  _FortuneWheelState createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;
  final double _itemExtent = 120;
  ConfettiController _controllerCenterRight =
      ConfettiController(duration: const Duration(seconds: 2));
  List<Timer> delayedActions = [];
  late double _startPosition;
  late double _velocity;
  late Duration _startTime;
  TodoItem? preSelectedItem;
  TodoItem? selectedItem;
  ValueNotifier<TodoItem?> selectedItemNotifier =
      ValueNotifier<TodoItem?>(null);

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
        initialItem: (widget.itemsList.length ~/ 2));
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _velocity = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WaveShimmerOverlay(
        id: 'fortune_wheel_bg',
        child: Listener(
          onPointerDown: _startSpin,
          onPointerMove: _updateSpin,
          onPointerUp: _endSpin,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 160.0),
                  child: ConfettiWidget(
                    confettiController: _controllerCenterRight,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    minimumSize: const Size(7, 4),
                    maximumSize: const Size(12, 6),
                    maxBlastForce: 15,
                    minBlastForce: 3,
                    emissionFrequency: 0.5,
                    numberOfParticles: 12,
                    gravity: 0.1,
                    colors: const [
                      Colors.purpleAccent,
                      Colors.deepPurpleAccent,
                      Colors.blueAccent,
                      Colors.white,
                    ],
                    particleDrag: 0.05,
                  ),
                ),
              ),
              ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: _itemExtent,
                physics: const FixedExtentScrollPhysics(),
                perspective: 0.0035,
                onSelectedItemChanged: (id) {
                  preSelectedItem =
                      widget.itemsList[id % widget.itemsList.length];
                  Log.i('SELECT ${preSelectedItem?.title}');
                },
                childDelegate: ListWheelChildLoopingListDelegate(
                  children: List<Widget>.generate(
                    widget.itemsList.length * 3,
                    (index) {
                      final item =
                          widget.itemsList[index % widget.itemsList.length];
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateZ(_controller.value == 0
                              ? 0
                              : (_controller.value * 2 - 1) * 0.03)
                          ..rotateY(_controller.value == 0
                              ? 0
                              : (_controller.value * 2 - 1) * 0.02)
                          ..rotateX(-0.07),
                        child: CardSpinItemWidget(
                          item: item,
                          index: index,
                          selectedItemNotifier: selectedItemNotifier,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double bounce =
                          math.sin(_controller.value * math.pi * 10).abs();
                      return Transform.translate(
                        offset: Offset(bounce * 10, 0),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 100),
                          scale: 1.0 + bounce * 0.1,
                          child: Icon(
                            Icons.arrow_right_outlined,
                            size: 100,
                            color: Colors.black.withValues(alpha: 0.45),
                            shadows: ToolThemeData.defTextShadow,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double bounce =
                          math.sin(_controller.value * math.pi * 10).abs();
                      return Transform.translate(
                        offset: Offset(bounce * 8, 0),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 100),
                          scale: 1.0 + bounce * 0.15,
                          child: Icon(
                            Icons.arrow_right_outlined,
                            size: 70,
                            color: ToolThemeData.highlightColor
                                .withValues(alpha: 0.92),
                            shadows: ToolThemeData.defTextShadow,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return const RotatedBox(
                        quarterTurns: 2,
                        child: SizedBox.shrink(),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double bounce =
                          math.sin(_controller.value * math.pi * 10).abs();
                      return RotatedBox(
                        quarterTurns: 2,
                        child: Transform.translate(
                          offset: Offset(bounce * 10, 0),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 100),
                            scale: 1.0 + bounce * 0.1,
                            child: Icon(
                              Icons.arrow_right_outlined,
                              size: 100,
                              color: Colors.black.withValues(alpha: 0.45),
                              shadows: ToolThemeData.defTextShadow,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double bounce =
                          math.sin(_controller.value * math.pi * 10).abs();
                      return RotatedBox(
                        quarterTurns: 2,
                        child: Transform.translate(
                          offset: Offset(bounce * 8, 0),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 100),
                            scale: 1.0 + bounce * 0.15,
                            child: Icon(
                              Icons.arrow_right_outlined,
                              size: 70,
                              color: ToolThemeData.highlightColor
                                  .withValues(alpha: 0.92),
                              shadows: ToolThemeData.defTextShadow,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(_controller.value == 0
                      ? 0
                      : (_controller.value * 2 - 1) * 0.01)
                  ..rotateY(_controller.value == 0
                      ? 0
                      : (_controller.value * 2 - 1) * 0.07),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Крутите барабан',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        letterSpacing: -0.4,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startSpin(PointerDownEvent event) {
    _startPosition = event.position.dy;
    _startTime = event.timeStamp;
  }

  double oldPos = 0;

  void _updateSpin(PointerMoveEvent event) {
    final double delta = event.position.dy - _startPosition;
    final Duration timeDelta = event.timeStamp - _startTime;
    if (timeDelta.inMilliseconds > 0) {
      _velocity = delta / timeDelta.inMilliseconds;
    }
  }

  void _endSpin(PointerUpEvent event) {
    final double delta = event.position.dy - _startPosition;
    final Duration timeDelta = event.timeStamp - _startTime;
    if (timeDelta.inMilliseconds > 0) {
      _velocity = delta / timeDelta.inMilliseconds;
    }
    _setUpSpinWheel(_velocity);
  }

  void _setUpSpinWheel(double spinVelocity) {
    final int itemCount = widget.itemsList.length;
    int randomItem = math.Random.secure().nextInt(itemCount);
    final double currentOffset = _scrollController.offset;
    Log.i('      $currentOffset + ($spinVelocity * $randomItem * 1000),');
    if (spinVelocity.abs() > 1) {
      AudioPlayer? bgMusicAudioPlayer =
          Get.find<ServiceAudioPlayer>().playFortuneSpinnerMusic();
      _scrollController.animateTo(
        currentOffset + (spinVelocity * randomItem * 1000),
        duration: Duration(seconds: 6),
        curve: Curves.easeOut,
      )..then((_) {
          delayedActions.add(
            Timer(const Duration(milliseconds: 750), () async {
              if (!mounted) {
                return;
              }
              await bgMusicAudioPlayer?.stop();
              await bgMusicAudioPlayer?.dispose();
            }),
          );
          delayedActions.add(
            Timer(const Duration(milliseconds: 350), () {
              if (!mounted) {
                return;
              }
              Get.find<ServiceAudioPlayer>().playFortuneWinAlert();
            }),
          );
          delayedActions.add(
            Timer(const Duration(milliseconds: 850), () {
              if (!mounted) {
                return;
              }
              Get.find<ServiceAudioPlayer>().playFortuneWinMusic(volume: 0.3);
            }),
          );

          if (!mounted) {
            return;
          }
          _controllerCenterRight.play();
          _controller
            ..stop()
            ..reset();
          selectedItemNotifier.value = preSelectedItem;
          try {
            Get.find<ListTodoScreenBloc>()
                .add(SetSpinWinnerEvent(movedItemId: preSelectedItem!.id));
          } catch (e) {
            Log.e(e);
          }
        });
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final Timer timer in delayedActions) {
      timer.cancel();
    }
    delayedActions.clear();
    _controller.dispose();
    _scrollController.dispose();
    _controllerCenterRight.dispose();
    super.dispose();
  }
}
