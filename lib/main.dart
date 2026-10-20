import 'package:flutter/material.dart';
import 'models/game_state.dart';
import 'ui/screens/main_menu_screen.dart';

void main() {
  runApp(const ArcolypseApp());
}

class GameStateScope extends InheritedNotifier<GameState> {
  const GameStateScope({
    super.key,
    required GameState gameState,
    required super.child,
  }) : super(notifier: gameState);

  static GameState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GameStateScope>()!.notifier!;
  }
}

class ArcolypseApp extends StatefulWidget {
  const ArcolypseApp({super.key});

  @override
  State<ArcolypseApp> createState() => _ArcolypseAppState();
}

class _ArcolypseAppState extends State<ArcolypseApp> {
  final GameState _gameState = GameState();

  @override
  Widget build(BuildContext context) {
    return GameStateScope(
      gameState: _gameState,
      child: MaterialApp(
        title: 'Arcolypse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}

// Extension for easy Provider-like access without external dependencies
extension GameStateContext on BuildContext {
  GameState get gameState => GameStateScope.of(this);
}
