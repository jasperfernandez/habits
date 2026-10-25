import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/services/local_notification_service.dart';
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
      expect(settings.notificationEnabled, isFalse);
      expect(settings.reminderTime, const TimeOfDay(hour: 9, minute: 0));
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

    test('schedules and cancels local notification reminder', () async {
      final fakeNotifications = FakeLocalNotificationService();
      final containerRef = ProviderContainer(
        overrides: [
          preferencesServiceProvider.overrideWithValue(
            InMemoryPreferencesService(),
          ),
          localNotificationServiceProvider.overrideWithValue(fakeNotifications),
        ],
      );

      // Enabling notifications schedules daily reminder
      await containerRef
          .read(settingsControllerProvider.notifier)
          .setNotificationEnabled(true);

      expect(
        containerRef.read(settingsControllerProvider).notificationEnabled,
        isTrue,
      );
      expect(
        fakeNotifications.scheduledTime,
        const TimeOfDay(hour: 9, minute: 0),
      );
      expect(fakeNotifications.scheduledTitle, contains('habits'));

      // Changing reminder time when enabled reschedules with new time
      await containerRef
          .read(settingsControllerProvider.notifier)
          .setReminderTime(const TimeOfDay(hour: 21, minute: 15));

      expect(
        containerRef.read(settingsControllerProvider).reminderTime,
        const TimeOfDay(hour: 21, minute: 15),
      );
      expect(
        fakeNotifications.scheduledTime,
        const TimeOfDay(hour: 21, minute: 15),
      );

      // Disabling notifications cancels scheduled reminder
      await containerRef
          .read(settingsControllerProvider.notifier)
          .setNotificationEnabled(false);

      expect(
        containerRef.read(settingsControllerProvider).notificationEnabled,
        isFalse,
      );
      expect(fakeNotifications.canceled, isTrue);
      expect(fakeNotifications.scheduledTime, isNull);
    });

    test('clearing preferences resets state', () async {
      final inMemory = InMemoryPreferencesService(
        initialUserName: 'Jasper',
        initialThemeMode: ThemeMode.dark,
        initialNotificationEnabled: false,
      );

      final containerRef = ProviderContainer(
        overrides: [preferencesServiceProvider.overrideWithValue(inMemory)],
      );

      expect(
        containerRef.read(settingsControllerProvider).hasCompletedOnboarding,
        isTrue,
      );

      await containerRef.read(settingsControllerProvider.notifier).clear();

      final settings = containerRef.read(settingsControllerProvider);
      expect(settings.userName, isNull);
      expect(settings.themeMode, ThemeMode.light);
      expect(settings.notificationEnabled, isFalse);
      expect(settings.hasCompletedOnboarding, isFalse);
    });
  });
}
