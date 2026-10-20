import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text('Terms of Service', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('By playing Arcolypse, you agree to survive the outbreak, defend your bases, and follow the strategic rules of grid containment. All rights reserved for web and Android deployments.'),
          ],
        ),
      ),
    );
  }
}
