import 'package:flutter/material.dart';

abstract class ToolThemeData {

  static const double itemWidth = 600;
  static const double itemHeight = 50;
  static const double itemOpenHeight = 110;

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
