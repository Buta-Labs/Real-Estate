import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Initial default pins matching App.tsx
const List<String> _kDefaultPins = [
  'analytics',
  'learning',
  'insights',
  'referrals',
];
const String _kPrefsKey = 'pinnedViews';

final pinnedViewsProvider = NotifierProvider<PinnedViewsNotifier, List<String>>(
  PinnedViewsNotifier.new,
);

class PinnedViewsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    _loadPins();
    return _kDefaultPins;
  }

  Future<void> _loadPins() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_kPrefsKey);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> togglePin(String viewId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> newState;
    if (state.contains(viewId)) {
      newState = state.where((id) => id != viewId).toList();
    } else {
      newState = [...state, viewId];
    }
    state = newState;
    await prefs.setStringList(_kPrefsKey, newState);
  }
}
