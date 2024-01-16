import 'package:flutter/material.dart';

abstract class ToolThemeData {
  static const Color mainShadowBgColor = Color(0x7F191919);
  static const Color mainLightShadowBgColor = Color(0x5F191919);
  static const Color mainCardColor = Color(0xFF0D47A1);
  static const Color mainLightCardColor = Color(0xFF64B5F6);

  static const TextStyle defTextDataStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle defConstTextStyle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black);

  static const TextStyle defFillTextDataStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static BoxShadow defShadowBox = BoxShadow(
    color: Colors.black.withAlpha(120),
    spreadRadius: 0.8,
    blurRadius: 0.8,
    offset: const Offset(-1.5, 3),
  );

  static BoxShadow alertShadowBox = BoxShadow(
    color: Colors.black.withAlpha(80),
    spreadRadius: 4.0,
    blurRadius: 13.0,
    offset: const Offset(-3.0, 12),
  );
}
