import 'package:flutter/services.dart';

class HapticUtils {
  /// Light impact for subtle feedback (e.g., tapping info buttons)
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact for standard interactions (e.g., opening tooltips)
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact for important actions (e.g., acknowledging risks)
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click for toggles and switches
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for warnings or errors
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
