import 'package:flutter_test/flutter_test.dart';
import 'package:habits/features/habits/application/services/streak_calculator.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/entities/habit_completion.dart';
import 'package:habits/features/habits/domain/enums/habit_frequency.dart';

void main() {
  group('StreakCalculator', () {
    final habit = Habit(
      id: 'h1',
      name: 'Exercise',
      frequency: HabitFrequency.daily,
      scheduledWeekdays: const {},
      createdAt: DateTime(2026, 10, 1),
      startDate: DateTime(2026, 10, 1),
    );

    test('returns 0 when no completions exist', () {
      final streak = StreakCalculator.calculateStreak(
        habit: habit,
        completions: [],
        targetDate: DateTime(2026, 10, 5),
      );

      expect(streak, 0);
    });

    test('returns 1 when completed on targetDate', () {
      final completions = [
        HabitCompletion(
          id: 'c1',
          habitId: 'h1',
          date: DateTime(2026, 10, 5),
          completedAt: DateTime(2026, 10, 5, 8, 30),
        ),
      ];

      final streak = StreakCalculator.calculateStreak(
        habit: habit,
        completions: completions,
        targetDate: DateTime(2026, 10, 5),
      );

      expect(streak, 1);
    });

    test('preserves yesterday streak when targetDate is not yet completed', () {
      final completions = [
        HabitCompletion(
          id: 'c1',
          habitId: 'h1',
          date: DateTime(2026, 10, 4),
          completedAt: DateTime(2026, 10, 4, 8, 30),
        ),
        HabitCompletion(
          id: 'c2',
          habitId: 'h1',
          date: DateTime(2026, 10, 3),
          completedAt: DateTime(2026, 10, 3, 8, 30),
        ),
      ];

      final streak = StreakCalculator.calculateStreak(
        habit: habit,
        completions: completions,
        targetDate: DateTime(2026, 10, 5),
      );

      expect(streak, 2);
    });

    test('calculates multi-day streak when today is completed', () {
      final completions = [
        HabitCompletion(
          id: 'c1',
          habitId: 'h1',
          date: DateTime(2026, 10, 5),
          completedAt: DateTime(2026, 10, 5, 8, 30),
        ),
        HabitCompletion(
          id: 'c2',
          habitId: 'h1',
          date: DateTime(2026, 10, 4),
          completedAt: DateTime(2026, 10, 4, 8, 30),
        ),
        HabitCompletion(
          id: 'c3',
          habitId: 'h1',
          date: DateTime(2026, 10, 3),
          completedAt: DateTime(2026, 10, 3, 8, 30),
        ),
      ];

      final streak = StreakCalculator.calculateStreak(
        habit: habit,
        completions: completions,
        targetDate: DateTime(2026, 10, 5),
      );

      expect(streak, 3);
    });

    test('breaks streak when a previous day was missed', () {
      final completions = [
        HabitCompletion(
          id: 'c1',
          habitId: 'h1',
          date: DateTime(2026, 10, 5),
          completedAt: DateTime(2026, 10, 5, 8, 30),
        ),
        // Missed Oct 4
        HabitCompletion(
          id: 'c3',
          habitId: 'h1',
          date: DateTime(2026, 10, 3),
          completedAt: DateTime(2026, 10, 3, 8, 30),
        ),
      ];

      final streak = StreakCalculator.calculateStreak(
        habit: habit,
        completions: completions,
        targetDate: DateTime(2026, 10, 5),
      );

      expect(streak, 1);
    });

    test('handles selected weekdays correctly without breaking on rest days', () {
      // 2026-10-19 is Monday (1)
      // 2026-10-21 is Wednesday (3)
      // 2026-10-23 is Friday (5)
      // 2026-10-24 is Saturday (6)
      final mwfHabit = Habit(
        id: 'h2',
        name: 'Gym',
        frequency: HabitFrequency.selectedWeekdays,
        scheduledWeekdays: const {DateTime.monday, DateTime.wednesday, DateTime.friday},
        createdAt: DateTime(2026, 10, 1),
        startDate: DateTime(2026, 10, 1),
      );

      final completions = [
        HabitCompletion(
          id: 'c1',
          habitId: 'h2',
          date: DateTime(2026, 10, 19),
          completedAt: DateTime(2026, 10, 19),
        ),
        HabitCompletion(
          id: 'c2',
          habitId: 'h2',
          date: DateTime(2026, 10, 21),
          completedAt: DateTime(2026, 10, 21),
        ),
        HabitCompletion(
          id: 'c3',
          habitId: 'h2',
          date: DateTime(2026, 10, 23),
          completedAt: DateTime(2026, 10, 23),
        ),
      ];

      // On Saturday Oct 24 (rest day), streak should still be 3
      final streak = StreakCalculator.calculateStreak(
        habit: mwfHabit,
        completions: completions,
        targetDate: DateTime(2026, 10, 24),
      );

      expect(streak, 3);
    });
  });
}
