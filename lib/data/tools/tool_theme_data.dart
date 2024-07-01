import 'package:flutter/material.dart';
import 'package:zymixx_todo_list/presentation/app.dart';

abstract class ToolThemeData {
  static const double itemWidth = 600;
  static const double itemHeight = 50;
  static const double itemOpenHeight = 110;
  static const String lineIndicator = '🎯';

  static const itemBorderColor = Color(0xFF651FFF);
  static const highlightColor = Colors.purpleAccent;
  static const specialItemColor = Colors.orangeAccent;
  static const mainGreenColor = Color(0xFF00C853);
  static const highlightGreenColor = Color(0xFF00E676);

  static const BoxDecoration defShadowBox = BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 2.0,
        spreadRadius: 1.0,
        offset: Offset(0, 0),
      ),
    ],
  );

  static const List<Shadow> defTextShadow = [
    Shadow(
      color: Colors.black26,
      offset: Offset(0, 0.1),
      blurRadius: 1.5,
    ),
  ];
}

class MyDefBgDecoration extends StatelessWidget {
  final Widget child;

  const MyDefBgDecoration({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(App.isRelease ? 'assets/zerowell.png' : 'assets/wood_bg.jpg'),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          colorFilter: ColorFilter.mode(
            Colors.black26,
            BlendMode.darken,
          ),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [
              Colors.transparent,
              Colors.black26,
              Colors.black38,
              Colors.deepPurpleAccent,
            ],
            stops: [0.2, 0.7, 0.75, 1.0],
          ),
          backgroundBlendMode: BlendMode.softLight,
        ),
        child: child,
      ),
    );
  }
}
