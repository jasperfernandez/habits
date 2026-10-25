import '../entities/habit_completion.dart';

abstract interface class HabitCompletionRepository {
  Stream<List<HabitCompletion>> watchByDate(DateTime date);

  Future<void> markCompleted({required String habitId, required DateTime date});

  Future<void> markIncomplete({
    required String habitId,
    required DateTime date,
  });

  Future<List<HabitCompletion>> getByHabitId(String habitId);
}
