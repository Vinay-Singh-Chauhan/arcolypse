import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'cell.dart';
import 'base.dart';
import 'entity.dart';
import '../themes/game_theme.dart';
import '../themes/zombie_theme.dart';
import '../themes/insurgency_theme.dart';

enum GameModeState { menu, playing, paused, gameOver, victory }

class GameState extends ChangeNotifier {
  // Larger grid with smaller cells (36 x 24)
  static const int gridWidth = 36;
  static const int gridHeight = 24;

  GameModeState state = GameModeState.menu;
  GameThemeData theme = ZombieTypeHelper.getTheme('Zombies');

  late List<List<Cell>> grid;
  late GameEntity protagonist;
  List<GameEntity> enemies = [];
  List<GameBase> bases = [];

  int score = 0;
  int ammo = 50;
  int civiliansRescued = 0;
  int subBaseUnlocksAvailable = 0;
  int ticks = 0;

  Timer? _gameLoopTimer;
  final Random _random = Random();

  GameState() {
    _initGrid();
  }

  void setTheme(String themeName) {
    if (themeName == 'Zombies') {
      theme = ZombieTheme();
    } else {
      theme = InsurgencyTheme();
    }
    notifyListeners();
  }

  void startGame() {
    state = GameModeState.playing;
    score = 0;
    civiliansRescued = 0;
    subBaseUnlocksAvailable = 0;
    ticks = 0;
    ammo = 50;
    enemies.clear();
    bases.clear();

    _initGrid();

    // Setup Main Base at center
    int bx = gridWidth ~/ 2;
    int by = gridHeight ~/ 2;
    grid[by][bx] = Cell(x: bx, y: by, type: CellType.base, health: 100, maxHealth: 100, isProtected: true);
    bases.add(GameBase(x: bx, y: by, isMain: true, health: 100, maxHealth: 100));

    // Setup Protagonist near base
    protagonist = GameEntity(x: bx - 1, y: by, type: EntityType.protagonist, health: 100, maxHealth: 100);

    // Spawn initial infection sources (more sources for larger grid)
    _spawnInfectionSources(5);

    // Spawn initial civilians
    _spawnCivilians(8);

    _startGameLoop();
    notifyListeners();
  }

  void _initGrid() {
    grid = List.generate(
      gridHeight,
      (y) => List.generate(
        gridWidth,
        (x) => Cell(x: x, y: y, type: CellType.empty),
      ),
    );
  }

  void _spawnInfectionSources(int count) {
    int spawned = 0;
    while (spawned < count) {
      int x = _random.nextInt(gridWidth);
      int y = _random.nextInt(gridHeight);
      if (grid[y][x].type == CellType.empty) {
        grid[y][x] = grid[y][x].copyWith(type: CellType.infectionSource, health: 100);
        spawned++;
      }
    }
  }

  void _spawnCivilians(int count) {
    int spawned = 0;
    while (spawned < count) {
      int x = _random.nextInt(gridWidth);
      int y = _random.nextInt(gridHeight);
      if (grid[y][x].type == CellType.empty) {
        grid[y][x] = grid[y][x].copyWith(type: CellType.civilian);
        spawned++;
      }
    }
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (state == GameModeState.playing) {
        _updateGameTick();
      }
    });
  }

  void _updateGameTick() {
    ticks++;

    if (ticks % 6 == 0) {
      _processInfectionSpread();
    }

    if (ticks % 3 == 0) {
      _updateEnemies();
    }

    int baseCount = bases.where((b) => !b.isDestroyed).length;
    ammo = min(100, ammo + (baseCount * 2));

    if (bases.every((b) => b.isDestroyed)) {
      state = GameModeState.gameOver;
      _gameLoopTimer?.cancel();
    }

    notifyListeners();
  }

  void _processInfectionSpread() {
    List<Point<int>> newInfections = [];
    List<Point<int>> newSources = [];
    List<Point<int>> corruptedHostages = [];

    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        Cell cell = grid[y][x];

        if (cell.isProtected) continue;

        if (cell.type == CellType.infection || cell.type == CellType.infectionSource) {
          for (var dir in [const Point(0, 1), const Point(0, -1), const Point(1, 0), const Point(-1, 0)]) {
            int nx = x + dir.x;
            int ny = y + dir.y;
            if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
              Cell neighbor = grid[ny][nx];
              if (!neighbor.isProtected) {
                if (neighbor.type == CellType.empty) {
                  newInfections.add(Point(nx, ny));
                } else if (neighbor.type == CellType.civilian) {
                  corruptedHostages.add(Point(nx, ny));
                } else if (neighbor.type == CellType.base || neighbor.type == CellType.subBase) {
                  for (var b in bases) {
                    if (b.x == nx && b.y == ny) {
                      b.takeDamage(10.0);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    for (var pt in newInfections) {
      if (grid[pt.y][pt.x].type == CellType.empty) {
        grid[pt.y][pt.x] = grid[pt.y][pt.x].copyWith(type: CellType.infection, health: 50);

        int infectedNeighbors = _countInfectedNeighbors(pt.x, pt.y);
        if (infectedNeighbors >= 3) {
          newSources.add(pt);
        }
      }
    }

    for (var pt in newSources) {
      if (grid[pt.y][pt.x].type == CellType.infection) {
        grid[pt.y][pt.x] = grid[pt.y][pt.x].copyWith(type: CellType.infectionSource);
      }
    }

    for (var pt in corruptedHostages) {
      grid[pt.y][pt.x] = grid[pt.y][pt.x].copyWith(type: CellType.hostageCorrupted);
      enemies.add(GameEntity(x: pt.x, y: pt.y, type: EntityType.enemy, health: 50, maxHealth: 50));
    }

    if (ticks % 10 == 0) {
      _spawnCivilians(1);
    }
  }

  int _countInfectedNeighbors(int x, int y) {
    int count = 0;
    for (var dir in [const Point(0, 1), const Point(0, -1), const Point(1, 0), const Point(-1, 0)]) {
      int nx = x + dir.x;
      int ny = y + dir.y;
      if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
        Cell c = grid[ny][nx];
        if (c.type == CellType.infection || c.type == CellType.infectionSource) {
          count++;
        }
      }
    }
    return count;
  }

  void _updateEnemies() {
    for (var enemy in enemies) {
      if (bases.isEmpty) break;
      GameBase targetBase = bases.where((b) => !b.isDestroyed).first;
      if (enemy.x < targetBase.x) {
        enemy.x++;
      } else if (enemy.x > targetBase.x) {
        enemy.x--;
      }

      if (enemy.y < targetBase.y) {
        enemy.y++;
      } else if (enemy.y > targetBase.y) {
        enemy.y--;
      }

      if (enemy.x == targetBase.x && enemy.y == targetBase.y) {
        for (var b in bases) {
          if (b.x == enemy.x && b.y == enemy.y) {
            b.takeDamage(15.0);
          }
        }
      }
    }
  }

  void moveProtagonist(int dx, int dy) {
    if (state != GameModeState.playing) return;
    int nx = protagonist.x + dx;
    int ny = protagonist.y + dy;
    if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
      protagonist.x = nx;
      protagonist.y = ny;

      Cell cell = grid[ny][nx];
      if (cell.type == CellType.civilian) {
        grid[ny][nx] = cell.copyWith(type: CellType.empty);
        civiliansRescued++;
        score += 100;
        
        if (civiliansRescued % 3 == 0 && bases.length < 5) {
          subBaseUnlocksAvailable++;
        }
      }
      notifyListeners();
    }
  }

  void buildWallAtProtagonist() {
    if (state != GameModeState.playing) return;
    int x = protagonist.x;
    int y = protagonist.y;
    Cell cell = grid[y][x];

    if (cell.type == CellType.empty) {
      grid[y][x] = cell.copyWith(type: CellType.wall, health: 100, isProtected: true);
      score += 20;
      _evaluateEnclosures();
      notifyListeners();
    }
  }

  void removeWallAtProtagonist() {
    if (state != GameModeState.playing) return;
    int x = protagonist.x;
    int y = protagonist.y;
    Cell cell = grid[y][x];

    if (cell.type == CellType.wall) {
      grid[y][x] = cell.copyWith(type: CellType.empty, isProtected: false);
      _evaluateEnclosures();
      notifyListeners();
    }
  }

  void buildSubBase() {
    if (state != GameModeState.playing || subBaseUnlocksAvailable <= 0) return;
    int x = protagonist.x;
    int y = protagonist.y;
    Cell cell = grid[y][x];

    if (cell.type == CellType.empty && cell.isProtected) {
      grid[y][x] = cell.copyWith(type: CellType.subBase, health: 75, maxHealth: 75, isProtected: true);
      bases.add(GameBase(x: x, y: y, isMain: false, health: 75, maxHealth: 75));
      subBaseUnlocksAvailable--;
      score += 500;
      notifyListeners();
    }
  }

  void disinfectAdjacentCell() {
    if (state != GameModeState.playing || ammo < 2) return;

    bool disinfectedAny = false;
    for (var dir in [const Point(0, 0), const Point(0, 1), const Point(0, -1), const Point(1, 0), const Point(-1, 0)]) {
      int nx = protagonist.x + dir.x;
      int ny = protagonist.y + dir.y;
      if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
        Cell c = grid[ny][nx];
        if (c.type == CellType.infection) {
          grid[ny][nx] = c.copyWith(type: CellType.empty);
          disinfectedAny = true;
        }
      }
    }

    if (disinfectedAny) {
      ammo -= 2;
      score += 30;
      _evaluateEnclosures();
      notifyListeners();
    }
  }

  void shootEnemy() {
    if (state != GameModeState.playing || ammo <= 0) return;
    ammo--;

    enemies.removeWhere((enemy) {
      bool adjacent = (enemy.x - protagonist.x).abs() <= 1 && (enemy.y - protagonist.y).abs() <= 1;
      if (adjacent) {
        score += 50;
        if (grid[enemy.y][enemy.x].type == CellType.hostageCorrupted) {
          grid[enemy.y][enemy.x] = grid[enemy.y][enemy.x].copyWith(type: CellType.empty);
        }
      }
      return adjacent;
    });
    notifyListeners();
  }

  void _evaluateEnclosures() {
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        Cell cell = grid[y][x];
        if (cell.type == CellType.wall || cell.type == CellType.base || cell.type == CellType.subBase) {
          cell.isProtected = true;
        } else {
          bool enclosed = _checkIfEnclosed(x, y);
          cell.isProtected = enclosed;

          if (enclosed && (cell.type == CellType.infectionSource || cell.type == CellType.infection)) {
            grid[y][x] = cell.copyWith(type: CellType.empty, isProtected: true);
            score += 150;
          }
        }
      }
    }
  }

  bool _checkIfEnclosed(int startX, int startY) {
    Set<Point<int>> visited = {};
    List<Point<int>> queue = [Point(startX, startY)];
    bool reachesEdge = false;

    while (queue.isNotEmpty) {
      var p = queue.removeAt(0);
      if (p.x == 0 || p.x == gridWidth - 1 || p.y == 0 || p.y == gridHeight - 1) {
        reachesEdge = true;
        break;
      }
      if (visited.contains(p)) continue;
      visited.add(p);

      for (var dir in [const Point(0, 1), const Point(0, -1), const Point(1, 0), const Point(-1, 0)]) {
        int nx = p.x + dir.x;
        int ny = p.y + dir.y;
        if (nx >= 0 && nx < gridWidth && ny >= 0 && ny < gridHeight) {
          Cell c = grid[ny][nx];
          if (c.type != CellType.wall && c.type != CellType.base && c.type != CellType.subBase) {
            queue.add(Point(nx, ny));
          }
        }
      }
    }
    return !reachesEdge;
  }

  void pauseGame() {
    if (state == GameModeState.playing) {
      state = GameModeState.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (state == GameModeState.paused) {
      state = GameModeState.playing;
      notifyListeners();
    }
  }

  void quitToMenu() {
    state = GameModeState.menu;
    _gameLoopTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }
}

class ZombieTypeHelper {
  static GameThemeData getTheme(String name) {
    return name == 'Zombies' ? ZombieTheme() : InsurgencyTheme();
  }
}
