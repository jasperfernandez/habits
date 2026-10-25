import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/drift_habit_completion_repository.dart';
import '../../data/drift_habit_repository.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/repository/habit_completion_repository.dart';
import '../../domain/repository/habit_repository.dart';
import '../../../../core/database/app_database_provider.dart';
import '../services/streak_calculator.dart';

part 'habit_providers.g.dart';

@Riverpod(keepAlive: true)
HabitRepository habitRepository(Ref ref) {
  return DriftHabitRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
HabitCompletionRepository habitCompletionRepository(Ref ref) {
  return DriftHabitCompletionRepository(ref.watch(appDatabaseProvider));
}

@riverpod
Stream<List<Habit>> habitsStream(Ref ref) {
  return ref.watch(habitRepositoryProvider).watchHabits();
}

@riverpod
Stream<List<HabitCompletion>> completionsForDate(Ref ref, DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return ref.watch(habitCompletionRepositoryProvider).watchByDate(normalized);
}

@riverpod
Future<int> habitStreak(Ref ref, String habitId, DateTime date) async {
  final normalized = DateTime(date.year, date.month, date.day);
  ref.watch(completionsForDateProvider(normalized));

  final habit = await ref.watch(habitRepositoryProvider).getById(habitId);
  if (habit == null) return 0;
  final completions =
      await ref.watch(habitCompletionRepositoryProvider).getByHabitId(habitId);
  return StreakCalculator.calculateStreak(
    habit: habit,
    completions: completions,
    targetDate: normalized,
  );
}
