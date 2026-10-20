import 'package:flutter/material.dart';

abstract class GameThemeData {
  String get name;
  Color get backgroundColor;
  Color get gridLineColor;
  Color get emptyCellColor;
  Color get wallColor;
  Color get infectionColor;
  Color get infectionSourceColor;
  Color get civilianColor;
  Color get corruptedColor;
  Color get baseColor;
  Color get subBaseColor;
  Color get protagonistColor;
  Color get enemyColor;
}
