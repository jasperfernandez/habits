import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/services/notification_permission_service.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/habits/application/controllers/habits_controller.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/enums/habit_frequency.dart';
import 'package:habits/features/settings/application/settings_controller.dart';
import 'package:habits/features/settings/data/preferences_service.dart';
import 'package:habits/features/settings/presentation/screens/settings_screen.dart';

class _FakeHabitsController extends HabitsController {
  _FakeHabitsController(this._habits);
  final List<Habit> _habits;

  @override
  Stream<List<Habit>> build() => Stream.value(_habits);
}

class _FakeNotificationPermissionService implements NotificationPermissionService {
  _FakeNotificationPermissionService({
    this.resultToReturn = NotificationPermissionResult.granted,
  });

  NotificationPermissionResult resultToReturn;
  bool requestCalled = false;
  bool openSettingsCalled = false;

  @override
  Future<NotificationPermissionResult> requestPermission() async {
    requestCalled = true;
    return resultToReturn;
  }

  @override
  Future<bool> isGranted() async {
    return resultToReturn == NotificationPermissionResult.granted;
  }

  @override
  Future<bool> openAppSettings() async {
    openSettingsCalled = true;
    return true;
  }
}

void main() {
  group('SettingsScreen', () {
    final sampleHabits = [
      Habit(
        id: 'h1',
        name: 'Meditation',
        frequency: HabitFrequency.daily,
        scheduledWeekdays: const {},
        createdAt: DateTime(2026, 10, 1),
        startDate: DateTime(2026, 10, 1),
      ),
      Habit(
        id: 'h2',
        name: 'Running',
        frequency: HabitFrequency.daily,
        scheduledWeekdays: const {},
        createdAt: DateTime(2026, 9, 1),
        startDate: DateTime(2026, 9, 1),
        archivedAt: DateTime(2026, 10, 1),
      ),
    ];

    testWidgets('renders profile, preferences, stats, and about sections', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController(sampleHabits),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Jasper'), findsOneWidget);
      expect(find.text('Daily Reminders'), findsOneWidget);
      expect(find.text('Active Habits'), findsOneWidget);
      expect(find.text('Total Tracked'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // active
      expect(find.text('2'), findsOneWidget); // total
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('allows editing user name in dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController([]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Edit Greeting Name'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Alex'), findsOneWidget);
    });

    testWidgets('requests OS permission when toggling daily reminders ON and enables on grant', (tester) async {
      final fakePermissionService = _FakeNotificationPermissionService(
        resultToReturn: NotificationPermissionResult.granted,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController([]),
            ),
            notificationPermissionServiceProvider.overrideWithValue(
              fakePermissionService,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find switch tile for Daily Reminders
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      // Verify currently false
      Switch switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);

      // Tap to toggle ON
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(fakePermissionService.requestCalled, isTrue);
      switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);
      expect(find.text('Daily reminders enabled!'), findsOneWidget);
    });

    testWidgets('shows warning and keeps switch off when permission is denied', (tester) async {
      final fakePermissionService = _FakeNotificationPermissionService(
        resultToReturn: NotificationPermissionResult.denied,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController([]),
            ),
            notificationPermissionServiceProvider.overrideWithValue(
              fakePermissionService,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(fakePermissionService.requestCalled, isTrue);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);
      expect(find.text('Notification permission was not granted.'), findsOneWidget);
    });

    testWidgets('shows settings action when permission is permanently denied', (tester) async {
      final fakePermissionService = _FakeNotificationPermissionService(
        resultToReturn: NotificationPermissionResult.permanentlyDenied,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController([]),
            ),
            notificationPermissionServiceProvider.overrideWithValue(
              fakePermissionService,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(fakePermissionService.requestCalled, isTrue);
      expect(find.text('Settings'), findsNWidgets(2)); // AppBar title + SnackBar action

      // Tap the SnackBar "Settings" action
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();

      expect(fakePermissionService.openSettingsCalled, isTrue);
    });

    testWidgets('shows reminder time tile when daily reminders is ON', (tester) async {
      final inMemory = InMemoryPreferencesService(
        initialNotificationEnabled: true,
        initialReminderTime: const TimeOfDay(hour: 9, minute: 0),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController([]),
            ),
            preferencesServiceProvider.overrideWithValue(inMemory),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Reminder Time'), findsOneWidget);
      expect(find.text('When to receive your daily habit reminder'), findsOneWidget);
    });
  });
}
