import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:habits/features/settings/application/settings_controller.dart';
import 'package:habits/features/settings/data/preferences_service.dart';

void main() {
  group('WelcomeScreen', () {
    testWidgets('renders welcome header, input, and options', (tester) async {
      final inMemory = InMemoryPreferencesService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(inMemory),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome to Habits'), findsOneWidget);
      expect(find.text('What should we call you?'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Habit Reminders'), findsNothing);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('validates required name field', (tester) async {
      final inMemory = InMemoryPreferencesService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(inMemory),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Get Started without typing a name
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your name to continue'), findsOneWidget);
      expect(inMemory.getUserName(), isNull);
    });

    testWidgets('submits name and starts app', (tester) async {
      final inMemory = InMemoryPreferencesService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(inMemory),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const WelcomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextFormField), 'Jasper');

      // Tap Get Started
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(inMemory.getUserName(), 'Jasper');
    });
  });
}
