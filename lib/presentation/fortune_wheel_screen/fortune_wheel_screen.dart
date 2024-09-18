import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:zymixx_todo_list/data/services/service_audio_player.dart';
import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:zymixx_todo_list/data/tools/tool_theme_data.dart';
import 'package:zymixx_todo_list/domain/enum_todo_category.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';
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

class _FortuneWheelState extends State<FortuneWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;
  final double _itemExtent = 100;
  ConfettiController _controllerCenterRight =
      ConfettiController(duration: const Duration(seconds: 2));
  late double _startPosition;
  late double _velocity;
  late Duration _startTime;
  TodoItem? preSelectedItem;
  TodoItem? selectedItem;
  ValueNotifier<TodoItem?> selectedItemNotifier = ValueNotifier<TodoItem?>(null);

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: (widget.itemsList.length ~/ 2));
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _velocity = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  minimumSize: Size(7, 4),
                  maximumSize: Size(12, 6),
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
              physics: FixedExtentScrollPhysics(),
              perspective: 0.0035,
              onSelectedItemChanged: (id) {
                preSelectedItem = widget.itemsList[id % widget.itemsList.length];
                Log.i('SELECT ${preSelectedItem?.title}');
              },
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List<Widget>.generate(
                  widget.itemsList.length * 3,
                  (index) {
                    final item = widget.itemsList[index % widget.itemsList.length];
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateZ(_controller.value == 0 ? 0 : (_controller.value * 2 - 1) * 0.03)
                        ..rotateY(_controller.value == 0 ? 0 : (_controller.value * 2 - 1) * 0.02)
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
                    return Transform.translate(
                      offset: Offset(0, math.sin(_controller.value * math.pi * 10) * 7),
                      child: Icon(
                        Icons.arrow_right_outlined,
                        size: 100,
                        color: Colors.black,
                        shadows: ToolThemeData.defTextShadow,
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
                    return Transform.translate(
                      offset: Offset(0, math.sin(_controller.value * math.pi * 10) * 7),
                      child: Icon(
                        Icons.arrow_right_outlined,
                        size: 70,
                        color: ToolThemeData.highlightColor,
                        shadows: ToolThemeData.defTextShadow,
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
                    return RotatedBox(
                      quarterTurns: 2,
                      child: Transform.translate(
                        offset: Offset(0, math.sin(_controller.value * math.pi * 10) * 4),
                        child: Icon(
                          Icons.arrow_right_outlined,
                          size: 100,
                          color: Colors.black,
                          shadows: ToolThemeData.defTextShadow,
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
                    return RotatedBox(
                      quarterTurns: 2,
                      child: Transform.translate(
                        offset: Offset(0, math.sin(_controller.value * math.pi * 10) * 4),
                        child: Icon(
                          Icons.arrow_right_outlined,
                          size: 70,
                          color: ToolThemeData.highlightColor,
                          shadows: ToolThemeData.defTextShadow,
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
                ..rotateZ(_controller.value == 0 ? 0 : (_controller.value * 2 - 1) * 0.01)
                ..rotateY(_controller.value == 0 ? 0 : (_controller.value * 2 - 1) * 0.07),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Крутите барабан',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      AudioPlayer? bgMusicAudioPlayer = Get.find<ServiceAudioPlayer>().playFortuneSpinnerMusic();
      _scrollController.animateTo(
        currentOffset + (spinVelocity * randomItem * 1000),
        duration: Duration(seconds: 6),
        curve: Curves.easeOut,
      )..then((_) {
          Future.delayed(Duration(milliseconds: 750)).then((_) async {
            await bgMusicAudioPlayer?.stop();
            await bgMusicAudioPlayer?.dispose();
          });
          Future.delayed(Duration(milliseconds: 350)).then((_) {
            Get.find<ServiceAudioPlayer>().playFortuneWinAlert();
          });
          Future.delayed(Duration(milliseconds: 850)).then((_) {
            Get.find<ServiceAudioPlayer>().playFortuneWinMusic(volume: 0.3);
          });
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
    _controller.dispose();
    _scrollController.dispose();
    _controllerCenterRight.dispose();
    super.dispose();
  }
}

class CardSpinItemWidget extends StatefulWidget {
  CardSpinItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.selectedItemNotifier,
  });

  final TodoItem item;
  final int index;
  final ValueNotifier<TodoItem?> selectedItemNotifier;

  @override
  State<CardSpinItemWidget> createState() => _CardSpinItemWidgetState();
}

class _CardSpinItemWidgetState extends State<CardSpinItemWidget> {
  bool isClicked = false;
  bool isWinner = false;

  @override
  void initState() {
    widget.selectedItemNotifier.addListener(() {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (widget.selectedItemNotifier.value == widget.item) {
            setState(() {
              isWinner = true;
            });
          } else {
            if (isWinner) {
              setState(() {
                isWinner = false;
              });
            }
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isClicked = !isClicked;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isClicked
                ? Colors.white
                : widget.index % 2 == 0
                    ? Colors.deepPurpleAccent
                    : Colors.blueAccent,
            border: Border.all(),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 4.0,
                spreadRadius: 3.0,
                offset: Offset(1, 1),
              ),
            ],
            image: DecorationImage(
              image: AssetImage('assets/frame_spin.png'),
              fit: BoxFit.fill,
              opacity: 0.2,
              colorFilter: ColorFilter.mode(
                Colors.black,
                BlendMode.srcATop, // режим наложения
              ),
            ),
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 750),
            alignment: Alignment.center,
            width: isWinner ? 255 : 240,
            height: 130,
            decoration: isWinner
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isClicked ? Colors.white : Colors.orangeAccent,
                    border: Border.all(),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 4.0,
                        spreadRadius: 3.0,
                        offset: Offset(1, 1),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage('assets/frame_spin.png'),
                      fit: BoxFit.fill,
                      opacity: 0.2,
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcATop, // р// ежим наложения
                      ),
                    ),
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 4),
                  child: Text(
                    isClicked
                        ? widget.item.content == ''
                            ? 'нет описания'
                            : widget.item.content
                        : widget.item.title,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                        fontWeight: isClicked ? FontWeight.w400 : FontWeight.w500,
                        fontSize: isClicked ? 18 : 22,
                        letterSpacing: -0.5,
                        wordSpacing: -1.0,
                        height: 0.9,
                        fontStyle: isClicked ? FontStyle.italic : null,
                        shadows: ToolThemeData.defTextShadow),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
