import 'package:flutter/material.dart';

// Виджет с анимацией при наведении, который увеличивает элемент из центра
class MyAnimatedCard extends StatefulWidget {
  final Widget child;
  final double intensity;
  final bool directionUp;

  const MyAnimatedCard({
    super.key,
    required this.child,
    required this.intensity,
    this.directionUp = false,
  });

  @override
  MyAnimatedCardState createState() => MyAnimatedCardState();
}

class MyAnimatedCardState extends State<MyAnimatedCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Учитываем интенсивность для масштаба
    double scaleIntensity = widget.intensity % 1 + 1.007;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? scaleIntensity : 1.0, // Масштабирование при наведении
        duration: Duration(milliseconds: 50), // Длительность анимации
        alignment: Alignment.center, // Центрируем анимацию
        child: widget.child,
      ),
    );
  }
}
