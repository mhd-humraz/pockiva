import 'package:flutter/material.dart';

/// Simple placeholder screen for games not yet implemented.
class PlaceholderGameScreen extends StatelessWidget {
  final String title;
  const PlaceholderGameScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: Center(
        child: Text('Placeholder for $title', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
