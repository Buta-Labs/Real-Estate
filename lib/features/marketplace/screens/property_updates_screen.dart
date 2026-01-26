import 'package:flutter/material.dart';

class PropertyUpdatesScreen extends StatelessWidget {
  const PropertyUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Updates')),
      body: const Center(child: Text('Construction Updates & Milestones')),
    );
  }
}
