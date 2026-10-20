import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../models/game_state.dart';
import '../../models/cell.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _handleKeyEvent(KeyEvent event, GameState gameState) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyW || event.logicalKey == LogicalKeyboardKey.arrowUp) {
        gameState.moveProtagonist(0, -1);
      } else if (event.logicalKey == LogicalKeyboardKey.keyS || event.logicalKey == LogicalKeyboardKey.arrowDown) {
        gameState.moveProtagonist(0, 1);
      } else if (event.logicalKey == LogicalKeyboardKey.keyA || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        gameState.moveProtagonist(-1, 0);
      } else if (event.logicalKey == LogicalKeyboardKey.keyD || event.logicalKey == LogicalKeyboardKey.arrowRight) {
        gameState.moveProtagonist(1, 0);
      } else if (event.logicalKey == LogicalKeyboardKey.keyC || event.logicalKey == LogicalKeyboardKey.space) {
        gameState.buildWallAtProtagonist();
      } else if (event.logicalKey == LogicalKeyboardKey.keyX) {
        gameState.removeWallAtProtagonist();
      } else if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        gameState.shootEnemy();
      } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        gameState.disinfectAdjacentCell();
      } else if (event.logicalKey == LogicalKeyboardKey.keyB) {
        gameState.buildSubBase();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        gameState.pauseGame();
      }
    }
  }

  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗺️ Game Legend & Keyboard Shortcuts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• ⚪ Protagonist (Move: WASD / Arrow Keys - hold to move continuously)'),
            Text('• 🟥 Enemy (Zombie / Terrorist)'),
            Text('• 🟫 Wall (Construct: C or Space | Demolish: X key)'),
            Text('• 🟩 Protected Zone (Enclosed safe area)'),
            Text('• 🟧 Infection (Disinfect: F key)'),
            Text('• 🦠 Infection Source (Enclose in walls to cleanse)'),
            Text('• 👤 Civilian (Rescue target - 3 rescues = 1 Sub-Base token)'),
            Text('• 🛡️ Main Base (100% health)'),
            Text('• 🛡️ Sub-Base (Build: B key on protected empty cells)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.gameState;

    return ListenableBuilder(
      listenable: gameState,
      builder: (context, child) {
        final theme = gameState.theme;

        if (gameState.state == GameModeState.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showGameOverDialog(context, gameState);
          });
        }

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (node, event) {
            _handleKeyEvent(event, gameState);
            return KeyEventResult.handled;
          },
          child: Scaffold(
            backgroundColor: theme.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.black87,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: ${gameState.score}', style: const TextStyle(fontSize: 13)),
                  Text('Ammo: ${gameState.ammo}', style: const TextStyle(fontSize: 13, color: Colors.amber)),
                  Text('Civilians: ${gameState.civiliansRescued}', style: const TextStyle(fontSize: 13, color: Colors.greenAccent)),
                  Text('SubBases: ${gameState.subBaseUnlocksAvailable}', style: const TextStyle(fontSize: 13, color: Colors.cyanAccent)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Legend & Controls',
                  onPressed: () => _showLegendDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  tooltip: 'Pause',
                  onPressed: () {
                    gameState.pauseGame();
                    _showPauseDialog(context, gameState);
                  },
                )
              ],
            ),
            body: Column(
              children: [
                // Game Grid
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: GameState.gridWidth / GameState.gridHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.gridLineColor, width: 2),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double cellWidth = constraints.maxWidth / GameState.gridWidth;
                            double cellHeight = constraints.maxHeight / GameState.gridHeight;

                            return Stack(
                              children: [
                                // Render Grid Cells
                                for (int y = 0; y < GameState.gridHeight; y++)
                                  for (int x = 0; x < GameState.gridWidth; x++)
                                    Positioned(
                                      left: x * cellWidth,
                                      top: y * cellHeight,
                                      width: cellWidth,
                                      height: cellHeight,
                                      child: GestureDetector(
                                        onTap: () {
                                          int dx = x - gameState.protagonist.x;
                                          int dy = y - gameState.protagonist.y;
                                          if (dx.abs() + dy.abs() == 1) {
                                            gameState.moveProtagonist(dx, dy);
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _getCellColor(gameState.grid[y][x], theme),
                                            border: Border.all(color: theme.gridLineColor.withValues(alpha: 0.5), width: 0.5),
                                          ),
                                          child: _getCellChild(gameState.grid[y][x]),
                                        ),
                                      ),
                                    ),

                                // Render Enemies
                                for (var enemy in gameState.enemies)
                                  Positioned(
                                    left: enemy.x * cellWidth,
                                    top: enemy.y * cellHeight,
                                    width: cellWidth,
                                    height: cellHeight,
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.enemyColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),

                                // Render Protagonist
                                Positioned(
                                  left: gameState.protagonist.x * cellWidth,
                                  top: gameState.protagonist.y * cellHeight,
                                  width: cellWidth,
                                  height: cellHeight,
                                  child: Center(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.protagonistColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.person, color: Colors.black, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom On-Screen Controls
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.black87,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700]),
                        onPressed: () => gameState.buildWallAtProtagonist(),
                        icon: const Icon(Icons.home),
                        label: const Text('Build (C)'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                        onPressed: () => gameState.removeWallAtProtagonist(),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove (X)'),
                      ),
                      if (gameState.subBaseUnlocksAvailable > 0)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                          onPressed: () => gameState.buildSubBase(),
                          icon: const Icon(Icons.security),
                          label: Text('Sub-Base (B)'),
                        ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                        onPressed: () => gameState.disinfectAdjacentCell(),
                        icon: const Icon(Icons.cleaning_services),
                        label: const Text('Disinfect (F)'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => gameState.shootEnemy(),
                        icon: const Icon(Icons.local_fire_department),
                        label: const Text('Shoot (J)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCellColor(Cell cell, dynamic theme) {
    if (cell.isProtected && cell.type == CellType.empty) {
      return Colors.green.withValues(alpha: 0.3);
    }
    switch (cell.type) {
      case CellType.empty:
        return theme.emptyCellColor;
      case CellType.wall:
        return theme.wallColor;
      case CellType.infection:
        return theme.infectionColor;
      case CellType.infectionSource:
        return theme.infectionSourceColor;
      case CellType.civilian:
        return theme.civilianColor;
      case CellType.hostageCorrupted:
        return theme.corruptedColor;
      case CellType.base:
        return theme.baseColor;
      case CellType.subBase:
        return theme.subBaseColor;
    }
  }

  Widget? _getCellChild(Cell cell) {
    switch (cell.type) {
      case CellType.civilian:
        return const Icon(Icons.face, color: Colors.black, size: 14);
      case CellType.base:
        return const Icon(Icons.shield, color: Colors.white, size: 16);
      case CellType.subBase:
        return const Icon(Icons.security, color: Colors.white, size: 14);
      case CellType.infectionSource:
        return const Icon(Icons.coronavirus, color: Colors.black, size: 14);
      default:
        return null;
    }
  }

  void _showPauseDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Paused'),
        content: const Text('Take a breather or adjust strategy.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameState.resumeGame();
            },
            child: const Text('Resume'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameState.quitToMenu();
              Navigator.pop(context);
            },
            child: const Text('Quit to Menu'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over', style: TextStyle(color: Colors.red)),
        content: Text('All bases were destroyed!\nFinal Score: ${gameState.score}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameState.quitToMenu();
              Navigator.pop(context);
            },
            child: const Text('Main Menu'),
          ),
        ],
      ),
    );
  }
}
