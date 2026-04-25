import 'package:shared_preferences/shared_preferences.dart';

class PrefsDataSource {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _themeKey = 'theme_mode';
  static const String _soundKey = 'sound_enabled';
  static const String _notificationKey = 'notification_enabled';
  static const String _streakKey = 'streak_count';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth
  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;
  String get userEmail => _prefs.getString(_userEmailKey) ?? '';
  String get userName => _prefs.getString(_userNameKey) ?? '';

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_isLoggedInKey, value);
  }

  Future<void> setUserEmail(String email) async {
    await _prefs.setString(_userEmailKey, email);
  }

  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  // Settings
  String get themeMode => _prefs.getString(_themeKey) ?? 'dark';
  bool get soundEnabled => _prefs.getBool(_soundKey) ?? true;
  bool get notificationEnabled => _prefs.getBool(_notificationKey) ?? true;

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_themeKey, mode);
  }

  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(_soundKey, value);
  }

  Future<void> setNotificationEnabled(bool value) async {
    await _prefs.setBool(_notificationKey, value);
  }

  // Streak
  int get streakCount => _prefs.getInt(_streakKey) ?? 0;

  Future<void> setStreakCount(int count) async {
    await _prefs.setInt(_streakKey, count);
  }

  Future<void> incrementStreak() async {
    await _prefs.setInt(_streakKey, streakCount + 1);
  }

  Future<void> resetStreak() async {
    await _prefs.setInt(_streakKey, 0);
  }

  // Clear
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
