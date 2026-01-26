import 'package:flutter/material.dart';

class PropertyTourScreen extends StatelessWidget {
  const PropertyTourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Tour')),
      body: const Center(child: Text('Immersive 3D Tour')),
    );
  }
}
