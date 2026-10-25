import '../entities/habit.dart';

abstract interface class HabitRepository {
  Stream<List<Habit>> watchHabits();

  Future<Habit?> getById(String id);

  Future<String> create(Habit habit);

  Future<void> update(Habit habit);

  Future<void> archive(String id);

  Future<void> unarchive(String id);

  Future<void> reorderHabits(List<String> habitIds);

  Future<void> delete(String id);
}
