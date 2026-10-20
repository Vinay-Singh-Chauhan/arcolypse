enum EntityType {
  protagonist,
  enemy,
}

class GameEntity {
  int x;
  int y;
  final EntityType type;
  double health;
  double maxHealth;

  GameEntity({
    required this.x,
    required this.y,
    required this.type,
    this.health = 100.0,
    this.maxHealth = 100.0,
  });
}
