import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/enums/habit_frequency.dart';

extension HabitScheduleExtension on Habit {
  /// Returns whether this habit is scheduled to be performed on [date].
  bool isScheduledOn(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    if (normalizedDate.isBefore(normalizedStart)) {
      return false;
    }

    if (archivedAt != null) {
      final normalizedArchived = DateTime(
        archivedAt!.year,
        archivedAt!.month,
        archivedAt!.day,
      );
      if (normalizedDate.isAfter(normalizedArchived)) {
        return false;
      }
    }

    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.selectedWeekdays:
        return scheduledWeekdays.contains(normalizedDate.weekday);
    }
  }
}

class StreakCalculator {
  const StreakCalculator._();

  /// Calculates the current streak of consecutive completed scheduled days
  /// for [habit] up to [targetDate].
  ///
  /// If [targetDate] is null, defaults to today.
  static int calculateStreak({
    required Habit habit,
    required List<HabitCompletion> completions,
    DateTime? targetDate,
  }) {
    final now = targetDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      habit.startDate.year,
      habit.startDate.month,
      habit.startDate.day,
    );

    if (today.isBefore(startDate)) {
      return 0;
    }

    final completedDates = completions
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet();

    int streak = 0;
    DateTime currentCheck = today;

    if (habit.isScheduledOn(today)) {
      if (completedDates.contains(today)) {
        streak++;
        currentCheck = today.subtract(const Duration(days: 1));
      } else {
        // Today is not completed yet. Streak is preserved from yesterday.
        currentCheck = today.subtract(const Duration(days: 1));
      }
    } else {
      // Today is a rest day (not scheduled). Look back to the previous day.
      currentCheck = today.subtract(const Duration(days: 1));
    }

    // Walk backwards day by day until start date
    while (!currentCheck.isBefore(startDate)) {
      if (habit.isScheduledOn(currentCheck)) {
        if (completedDates.contains(currentCheck)) {
          streak++;
        } else {
          // Missed a scheduled day in the past -> streak is broken.
          break;
        }
      }
      currentCheck = currentCheck.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Calculates the longest streak achieved for [habit].
  static int calculateLongestStreak({
    required Habit habit,
    required List<HabitCompletion> completions,
    DateTime? upToDate,
  }) {
    final now = upToDate ?? DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      habit.startDate.year,
      habit.startDate.month,
      habit.startDate.day,
    );

    if (endDate.isBefore(startDate)) {
      return 0;
    }

    final completedDates = completions
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet();

    int maxStreak = 0;
    int currentRun = 0;

    DateTime checkDate = startDate;
    while (!checkDate.isAfter(endDate)) {
      if (habit.isScheduledOn(checkDate)) {
        if (completedDates.contains(checkDate)) {
          currentRun++;
          if (currentRun > maxStreak) {
            maxStreak = currentRun;
          }
        } else {
          currentRun = 0;
        }
      }
      checkDate = checkDate.add(const Duration(days: 1));
    }

    return maxStreak;
  }
}
