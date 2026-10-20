import 'package:flutter/material.dart';
import 'game_theme.dart';

class InsurgencyTheme implements GameThemeData {
  @override
  String get name => 'Insurgency';

  @override
  Color get backgroundColor => const Color(0xFF1A1C1E);

  @override
  Color get gridLineColor => const Color(0xFF383838);

  @override
  Color get emptyCellColor => const Color(0xFF26282A);

  @override
  Color get wallColor => const Color(0xFF607D8B); // Steel barricade

  @override
  Color get infectionColor => const Color(0xFFFF9800); // Orange militant territory spread

  @override
  Color get infectionSourceColor => const Color(0xFFF57C00); // Rebel base / source

  @override
  Color get civilianColor => const Color(0xFF00BCD4); // Hostage

  @override
  Color get corruptedColor => const Color(0xFF9C27B0); // Turncoat / terrorist

  @override
  Color get baseColor => const Color(0xFF3F51B5); // Command FOB

  @override
  Color get subBaseColor => const Color(0xFF5C6BC0); // Forward Outpost

  @override
  Color get protagonistColor => const Color(0xFF8BC34A); // Tactical Operator

  @override
  Color get enemyColor => const Color(0xFFD32F2F); // Insurgent combatant
}
