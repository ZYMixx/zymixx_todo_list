import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/domain/todo_item.dart';

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
    final bool isEven = widget.index % 2 == 0;

    final bool isWinner = widget.selectedItemNotifier.value == widget.item;

    // Современные глубокие градиенты с эффектом объема
    final Color color1 =
        isEven ? const Color(0xFF6A11CB) : const Color(0xFF2575FC);
    final Color color2 =
        isEven ? const Color(0xFF2575FC) : const Color(0xFF6A11CB);

    final Color winnerColor1 = const Color(0xFFFF8C00);
    final Color winnerColor2 = const Color(0xFFFFD700);

    return AnimatedScale(
      duration: const Duration(milliseconds: 400),
      scale: isWinner ? 1.08 : 1.0,
      curve: Curves.elasticOut,
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 600),
        turns: isWinner ? 0.01 : 0,
        curve: Curves.easeOutBack,
        child: InkWell(
          onTap: () {
            setState(() {
              isClicked = !isClicked;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              alignment: Alignment.center,
              width: isWinner ? 260 : 240,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: isClicked
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isWinner
                            ? [winnerColor1, winnerColor2]
                            : [color1, color2],
                      ),
                color: isClicked ? Colors.white : null,
                border: Border.all(
                  color: isWinner
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.25),
                  width: isWinner ? 2.5 : 1.2,
                ),
                boxShadow: [
                  // Основная тень с эффектом объема
                  BoxShadow(
                    color: (isWinner ? Colors.orange : Colors.black)
                        .withValues(alpha: isWinner ? 0.5 : 0.35),
                    blurRadius: isWinner ? 35 : 18,
                    spreadRadius: isWinner ? 5 : 0,
                    offset: Offset(0, isWinner ? 12 : 8),
                  ),
                  // Эффект внутренней подсветки грани (верхний левый угол)
                  if (!isClicked)
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 0,
                      spreadRadius: -1,
                      offset: const Offset(1.5, 1.5),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    // Глянцевый градиентный блик (для эффекта стекла/пластика)
                    if (!isClicked)
                      Positioned(
                        left: -40,
                        top: -40,
                        child: Container(
                          width: 180,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Дополнительный нижний блик
                    if (!isClicked && isWinner)
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
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Декоративные вращающиеся круги на фоне
                    if (!isClicked) ...[
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
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Контент карточки
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isClicked && isWinner)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6.0),
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            Text(
                              isClicked
                                  ? (widget.item.content.isEmpty
                                      ? 'нет описания'
                                      : widget.item.content)
                                  : widget.item.title,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isClicked
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                fontSize: isClicked ? 14 : 18,
                                letterSpacing: isClicked ? 0 : -0.2,
                                color:
                                    isClicked ? Colors.black87 : Colors.white,
                                shadows: isClicked
                                    ? null
                                    : [
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.6),
                                          offset: const Offset(0, 1.5),
                                          blurRadius: 6,
                                        ),
                                      ],
                              ),
                            ),
                          ],
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
    );
  }
}
