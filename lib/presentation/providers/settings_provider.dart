import 'package:flutter/material.dart';
import '../../data/datasources/prefs_datasource.dart';

class SettingsProvider extends ChangeNotifier {
  final PrefsDataSource _prefs;

  late String _themeMode;
  late bool _soundEnabled;
  late bool _notificationEnabled;
  final Map<String, bool> _blockedCategories = {
    'Social Media': true,
    'Video Streaming': true,
    'Games': false,
    'News': false,
  };

  SettingsProvider(this._prefs) {
    _themeMode = _prefs.themeMode;
    _soundEnabled = _prefs.soundEnabled;
    _notificationEnabled = _prefs.notificationEnabled;
  }

  String get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  bool get notificationEnabled => _notificationEnabled;
  Map<String, bool> get blockedCategories => _blockedCategories;

  ThemeMode get currentThemeMode {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs.setSoundEnabled(value);
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool value) async {
    _notificationEnabled = value;
    await _prefs.setNotificationEnabled(value);
    notifyListeners();
  }

  void toggleBlockedCategory(String category) {
    _blockedCategories[category] = !(_blockedCategories[category] ?? false);
    notifyListeners();
  }

  List<String> getActiveBlockedCategories() {
    return _blockedCategories.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
  }
}
