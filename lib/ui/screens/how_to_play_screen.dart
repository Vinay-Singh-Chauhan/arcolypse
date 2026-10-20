import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Play')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text('🎮 Game Rules & Objectives', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('• Larger Grid Space: Navigate the tactical grid with WASD/Arrow keys (hold down to move continuously).'),
            Text('• Walls & Enclosures: Construct walls around cells to create protected enclosures (highlighted in green). Enclosed infection sources are automatically cleansed and neutralized!'),
            Text('• Infection Spread: Infection spreads slowly from sources. If an infection reaches a civilian before rescue, they turn into enemies.'),
            Text('• Civilians & Sub-Bases: Rescue civilians to earn Sub-Base tokens (1 token per 3 rescues). Build sub-bases on protected empty cells (75% health).'),
            Text('• Disinfection: Use the chemical sprayer to disinfect adjacent infected cells.'),
            Text('• Ammo & Combat: Use your weapon to eliminate nearby enemies. Ammo regenerates based on active bases.'),
            SizedBox(height: 20),
            Text('⌨️ Keyboard Controls & Shortcuts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('• Move: WASD / Arrow Keys (Hold to move continuously)'),
            Text('• Construct Wall: C or Spacebar'),
            Text('• Demolish Wall: X'),
            Text('• Build Sub-Base: B (when standing on protected empty cell with token)'),
            Text('• Disinfect: F (cleanses adjacent infection cells)'),
            Text('• Shoot Enemy: J'),
            Text('• Pause: Esc'),
          ],
        ),
      ),
    );
  }
}
