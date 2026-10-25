import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/enums/habit_frequency.dart';
import 'package:habits/features/habits/presentation/widgets/habit_card.dart';

void main() {
  Widget buildWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );
  }

  group('HabitCard', () {
    final sampleHabit = Habit(
      id: 'h1',
      name: 'Read 20 pages',
      description: 'Fiction or non-fiction',
      frequency: HabitFrequency.daily,
      scheduledWeekdays: const {},
      createdAt: DateTime(2026, 10, 1),
      startDate: DateTime(2026, 10, 1),
    );

    testWidgets('renders habit name, description, frequency, and streak', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          HabitCard(
            habit: sampleHabit,
            isCompleted: false,
            streak: 4,
            onToggle: () {},
          ),
        ),
      );

      expect(find.text('Read 20 pages'), findsOneWidget);
      expect(find.text('Fiction or non-fiction'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('4 days'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });

    testWidgets('renders completed state with checkmark', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          HabitCard(
            habit: sampleHabit,
            isCompleted: true,
            streak: 5,
            onToggle: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('calls onToggle when tapped', (tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        buildWidget(
          HabitCard(
            habit: sampleHabit,
            isCompleted: false,
            streak: 0,
            onToggle: () => toggled = true,
          ),
        ),
      );

      await tester.tap(find.text('Read 20 pages'));
      expect(toggled, isTrue);
    });

    testWidgets('displays selected weekdays frequency correctly', (tester) async {
      final mwfHabit = Habit(
        id: 'h2',
        name: 'Gym Workout',
        frequency: HabitFrequency.selectedWeekdays,
        scheduledWeekdays: const {DateTime.monday, DateTime.wednesday, DateTime.friday},
        createdAt: DateTime(2026, 10, 1),
        startDate: DateTime(2026, 10, 1),
      );

      await tester.pumpWidget(
        buildWidget(
          HabitCard(
            habit: mwfHabit,
            isCompleted: false,
            streak: 0,
            onToggle: () {},
          ),
        ),
      );

      expect(find.text('Mon, Wed, Fri'), findsOneWidget);
    });

    testWidgets('supports archive and delete menu actions', (tester) async {
      bool archived = false;

      await tester.pumpWidget(
        buildWidget(
          HabitCard(
            habit: sampleHabit,
            isCompleted: false,
            streak: 0,
            onToggle: () {},
            onArchive: () => archived = true,
            onDelete: () {},
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      expect(archived, isTrue);
    });
  });
}
