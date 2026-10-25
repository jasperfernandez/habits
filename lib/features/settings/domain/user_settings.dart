import 'package:flutter/material.dart';

class UserSettings {
  final String? userName;
  final ThemeMode themeMode;
  final bool notificationEnabled;

  const UserSettings({
    this.userName,
    this.themeMode = ThemeMode.light,
    this.notificationEnabled = true,
  });

  bool get hasCompletedOnboarding =>
      userName != null && userName!.trim().isNotEmpty;

  UserSettings copyWith({
    String? userName,
    ThemeMode? themeMode,
    bool? notificationEnabled,
  }) {
    return UserSettings(
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    );
  }
}
