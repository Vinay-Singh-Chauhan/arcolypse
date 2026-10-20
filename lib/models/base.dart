class GameBase {
  final int x;
  final int y;
  final bool isMain;
  double health;
  double maxHealth;
  bool isDestroyed;

  GameBase({
    required this.x,
    required this.y,
    required this.isMain,
    required this.health,
    required this.maxHealth,
    this.isDestroyed = false,
  });

  void takeDamage(double amount) {
    if (isDestroyed) return;
    health -= amount;
    if (health <= 0) {
      health = 0;
      isDestroyed = true;
    }
  }
}
