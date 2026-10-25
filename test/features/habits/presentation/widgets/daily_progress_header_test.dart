import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/habits/presentation/widgets/daily_progress_header.dart';

void main() {
  Widget buildWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  group('DailyProgressHeader', () {
    testWidgets('displays date and 0 of 0 completed when 0 habits', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          DailyProgressHeader(
            completedCount: 0,
            totalCount: 0,
            date: DateTime(2026, 10, 24),
          ),
        ),
      );

      expect(find.textContaining('Saturday, Oct 24'), findsOneWidget);
      expect(find.text('0 of 0 completed'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('displays correct percentage and completed count', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          DailyProgressHeader(
            completedCount: 3,
            totalCount: 4,
            date: DateTime(2026, 10, 24),
          ),
        ),
      );

      expect(find.text('3 of 4 completed'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('displays 100% and check icon when all habits completed', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          DailyProgressHeader(
            completedCount: 5,
            totalCount: 5,
            date: DateTime(2026, 10, 24),
          ),
        ),
      );

      expect(find.text('5 of 5 completed'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('triggers navigation callbacks', (tester) async {
      bool prevTapped = false;
      bool nextTapped = false;

      await tester.pumpWidget(
        buildWidget(
          DailyProgressHeader(
            completedCount: 1,
            totalCount: 2,
            onPreviousDay: () => prevTapped = true,
            onNextDay: () => nextTapped = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      expect(prevTapped, isTrue);

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      expect(nextTapped, isTrue);
    });
  });
}
