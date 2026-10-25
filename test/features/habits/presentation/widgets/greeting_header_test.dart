import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habits/core/theme/app_theme.dart';
import 'package:habits/features/habits/presentation/widgets/greeting_header.dart';

void main() {
  Widget buildWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(appBar: AppBar(title: child)),
    );
  }

  group('GreetingHeader', () {
    testWidgets('shows Good morning and sun icon during morning hours', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          GreetingHeader(name: 'Jasper', time: DateTime(2026, 10, 24, 8, 30)),
        ),
      );

      expect(find.text('Good morning, Jasper!'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_round), findsNothing);
    });

    testWidgets('shows Good noon and sun icon during afternoon hours', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          GreetingHeader(name: 'Jasper', time: DateTime(2026, 10, 24, 13, 0)),
        ),
      );

      expect(find.text('Good noon, Jasper!'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_round), findsNothing);
    });

    testWidgets('shows Good evening and moon icon during evening hours', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          GreetingHeader(name: 'Jasper', time: DateTime(2026, 10, 24, 19, 45)),
        ),
      );

      expect(find.text('Good evening, Jasper!'), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsNothing);
    });

    testWidgets('shows Good evening and moon icon during late night hours', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          GreetingHeader(name: 'Jasper', time: DateTime(2026, 10, 24, 2, 15)),
        ),
      );

      expect(find.text('Good evening, Jasper!'), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    });

    testWidgets('handles empty or null name prop', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          GreetingHeader(name: null, time: DateTime(2026, 10, 24, 9, 0)),
        ),
      );

      expect(find.text('Good morning!'), findsOneWidget);
    });
  });
}
