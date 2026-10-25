import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/preferences_service.dart';
import '../domain/user_settings.dart';

part 'settings_controller.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences? sharedPreferences(Ref ref) {
  return null;
}

@Riverpod(keepAlive: true)
PreferencesService preferencesService(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  if (prefs != null) {
    return SharedPreferencesService(prefs);
  }
  return InMemoryPreferencesService();
}

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  @override
  UserSettings build() {
    final service = ref.watch(preferencesServiceProvider);
    return UserSettings(
      userName: service.getUserName(),
      themeMode: service.getThemeMode(),
      notificationEnabled: service.getNotificationEnabled(),
    );
  }

  Future<void> setUserName(String name) async {
    final service = ref.read(preferencesServiceProvider);
    final trimmed = name.trim();
    await service.setUserName(trimmed);
    state = state.copyWith(userName: trimmed);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final service = ref.read(preferencesServiceProvider);
    await service.setThemeMode(themeMode);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final service = ref.read(preferencesServiceProvider);
    await service.setNotificationEnabled(enabled);
    state = state.copyWith(notificationEnabled: enabled);
  }

  Future<void> clear() async {
    final service = ref.read(preferencesServiceProvider);
    await service.clear();
    state = const UserSettings(
      userName: null,
      themeMode: ThemeMode.light,
      notificationEnabled: true,
    );
  }
}
