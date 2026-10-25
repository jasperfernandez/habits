import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/app.dart';
import 'package:habits/features/habits/application/controllers/habits_controller.dart';
import 'package:habits/features/habits/application/providers/habit_providers.dart';
import 'package:habits/features/habits/domain/entities/habit.dart';
import 'package:habits/features/habits/domain/entities/habit_completion.dart';
import 'package:habits/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:habits/features/navigation/presentation/screens/main_screen.dart';
import 'package:habits/features/settings/application/settings_controller.dart';
import 'package:habits/features/settings/data/preferences_service.dart';

class _FakeHabitsController extends HabitsController {
  @override
  Stream<List<Habit>> build() => Stream.value(<Habit>[]);
}

void main() {
  group('App', () {
    testWidgets('shows WelcomeScreen on first launch when user name is not set', (tester) async {
      final inMemory = InMemoryPreferencesService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(inMemory),
            habitsControllerProvider.overrideWith(() => _FakeHabitsController()),
            completionsForDateProvider.overrideWith(
              (ref, date) => Stream.value(<HabitCompletion>[]),
            ),
          ],
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(MainScreen), findsNothing);
      expect(find.text('Welcome to Habits'), findsOneWidget);
    });

    testWidgets('shows MainScreen when onboarding is already completed', (tester) async {
      final inMemory = InMemoryPreferencesService(
        initialUserName: 'Jasper',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(inMemory),
            habitsControllerProvider.overrideWith(() => _FakeHabitsController()),
            completionsForDateProvider.overrideWith(
              (ref, date) => Stream.value(<HabitCompletion>[]),
            ),
          ],
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
      expect(find.textContaining('Jasper'), findsOneWidget); // In GreetingHeader
    });

    testWidgets('seamlessly transitions from WelcomeScreen to MainScreen after entering name', (tester) async {
      final inMemory = InMemoryPreferencesService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(inMemory),
            habitsControllerProvider.overrideWith(() => _FakeHabitsController()),
            completionsForDateProvider.overrideWith(
              (ref, date) => Stream.value(<HabitCompletion>[]),
            ),
          ],
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Jasper');
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
      expect(find.textContaining('Jasper'), findsOneWidget);
    });

    testWidgets('applies dark theme mode correctly', (tester) async {
      final inMemory = InMemoryPreferencesService(
        initialUserName: 'Jasper',
        initialThemeMode: ThemeMode.dark,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(inMemory),
            habitsControllerProvider.overrideWith(() => _FakeHabitsController()),
            completionsForDateProvider.overrideWith(
              (ref, date) => Stream.value(<HabitCompletion>[]),
            ),
          ],
          child: const App(),
        ),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
    });
  });
}
