import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics & Records')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.leaderboard, size: 80, color: Colors.amber),
            SizedBox(height: 20),
            Text('High Score: 2,450', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Total Civilians Rescued: 42', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Sub-Bases Established: 12', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
