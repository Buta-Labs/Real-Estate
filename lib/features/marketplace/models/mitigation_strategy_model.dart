import 'package:flutter/material.dart';

class MitigationStrategy {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String? actionLabel;
  final String? actionUrl;
  final bool isHighlighted;

  MitigationStrategy({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.actionLabel,
    this.actionUrl,
    this.isHighlighted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'actionLabel': actionLabel,
      'actionUrl': actionUrl,
      'isHighlighted': isHighlighted,
    };
  }

  factory MitigationStrategy.fromMap(Map<String, dynamic> map) {
    return MitigationStrategy(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: Icons.shield, // Default
      iconColor: Colors.green, // Default
      actionLabel: map['actionLabel'],
      actionUrl: map['actionUrl'],
      isHighlighted: map['isHighlighted'] ?? false,
    );
  }
}
