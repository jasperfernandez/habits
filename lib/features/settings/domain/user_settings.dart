import 'package:flutter/material.dart';

class UserSettings {
  final String? userName;
  final ThemeMode themeMode;
  final bool notificationEnabled;
  final TimeOfDay reminderTime;

  const UserSettings({
    this.userName,
    this.themeMode = ThemeMode.light,
    this.notificationEnabled = false,
    this.reminderTime = const TimeOfDay(hour: 9, minute: 0),
  });

  bool get hasCompletedOnboarding =>
      userName != null && userName!.trim().isNotEmpty;

  UserSettings copyWith({
    String? userName,
    ThemeMode? themeMode,
    bool? notificationEnabled,
    TimeOfDay? reminderTime,
  }) {
    return UserSettings(
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
