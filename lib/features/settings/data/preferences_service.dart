import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PreferencesService {
  String? getUserName();
  Future<void> setUserName(String name);

  ThemeMode getThemeMode();
  Future<void> setThemeMode(ThemeMode themeMode);

  bool getNotificationEnabled();
  Future<void> setNotificationEnabled(bool enabled);

  TimeOfDay getReminderTime();
  Future<void> setReminderTime(TimeOfDay time);

  Future<void> clear();
}

class SharedPreferencesService implements PreferencesService {
  const SharedPreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const String keyUserName = 'user_name';
  static const String keyThemeMode = 'theme_mode';
  static const String keyNotificationEnabled = 'notification_enabled';
  static const String keyReminderHour = 'reminder_hour';
  static const String keyReminderMinute = 'reminder_minute';

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
    return _prefs.getBool(keyNotificationEnabled) ?? false;
  }

  @override
  Future<void> setNotificationEnabled(bool enabled) async {
    await _prefs.setBool(keyNotificationEnabled, enabled);
  }

  @override
  TimeOfDay getReminderTime() {
    final hour = _prefs.getInt(keyReminderHour) ?? 9;
    final minute = _prefs.getInt(keyReminderMinute) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Future<void> setReminderTime(TimeOfDay time) async {
    await _prefs.setInt(keyReminderHour, time.hour);
    await _prefs.setInt(keyReminderMinute, time.minute);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(keyUserName);
    await _prefs.remove(keyThemeMode);
    await _prefs.remove(keyNotificationEnabled);
    await _prefs.remove(keyReminderHour);
    await _prefs.remove(keyReminderMinute);
  }
}

class InMemoryPreferencesService implements PreferencesService {
  InMemoryPreferencesService({
    String? initialUserName,
    ThemeMode initialThemeMode = ThemeMode.light,
    bool initialNotificationEnabled = false,
    TimeOfDay initialReminderTime = const TimeOfDay(hour: 9, minute: 0),
  }) : _userName = initialUserName,
       _themeMode = initialThemeMode,
       _notificationEnabled = initialNotificationEnabled,
       _reminderTime = initialReminderTime;

  String? _userName;
  ThemeMode _themeMode;
  bool _notificationEnabled;
  TimeOfDay _reminderTime;

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
  TimeOfDay getReminderTime() => _reminderTime;

  @override
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
  }

  @override
  Future<void> clear() async {
    _userName = null;
    _themeMode = ThemeMode.light;
    _notificationEnabled = false;
    _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  }
}
