import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesService {
  String? getUserName();
  Future<void> setUserName(String name);

  ThemeMode getThemeMode();
  Future<void> setThemeMode(ThemeMode themeMode);

  bool getNotificationEnabled();
  Future<void> setNotificationEnabled(bool enabled);

  Future<void> clear();
}

class SharedPreferencesService implements PreferencesService {
  const SharedPreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const String keyUserName = 'user_name';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationEnabled = 'notification_enabled';

  @override
  String? getUserName() {
    return _prefs.getString(keyUserName);
  }

  @override
  Future<void> setUserName(String name) async {
    await _prefs.setString(keyUserName, name);
  }

  @override
  ThemeMode getThemeMode() {
    final value = _prefs.getString(keyThemeMode);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final String value;
    switch (themeMode) {
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
        value = 'system';
        break;
      case ThemeMode.light:
        value = 'light';
        break;
    }
    await _prefs.setString(keyThemeMode, value);
  }

  @override
  bool getNotificationEnabled() {
    return _prefs.getBool(keyNotificationEnabled) ?? true;
  }

  @override
  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs.setBool(keyNotificationEnabled, enabled);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(keyUserName);
    await _prefs.remove(keyThemeMode);
    await _prefs.remove(keyNotificationEnabled);
  }
}

class InMemoryPreferencesService implements PreferencesService {
  InMemoryPreferencesService({
    String? initialUserName,
    ThemeMode initialThemeMode = ThemeMode.light,
    bool initialNotificationEnabled = true,
  })  : _userName = initialUserName,
        _themeMode = initialThemeMode,
        _notificationEnabled = initialNotificationEnabled;

  String? _userName;
  ThemeMode _themeMode;
  bool _notificationEnabled;

  @override
  String? getUserName() => _userName;

  @override
  Future<void> setUserName(String name) async {
    _userName = name;
  }

  @override
  ThemeMode getThemeMode() => _themeMode;

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
  }

  @override
  bool getNotificationEnabled() => _notificationEnabled;

  @override
  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationEnabled = enabled;
  }

  @override
  Future<void> clear() async {
    _userName = null;
    _themeMode = ThemeMode.light;
    _notificationEnabled = true;
  }
}
