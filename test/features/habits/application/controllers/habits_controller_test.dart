import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/database/app_database.dart' as db;
import 'package:habits/core/database/app_database_provider.dart';
import 'package:habits/features/habits/application/controllers/habits_controller.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/enums/habit_frequency.dart';

void main() {
  late db.AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = db.AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  group('HabitsController', () {
    test('creates and toggles completion without UnmountedRefException', () async {
      // Keep an active listener on habitsControllerProvider
      final sub = container.listen(habitsControllerProvider, (_, _) {});

      final controller = container.read(habitsControllerProvider.notifier);

      final habit = Habit(
        id: 'test-h1',
        name: 'Meditate',
        frequency: HabitFrequency.daily,
        scheduledWeekdays: const {},
        createdAt: DateTime.now(),
        startDate: DateTime.now(),
      );

      // Should not throw UnmountedRefException
      await controller.create(habit);

      final habits = await container.read(habitsControllerProvider.future);
      expect(habits.any((h) => h.id == 'test-h1'), isTrue);

      // Toggle completion
      final today = DateTime.now();
      await controller.toggleCompletion(
        habitId: 'test-h1',
        date: today,
        isCurrentlyCompleted: false,
      );

      await controller.toggleCompletion(
        habitId: 'test-h1',
        date: today,
        isCurrentlyCompleted: true,
      );

      // Archive
      await controller.archive('test-h1');

      // Unarchive
      await controller.unarchive('test-h1');

      // Create second habit for reorder test
      final habit2 = Habit(
        id: 'test-h2',
        name: 'Exercise',
        frequency: HabitFrequency.daily,
        scheduledWeekdays: const {},
        createdAt: DateTime.now(),
        startDate: DateTime.now(),
      );
      await controller.create(habit2);

      // Reorder test-h2 before test-h1
      await controller.reorder(0, 2, [habit, habit2]);

      // Delete
      await controller.delete('test-h1');
      await controller.delete('test-h2');

      sub.close();
    });
  });
}
