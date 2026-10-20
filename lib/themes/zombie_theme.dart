import 'package:flutter/material.dart';
import 'game_theme.dart';

class ZombieTheme implements GameThemeData {
  @override
  String get name => 'Zombies';

  @override
  Color get backgroundColor => const Color(0xFF121212);

  @override
  Color get gridLineColor => const Color(0xFF2C2C2C);

  @override
  Color get emptyCellColor => const Color(0xFF1E1E1E);

  @override
  Color get wallColor => const Color(0xFF795548); // Brown wood/stone wall

  @override
  Color get infectionColor => const Color(0xFF8BC34A); // Toxic green infection slime

  @override
  Color get infectionSourceColor => const Color(0xFF4CAF50); // Dark toxic source

  @override
  Color get civilianColor => const Color(0xFFFFEB3B); // Yellow civilian survivor

  @override
  Color get corruptedColor => const Color(0xFFE91E63); // Pinkish zombie/mutant

  @override
  Color get baseColor => const Color(0xFF2196F3); // Blue safe base

  @override
  Color get subBaseColor => const Color(0xFF03A9F4); // Lighter blue sub base

  @override
  Color get protagonistColor => const Color(0xFFFFFFFF); // White survivor protagonist

  @override
  Color get enemyColor => const Color(0xFFF44336); // Red zombie horde
}
