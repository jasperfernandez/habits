import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/habits/application/controllers/habits_controller.dart';
import 'package:habits/features/habits/application/providers/habit_providers.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/entities/habit_completion.dart';
import 'package:habits/features/navigation/presentation/screens/main_screen.dart';

class _FakeHabitsController extends HabitsController {
  _FakeHabitsController(this._habits);
  final List<Habit> _habits;

  @override
  Stream<List<Habit>> build() => Stream.value(_habits);
}

void main() {
  group('MainScreen Navigation', () {
    testWidgets('renders 3 bottom navigation destinations and switches tabs', (
      tester,
    ) async {
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
          child: MaterialApp(theme: AppTheme.light, home: const MainScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check destinations exist
      expect(find.text('Today'), findsWidgets);
      expect(find.text('Habits'), findsWidgets);
      expect(find.text('Settings'), findsOneWidget);

      // Initially on Today tab
      expect(find.text('No habits yet'), findsOneWidget);

      // Switch to Habits tab via bottom bar
      await tester.tap(find.text('Habits').last);
      await tester.pumpAndSettle();

      expect(find.text('Active Habits'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);

      // Switch to Settings tab via bottom bar
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
      expect(find.text('PREFERENCES'), findsOneWidget);

      // Switch back to Today tab
      await tester.tap(find.text('Today').last);
      await tester.pumpAndSettle();

      expect(find.text('No habits yet'), findsOneWidget);
    });
  });
}
