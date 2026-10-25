import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/habits/application/controllers/habits_controller.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/enums/habit_frequency.dart';
import 'package:habits/features/settings/presentation/screens/settings_screen.dart';

class _FakeHabitsController extends HabitsController {
  _FakeHabitsController(this._habits);
  final List<Habit> _habits;

  @override
  Stream<List<Habit>> build() => Stream.value(_habits);
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
  });
}
