import 'package:zymixx_todo_list/data/tools/tool_logger.dart';
import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

class CardSpinItemWidget extends StatefulWidget {
  CardSpinItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isWinner,
  });

  final TodoItem item;
  final int index;
  final bool isWinner;

  @override
  State<CardSpinItemWidget> createState() => _CardSpinItemWidgetState();
}

class _CardSpinItemWidgetState extends State<CardSpinItemWidget> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    final bool isEven = widget.index % 2 == 0;

    final bool isWinner = widget.isWinner;
    if (isWinner) {
      Log.i(
          'CardSpinItemWidget: isWinner is TRUE for item ${widget.item.title}');
    }

    // Цвета для плавного перехода
    final Color color1 =
        isEven ? const Color(0xFF6A11CB) : const Color(0xFF2575FC);
    final Color color2 =
        isEven ? const Color(0xFF2575FC) : const Color(0xFF6A11CB);

    final List<Color> currentColors = isClicked
        ? [const Color(0xFFFFFFFF), const Color(0xFFF0F2F5)]
        : (isWinner
            ? [const Color(0xFFFF9800), const Color(0xFFFFD700)]
            : [
                color1.withValues(alpha: 0.85),
                color2.withValues(alpha: 0.85),
              ]);

    // Разница в масштабе была 0.12 (1.12 - 1.0). Уменьшаем на 20%: 0.12 * 0.8 = 0.096. Новый масштаб: 1.096
    // Разница в повороте была 0.005. Уменьшаем на 20%: 0.005 * 0.8 = 0.004
    final double targetScale = isWinner ? 1.096 : 1.0;
    final double targetTurns = isWinner ? 0.004 : 0;

    return RepaintBoundary(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 400),
        scale: targetScale,
        curve: Curves.elasticOut,
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 600),
          turns: targetTurns,
          curve: Curves.easeOutBack,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              setState(() {
                isClicked = !isClicked;
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                alignment: Alignment.center,
                width: isWinner ? 265 : 240,
                height: 115,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Перспектива
                  ..rotateX(
                      isWinner ? -0.05 : 0) // Легкий наклон назад для объема
                  ..rotateY(isWinner ? 0.02 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: currentColors,
                  ),
                  border: Border.all(
                    color: isWinner
                        ? Colors.white.withAlpha(204)
                        : Colors.white.withAlpha(76),
                    width: isWinner ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    // Глубокая тень для объема
                    BoxShadow(
                      color: (isWinner ? Colors.orange : Colors.black)
                          .withAlpha(isWinner ? 153 : 102),
                      blurRadius: isWinner ? 40 : 20,
                      spreadRadius: isWinner ? 6 : 0,
                      offset: Offset(0, isWinner ? 15 : 10),
                    ),
                    // Контурное свечение для победителя
                    if (isWinner)
                      BoxShadow(
                        color: Colors.orangeAccent.withAlpha(128),
                        blurRadius: 20,
                        spreadRadius: -2,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // Постоянный блик с плавной прозрачностью
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isClicked ? 0.0 : 1.0,
                        child: Stack(
                          children: [
                            Positioned(
                              left: -40,
                              top: -40,
                              child: Container(
                                width: 180,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white.withAlpha(51),
                                      Colors.white.withAlpha(0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (isWinner)
                              Positioned(
                                right: -30,
                                bottom: -30,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withAlpha(38),
                                        Colors.white.withAlpha(0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              right: -20,
                              top: -20,
                              child: AnimatedRotation(
                                duration: const Duration(seconds: 15),
                                turns: isWinner ? 1 : 0,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(26),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Иконка на заднем плане (только для победителя)
                      if (isWinner)
                        Center(
                          child: Opacity(
                            opacity: 0.15,
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.black,
                              size: 80,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Center(
                          child: Text(
                            isClicked
                                ? (widget.item.content.isEmpty
                                    ? 'нет описания'
                                    : widget.item.content)
                                : widget.item.title,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  isClicked ? FontWeight.w500 : FontWeight.w800,
                              fontSize: isClicked ? 15 : 19,
                              letterSpacing: isClicked ? 0 : -0.3,
                              color: isClicked
                                  ? Colors.black87
                                  : (isWinner
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white),
                              shadows: isWinner
                                  ? [
                                      Shadow(
                                        color: Colors.white.withAlpha(76),
                                        offset: const Offset(0, 1),
                                        blurRadius: 1,
                                      ),
                                    ]
                                  : (isClicked
                                      ? null
                                      : [
                                          Shadow(
                                            color: Colors.black.withAlpha(153),
                                            offset: const Offset(0, 2),
                                            blurRadius: 8,
                                          ),
                                        ]),
                            ),
                          ),
                        ),
                      ),
                    ],
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
