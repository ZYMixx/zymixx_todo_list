import 'package:flutter/material.dart';

class MyAnimatedCard extends StatefulWidget {
  final Widget child;
  final double intensity;
  final bool directionUp;

  const MyAnimatedCard({
    super.key,
    required this.child,
    required this.intensity,
    this.directionUp = true,
  });

  @override
  MyAnimatedCardState createState() => MyAnimatedCardState();
}

class MyAnimatedCardState extends State<MyAnimatedCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    double scaleIntensity = widget.intensity % 1 + 1;
    double translateIntensity = widget.intensity % 1 * -100;
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 75),
        transform: isHovered
            ? (Matrix4.identity()
          ..scale(scaleIntensity, scaleIntensity)
          ..translate(translateIntensity, translateIntensity))
            : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}