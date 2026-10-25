import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/habits/application/controllers/habits_controller.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/enums/habit_frequency.dart';
import 'package:habits/features/habits/presentation/screens/habits_screen.dart';

class _FakeHabitsController extends HabitsController {
  _FakeHabitsController(this._habits);
  final List<Habit> _habits;
  bool reorderedCalled = false;
  bool unarchiveCalled = false;
  bool archiveCalled = false;

  @override
  Stream<List<Habit>> build() => Stream.value(_habits);

  @override
  Future<void> reorder(int oldIndex, int newIndex, List<Habit> activeHabits) async {
    reorderedCalled = true;
  }

  @override
  Future<void> unarchive(String id) async {
    unarchiveCalled = true;
  }

  @override
  Future<void> archive(String id) async {
    archiveCalled = true;
  }
}

void main() {
  group('HabitsScreen', () {
    final activeHabits = [
      Habit(
        id: 'h1',
        name: 'Morning Meditation',
        frequency: HabitFrequency.daily,
        scheduledWeekdays: const {},
        createdAt: DateTime(2026, 10, 1),
        startDate: DateTime(2026, 10, 1),
        sortOrder: 0,
      ),
      Habit(
        id: 'h2',
        name: 'Workout',
        frequency: HabitFrequency.selectedWeekdays,
        scheduledWeekdays: const {DateTime.monday, DateTime.wednesday, DateTime.friday},
        createdAt: DateTime(2026, 10, 2),
        startDate: DateTime(2026, 10, 2),
        sortOrder: 1,
      ),
    ];

    final archivedHabits = [
      Habit(
        id: 'h3',
        name: 'Old Habit',
        frequency: HabitFrequency.daily,
        scheduledWeekdays: const {},
        createdAt: DateTime(2026, 9, 1),
        startDate: DateTime(2026, 9, 1),
        archivedAt: DateTime(2026, 10, 1),
        sortOrder: 2,
      ),
    ];

    testWidgets('renders active habits tab with drag handles', (tester) async {
      final fakeController = _FakeHabitsController([...activeHabits, ...archivedHabits]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(() => fakeController),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HabitsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Habits'), findsOneWidget);
      expect(find.text('Active Habits'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
      expect(find.text('Morning Meditation'), findsOneWidget);
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('Hold and drag to reorder routine'), findsOneWidget);
      expect(find.byIcon(Icons.drag_handle_rounded), findsNWidgets(2));
    });

    testWidgets('shows archived tab and allows restore', (tester) async {
      final fakeController = _FakeHabitsController([...activeHabits, ...archivedHabits]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(() => fakeController),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HabitsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Archived tab
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();

      expect(find.text('Old Habit'), findsOneWidget);

      // Tap restore icon button
      await tester.tap(find.byIcon(Icons.unarchive_outlined));
      expect(fakeController.unarchiveCalled, isTrue);
    });

    testWidgets('shows empty state when no habits exist', (tester) async {
      final fakeController = _FakeHabitsController([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsControllerProvider.overrideWith(() => fakeController),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const HabitsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No active habits'), findsOneWidget);
      expect(find.text('Add Habit'), findsOneWidget);
    });
  });
}
