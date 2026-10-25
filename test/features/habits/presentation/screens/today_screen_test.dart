import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/habits/application/controllers/habits_controller.dart';
import 'package:habits/features/habits/application/providers/habit_providers.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/entities/habit_completion.dart';
import 'package:habits/features/habits/domain/enums/habit_frequency.dart';
import 'package:habits/features/habits/presentation/screens/today_screen.dart';
import 'package:habits/features/habits/presentation/widgets/daily_progress_header.dart';
import 'package:habits/features/habits/presentation/widgets/habit_card.dart';

class _FakeHabitsController extends HabitsController {
  _FakeHabitsController(this._habits);
  final List<Habit> _habits;

  @override
  Stream<List<Habit>> build() => Stream.value(_habits);

  @override
  Future<void> toggleCompletion({
    required String habitId,
    required DateTime date,
    required bool isCurrentlyCompleted,
  }) async {}
}

void main() {
  group('TodayScreen', () {
    testWidgets('shows empty state when no habits exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController([]),
            ),
            completionsForDateProvider.overrideWith(
              (ref, date) => Stream.value(<HabitCompletion>[]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const TodayScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DailyProgressHeader), findsOneWidget);
      expect(find.text('No habits yet'), findsOneWidget);
      expect(find.text('Create Habit'), findsOneWidget);
    });

    testWidgets('renders habit cards for scheduled habits', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final habits = [
        Habit(
          id: 'h1',
          name: 'Morning Jog',
          frequency: HabitFrequency.daily,
          scheduledWeekdays: const {},
          createdAt: today,
          startDate: today,
        ),
        Habit(
          id: 'h2',
          name: 'Drink Water',
          frequency: HabitFrequency.daily,
          scheduledWeekdays: const {},
          createdAt: today,
          startDate: today,
        ),
      ];

      final completions = [
        HabitCompletion(
          id: 'c1',
          habitId: 'h1',
          date: today,
          completedAt: today,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController(habits),
            ),
            completionsForDateProvider.overrideWith(
              (ref, date) => Stream.value(completions),
            ),
            habitStreakProvider.overrideWith(
              (ref, args) => Future.value(1),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const TodayScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DailyProgressHeader), findsOneWidget);
      expect(find.byType(HabitCard), findsNWidgets(2));
      expect(find.text('Morning Jog'), findsOneWidget);
      expect(find.text('Drink Water'), findsOneWidget);
      expect(find.text('1 of 2 completed'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('shows celebratory SnackBar when completing the final habit', (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final habits = [
        Habit(
          id: 'h1',
          name: 'Morning Jog',
          frequency: HabitFrequency.daily,
          scheduledWeekdays: const {},
          createdAt: today,
          startDate: today,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController(habits),
            ),
            completionsForDateProvider.overrideWith(
              (ref, date) => Stream.value(<HabitCompletion>[]),
            ),
            habitStreakProvider.overrideWith(
              (ref, args) => Future.value(1),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const TodayScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the uncompleted habit card to complete it
      await tester.tap(find.text('Morning Jog'));
      await tester.pumpAndSettle();

      expect(find.textContaining('All habits completed for today!'), findsOneWidget);
    });

    testWidgets('has no FAB and opens add habit sheet via empty state button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(
              () => _FakeHabitsController([]),
            ),
            completionsForDateProvider.overrideWith(
              (ref, date) => Stream.value(<HabitCompletion>[]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const TodayScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);

      await tester.tap(find.text('Create Habit'));
      await tester.pumpAndSettle();

      expect(find.text('Habit Name'), findsOneWidget);
      expect(find.text('Save Habit'), findsOneWidget);
    });
  });
}
