import 'package:flutter/material.dart';

/// Simple placeholder screen used for actions that are not yet implemented.
class PlaceholderActionScreen extends StatelessWidget {
  final String title;
  const PlaceholderActionScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: const Center(
        child: Text('Coming in a next phase', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
