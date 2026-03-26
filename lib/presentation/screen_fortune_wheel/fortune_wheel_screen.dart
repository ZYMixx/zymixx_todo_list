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
import '../screen_app_bottom_navigator/my_bottom_navigator_screen.dart';

class FortuneWheelScreen extends StatelessWidget {
  const FortuneWheelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<TodoItem> todoItemsList = Get.find<AllItemControlBloc>()
        .state
        .todoActiveItemList
        .where((e) => e.category == EnumTodoCategory.active.name)
        .toList();

    if (todoItemsList.isEmpty) {
      return FortuneWheelEmptyState(
        onAddTaskTap: () =>
            Get.find<AllItemControlBloc>().add(AddNewItemEvent()),
      );
    }
    return FortuneWheel(
      itemsList: todoItemsList,
    );
  }
}

class FortuneWheelEmptyState extends StatelessWidget {
  final VoidCallback onAddTaskTap;

  const FortuneWheelEmptyState({
    super.key,
    required this.onAddTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WaveShimmerOverlay(
        seed: FortuneWheelEmptyState,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.55),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.casino_rounded,
                            color: Colors.white,
                            size: 34,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Нет задач для барабана',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          letterSpacing: -0.2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Добавьте хотя бы одну активную задачу — и можно будет крутить барабан.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.3,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.find<MyBottomNavigatorWidget>()
                                .state
                                .setSelectedTab(0);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              onAddTaskTap();
                            });
                          },
                          icon: const Icon(Icons.add_rounded, size: 22),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'Добавить задачу',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ToolThemeData.mainGreenColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _shakeController;
  late FixedExtentScrollController _scrollController;
  final double _itemExtent = 120;
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  int spinResetCounter = 0;
  late double _startPosition;
  late double _velocity;
  late Duration _startTime;
  TodoItem? selectedItem;
  ValueNotifier<TodoItem?> selectedItemNotifier =
      ValueNotifier<TodoItem?>(null);

  bool _isWinAlertPlayed = false;
  bool _isWinMusicPlayed = false;
  bool _isConfettiPlayed = false;
  bool _isWinnerSet = false;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
        initialItem: (widget.itemsList.length ~/ 2));

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _spinController.addListener(_handleSpinUpdate);
    _spinController.addStatusListener(_handleSpinStatus);

    _velocity = 0;
  }

  void _handleSpinUpdate() {
    if (!_spinController.isAnimating) return;

    // Управляем анимацией стрелок (тряска)
    if (_spinController.value < 0.9) {
      if (!_shakeController.isAnimating) {
        _shakeController.repeat(reverse: true);
      }
    } else {
      _shakeController.stop();
      _shakeController.reset();
    }

    // События в конце анимации без таймеров
    final double progress = _spinController.value;

    // 1. Показ победителя (когда колесо почти остановилось)
    if (progress > 0.95 && !_isWinnerSet) {
      _isWinnerSet = true;
      selectedItemNotifier.value = selectedItem;
    }

    // 2. Звук победы
    if (progress > 0.96 && !_isWinAlertPlayed) {
      _isWinAlertPlayed = true;
      Get.find<ServiceAudioPlayer>().playFortuneWinAlert();
    }

    // 3. Конфетти
    if (progress > 0.97 && !_isConfettiPlayed) {
      _isConfettiPlayed = true;
      _confettiController.play();
    }

    // 4. Музыка победы перенесена в _handleSpinStatus для надежности
  }

  void _handleSpinStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _shakeController.stop();
      _shakeController.reset();

      // Останавливаем звук кручения
      Get.find<ServiceAudioPlayer>().stopAll();

      // Запускаем музыку победы только после полной остановки колеса,
      // чтобы stopAll ее не прервал
      Get.find<ServiceAudioPlayer>().playFortuneWinMusic(volume: 0.2);

      if (selectedItem != null) {
        try {
          Get.find<ListTodoScreenBloc>()
              .add(SetSpinWinnerEvent(movedItemId: selectedItem!.id));
        } catch (e) {
          Log.e(e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WaveShimmerOverlay(
        seed: FortuneWheel,
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
                    confettiController: _confettiController,
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
              Positioned.fill(
                child: ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: _itemExtent,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.0035,
                  onSelectedItemChanged: (id) {},
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List<Widget>.generate(
                      widget.itemsList.length * 3,
                      (index) {
                        final item =
                            widget.itemsList[index % widget.itemsList.length];
                        return AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateZ(_shakeController.value == 0
                                    ? 0
                                    : (_shakeController.value * 2 - 1) * 0.03)
                                ..rotateY(_shakeController.value == 0
                                    ? 0
                                    : (_shakeController.value * 2 - 1) * 0.02)
                                ..rotateX(-0.07),
                              child: ValueListenableBuilder<TodoItem?>(
                                valueListenable: selectedItemNotifier,
                                builder: (context, selectedWinner, _) {
                                  return CardSpinItemWidget(
                                    key: ValueKey(
                                        'spin_card_${item.id}_$spinResetCounter\_$index'),
                                    item: item,
                                    index: index,
                                    isWinner: selectedWinner == item,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Боковые стрелки
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final double bounce =
                          math.sin(_shakeController.value * math.pi).abs();
                      final double intensity =
                          _shakeController.isAnimating ? 1.0 : 0.6;
                      return Transform.translate(
                        offset: Offset(bounce * 12 * intensity, 0),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 100),
                          scale: 1.0 + bounce * 0.2 * intensity,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.4 * intensity),
                                  blurRadius: 15,
                                  offset: const Offset(2, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white
                                      .withValues(alpha: 0.2 * intensity),
                                  blurRadius: 10,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              size: 80,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 15,
                                  offset: Offset(0, 4),
                                ),
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final double bounce =
                          math.sin(_shakeController.value * math.pi).abs();
                      final double intensity =
                          _shakeController.isAnimating ? 1.0 : 0.6;
                      return RotatedBox(
                        quarterTurns: 2,
                        child: Transform.translate(
                          offset: Offset(bounce * 12 * intensity, 0),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 100),
                            scale: 1.0 + bounce * 0.2 * intensity,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.4 * intensity),
                                    blurRadius: 15,
                                    offset: const Offset(2, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.white
                                        .withValues(alpha: 0.2 * intensity),
                                    blurRadius: 10,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.chevron_right_rounded,
                                size: 80,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 15,
                                    offset: Offset(0, 4),
                                  ),
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Невидимый слой для перехвата жестов и вращения
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: (details) {
                    if (_spinController.isAnimating) return;
                    selectedItemNotifier.value = null;
                    _startPosition = details.globalPosition.dy;
                    _startTime = Duration(
                        milliseconds: DateTime.now().millisecondsSinceEpoch);
                    _velocity = 0;
                  },
                  onVerticalDragUpdate: (details) {
                    final double delta =
                        details.globalPosition.dy - _startPosition;
                    final Duration timeDelta = Duration(
                            milliseconds:
                                DateTime.now().millisecondsSinceEpoch) -
                        _startTime;
                    if (timeDelta.inMilliseconds > 0) {
                      _velocity = delta / timeDelta.inMilliseconds;
                    }
                    // Позволяем прокручивать список пальцем
                    _scrollController
                        .jumpTo(_scrollController.offset - details.delta.dy);
                  },
                  onVerticalDragEnd: (details) {
                    _setUpSpinWheel(_velocity);
                  },
                ),
              ),
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateZ(_shakeController.value == 0
                          ? 0
                          : (_shakeController.value * 2 - 1) * 0.01)
                      ..rotateY(_shakeController.value == 0
                          ? 0
                          : (_shakeController.value * 2 - 1) * 0.07),
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startSpin(PointerDownEvent event) {
    if (_spinController.isAnimating) return;
    selectedItemNotifier.value =
        null; // Сброс победителя при начале нового кручения
    _startPosition = event.position.dy;
    _startTime = Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);
    _velocity = 0;
  }

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
    if (spinVelocity.abs() < 0.5) return;

    setState(() {
      spinResetCounter++;
    });

    Get.find<ServiceAudioPlayer>().stopAll();

    // Сброс флагов анимации
    _isWinAlertPlayed = false;
    _isWinMusicPlayed = false;
    _isConfettiPlayed = false;
    _isWinnerSet = false;
    selectedItemNotifier.value = null;

    final int itemCount = widget.itemsList.length;
    final int randomItem = math.Random.secure().nextInt(itemCount);
    final int fullRotations = 4 + math.Random.secure().nextInt(3);
    final int currentIndex = _scrollController.selectedItem;
    final int direction = spinVelocity >= 0 ? -1 : 1;
    final int targetIndex =
        currentIndex + direction * (fullRotations * itemCount + randomItem);
    selectedItem = widget.itemsList[targetIndex % itemCount];

    Log.i(
        'FortuneWheel: START SPIN. targetIndex: $targetIndex, finalItem: ${selectedItem?.title}');
    Get.find<ServiceAudioPlayer>().playFortuneSpinnerMusic();

    _spinController.reset();

    // Используем Animation для управления прокруткой
    final Animation<double> scrollAnimation = Tween<double>(
      begin: _scrollController.offset,
      end: targetIndex * _itemExtent,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    scrollAnimation.addListener(() {
      _scrollController.jumpTo(scrollAnimation.value);
    });

    _spinController.forward();
  }

  @override
  void dispose() {
    try {
      Get.find<ServiceAudioPlayer>().stopAll();
    } catch (e) {}

    _spinController.dispose();
    _shakeController.dispose();
    _scrollController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
