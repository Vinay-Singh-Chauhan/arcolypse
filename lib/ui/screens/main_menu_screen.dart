import 'package:flutter/material.dart';
import '../../main.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'stats_screen.dart';
import 'terms_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String selectedTheme = 'Zombies';

  void _showHowToPlayPopup(BuildContext context, VoidCallback onStartGame) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎮 How to Play & Controls'),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Objective:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Contain infection, rescue civilians, build protective enclosures (green zones), and defend your bases!\n'),
                Text('Map Legend & Symbols:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('• ⚪ Protagonist: You! Move with WASD/Arrows (hold to move continuously).'),
                Text('• 🟥 Enemy: Zombies / Terrorists attacking your bases.'),
                Text('• 🟫 Wall: Construct with C (or Space) | Demolish with X.'),
                Text('• 🟩 Protected Zone: Enclosed safe area.'),
                Text('• 🟧 Infection: Disinfect with F key.'),
                Text('• 🦠 Infection Source: Enclose fully in walls to cleanse/neutralize.'),
                Text('• 👤 Civilian: Rescue them (3 rescues = 1 Sub-Base token).'),
                Text('• 🛡️ Main Base: Core base (100% health).'),
                Text('• 🛡️ Sub-Base: Build with B key on protected empty cells (75% health).\n'),
                Text('Keyboard Shortcuts:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('• Move: WASD / Arrow Keys (Continuous hold)'),
                Text('• Construct Wall: C or Space'),
                Text('• Demolish Wall: X'),
                Text('• Build Sub-Base: B'),
                Text('• Disinfect: F'),
                Text('• Shoot: J'),
                Text('• Pause: Esc'),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              onStartGame();
            },
            child: const Text('Start Surviving!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.gameState;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ARCOLYPSE',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Grid Survival & Containment',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 40),

              // Theme Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Theme: ', style: TextStyle(color: Colors.white, fontSize: 16)),
                  DropdownButton<String>(
                    value: selectedTheme,
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'Zombies', child: Text('🧟 Zombies')),
                      DropdownMenuItem(value: 'Insurgency', child: Text('🪖 Insurgency')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedTheme = val;
                        });
                        gameState.setTheme(val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Menu Buttons
              _MenuButton(
                text: 'Start Game',
                icon: Icons.play_arrow,
                onPressed: () {
                  _showHowToPlayPopup(context, () {
                    gameState.startGame();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  });
                },
              ),
              const SizedBox(height: 15),
              _MenuButton(
                text: 'How to Play',
                icon: Icons.help_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                  );
                },
              ),
              const SizedBox(height: 15),
              _MenuButton(
                text: 'Stats',
                icon: Icons.bar_chart,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                  );
                },
              ),
              const SizedBox(height: 15),
              _MenuButton(
                text: 'Terms & Conditions',
                icon: Icons.description,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 300, minHeight: 50),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[900],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
