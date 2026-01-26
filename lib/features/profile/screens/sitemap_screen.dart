import 'package:flutter/material.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Sitemap')),
      body: const Center(child: Text('Sitemap')),
    );
  }
}
