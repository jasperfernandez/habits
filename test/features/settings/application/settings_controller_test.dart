import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/settings/application/settings_controller.dart';
import 'package:habits/features/settings/data/preferences_service.dart';

void main() {
  group('SettingsController', () {
    test('initializes with default preferences when empty', () {
      final containerRef = ProviderContainer(
        overrides: [
          preferencesServiceProvider.overrideWithValue(
            InMemoryPreferencesService(),
          ),
        ],
      );

      final settings = containerRef.read(settingsControllerProvider);
      expect(settings.userName, isNull);
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.notificationEnabled, isTrue);
      expect(settings.hasCompletedOnboarding, isFalse);
    });

    test('updates user name and marks onboarding completed', () async {
      final containerRef = ProviderContainer(
        overrides: [
          preferencesServiceProvider.overrideWithValue(
            InMemoryPreferencesService(),
          ),
        ],
      );

      await containerRef
          .read(settingsControllerProvider.notifier)
          .setUserName('Jasper');

      final settings = containerRef.read(settingsControllerProvider);
      expect(settings.userName, 'Jasper');
      expect(settings.hasCompletedOnboarding, isTrue);
    });

    test('updates theme mode and notification preferences', () async {
      final containerRef = ProviderContainer(
        overrides: [
          preferencesServiceProvider.overrideWithValue(
            InMemoryPreferencesService(),
          ),
        ],
      );

      await containerRef
          .read(settingsControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      await containerRef
          .read(settingsControllerProvider.notifier)
          .setNotificationEnabled(false);

      final settings = containerRef.read(settingsControllerProvider);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.notificationEnabled, isFalse);
    });

    test('clearing preferences resets state', () async {
      final inMemory = InMemoryPreferencesService(
        initialUserName: 'Jasper',
        initialThemeMode: ThemeMode.dark,
        initialNotificationEnabled: false,
      );

      final containerRef = ProviderContainer(
        overrides: [
          preferencesServiceProvider.overrideWithValue(inMemory),
        ],
      );

      expect(
        containerRef.read(settingsControllerProvider).hasCompletedOnboarding,
        isTrue,
      );

      await containerRef.read(settingsControllerProvider.notifier).clear();

      final settings = containerRef.read(settingsControllerProvider);
      expect(settings.userName, isNull);
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.notificationEnabled, isTrue);
      expect(settings.hasCompletedOnboarding, isFalse);
    });
  });
}
