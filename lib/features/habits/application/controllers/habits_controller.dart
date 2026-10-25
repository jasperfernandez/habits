import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/habit_providers.dart';
import '../../domain/entities/habit.dart';

part 'habits_controller.g.dart';

@Riverpod(keepAlive: true)
class HabitsController extends _$HabitsController {
  @override
  Stream<List<Habit>> build() {
    return ref.watch(habitRepositoryProvider).watchHabits();
  }

  Future<void> create(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.create(habit);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }

  Future<void> archive(String id) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.archive(id);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }

  Future<void> unarchive(String id) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.unarchive(id);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }

  Future<void> reorder(
    int oldIndex,
    int newIndex,
    List<Habit> activeHabits,
  ) async {
    if (activeHabits.isEmpty ||
        oldIndex < 0 ||
        oldIndex >= activeHabits.length) {
      return;
    }
    final items = List<Habit>.from(activeHabits);
    final item = items.removeAt(oldIndex);
    final targetIndex = newIndex.clamp(0, items.length);
    items.insert(targetIndex, item);

    final repository = ref.read(habitRepositoryProvider);
    await repository.reorderHabits(items.map((h) => h.id).toList());
  }

  Future<void> delete(String id) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.delete(id);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }

  Future<void> toggleCompletion({
    required String habitId,
    required DateTime date,
    required bool isCurrentlyCompleted,
  }) async {
    final completionRepo = ref.read(habitCompletionRepositoryProvider);
    final normalized = DateTime(date.year, date.month, date.day);

    if (isCurrentlyCompleted) {
      await completionRepo.markIncomplete(habitId: habitId, date: normalized);
    } else {
      await completionRepo.markCompleted(habitId: habitId, date: normalized);
    }
  }
}
