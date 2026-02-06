import 'package:flutter/material.dart';

enum RiskLevel { low, medium, high, verified }

class RiskMetric {
  final String id;
  final String title;
  final String description;
  final RiskLevel level;
  final int score; // 0-100 for progress bar
  final String? subtitle;
  final Color color;
  final IconData icon;
  final String? tooltipTitle;
  final String? tooltipContent;
  final String? actionLabel;
  final String? actionUrl;

  RiskMetric({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    this.score = 50,
    this.subtitle,
    required this.color,
    required this.icon,
    this.tooltipTitle,
    this.tooltipContent,
    this.actionLabel,
    this.actionUrl,
  });

  String get levelText {
    switch (level) {
      case RiskLevel.low:
        return 'LOW';
      case RiskLevel.medium:
        return 'MEDIUM';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.verified:
        return 'VERIFIED';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level.toString(),
      'score': score,
      'subtitle': subtitle,
      'tooltipTitle': tooltipTitle,
      'tooltipContent': tooltipContent,
      'actionLabel': actionLabel,
      'actionUrl': actionUrl,
    };
  }

  factory RiskMetric.fromMap(Map<String, dynamic> map) {
    return RiskMetric(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      level: _parseLevelFromString(map['level']),
      score: map['score'] ?? 50,
      subtitle: map['subtitle'],
      color: Colors.orange, // Default, will be overridden
      icon: Icons.info, // Default
      tooltipTitle: map['tooltipTitle'],
      tooltipContent: map['tooltipContent'],
      actionLabel: map['actionLabel'],
      actionUrl: map['actionUrl'],
    );
  }

  static RiskLevel _parseLevelFromString(String? levelStr) {
    if (levelStr == null) return RiskLevel.medium;
    if (levelStr.contains('low')) return RiskLevel.low;
    if (levelStr.contains('high')) return RiskLevel.high;
    if (levelStr.contains('verified')) return RiskLevel.verified;
    return RiskLevel.medium;
  }
}
