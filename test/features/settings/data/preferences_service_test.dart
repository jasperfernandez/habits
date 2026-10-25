import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/settings/data/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesService', () {
    test('reads default values when preferences are empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SharedPreferencesService(prefs);

      expect(service.getUserName(), isNull);
      expect(service.getThemeMode(), ThemeMode.light);
      expect(service.getNotificationEnabled(), isFalse);
    });

    test('stores and retrieves user name', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SharedPreferencesService(prefs);

      await service.setUserName('Alice');
      expect(service.getUserName(), 'Alice');
      expect(prefs.getString('user_name'), 'Alice');
    });

    test('stores and retrieves theme mode', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SharedPreferencesService(prefs);

      await service.setThemeMode(ThemeMode.dark);
      expect(service.getThemeMode(), ThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');

      await service.setThemeMode(ThemeMode.light);
      expect(service.getThemeMode(), ThemeMode.light);
      expect(prefs.getString('theme_mode'), 'light');
    });

    test('stores and retrieves notification_enabled', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SharedPreferencesService(prefs);

      await service.setNotificationEnabled(false);
      expect(service.getNotificationEnabled(), isFalse);
      expect(prefs.getBool('notification_enabled'), isFalse);

      await service.setNotificationEnabled(true);
      expect(service.getNotificationEnabled(), isTrue);
      expect(prefs.getBool('notification_enabled'), isTrue);
    });

    test('stores and retrieves reminder time', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = SharedPreferencesService(prefs);

      expect(service.getReminderTime(), const TimeOfDay(hour: 9, minute: 0));

      await service.setReminderTime(const TimeOfDay(hour: 20, minute: 30));
      expect(service.getReminderTime(), const TimeOfDay(hour: 20, minute: 30));
      expect(prefs.getInt('reminder_hour'), 20);
      expect(prefs.getInt('reminder_minute'), 30);
    });

    test('clears all preferences', () async {
      SharedPreferences.setMockInitialValues({
        'user_name': 'Alice',
        'theme_mode': 'dark',
        'notification_enabled': false,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = SharedPreferencesService(prefs);

      await service.clear();

      expect(service.getUserName(), isNull);
      expect(service.getThemeMode(), ThemeMode.light);
      expect(service.getNotificationEnabled(), isFalse);
    });
  });

  group('InMemoryPreferencesService', () {
    test('stores and retrieves in-memory settings', () async {
      final service = InMemoryPreferencesService();

      expect(service.getUserName(), isNull);
      expect(service.getThemeMode(), ThemeMode.light);
      expect(service.getNotificationEnabled(), isFalse);
      expect(service.getReminderTime(), const TimeOfDay(hour: 9, minute: 0));

      await service.setUserName('Bob');
      await service.setThemeMode(ThemeMode.dark);
      await service.setNotificationEnabled(false);
      await service.setReminderTime(const TimeOfDay(hour: 7, minute: 15));

      expect(service.getUserName(), 'Bob');
      expect(service.getThemeMode(), ThemeMode.dark);
      expect(service.getNotificationEnabled(), isFalse);
      expect(service.getReminderTime(), const TimeOfDay(hour: 7, minute: 15));

      await service.clear();
      expect(service.getUserName(), isNull);
      expect(service.getThemeMode(), ThemeMode.light);
      expect(service.getNotificationEnabled(), isFalse);
      expect(service.getReminderTime(), const TimeOfDay(hour: 9, minute: 0));
    });
  });
}
