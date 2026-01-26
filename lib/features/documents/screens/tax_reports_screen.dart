import 'package:flutter/material.dart';

class TaxReportsScreen extends StatelessWidget {
  const TaxReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax & Reporting')),
      body: const Center(child: Text('Tax Reports')),
    );
  }
}
