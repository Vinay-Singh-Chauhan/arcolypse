enum CellType {
  empty,
  wall,
  infection,
  infectionSource,
  civilian,
  hostageCorrupted,
  base,
  subBase,
}

class Cell {
  final int x;
  final int y;
  CellType type;
  double health;
  double maxHealth;
  bool isProtected; // inside an enclosure

  Cell({
    required this.x,
    required this.y,
    this.type = CellType.empty,
    this.health = 100.0,
    this.maxHealth = 100.0,
    this.isProtected = false,
  });

  Cell copyWith({
    CellType? type,
    double? health,
    double? maxHealth,
    bool? isProtected,
  }) {
    return Cell(
      x: x,
      y: y,
      type: type ?? this.type,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
      isProtected: isProtected ?? this.isProtected,
    );
  }
}
