import 'package:flutter/material.dart';

class DigitalKeyScreen extends StatelessWidget {
  const DigitalKeyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guest Access')),
      body: const Center(child: Text('Digital Key / Guest Access')),
    );
  }
}
