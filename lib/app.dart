import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/screens/main_screen.dart';
import 'features/onboarding/presentation/screens/welcome_screen.dart';
import 'features/settings/application/settings_controller.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habits',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      home: settings.hasCompletedOnboarding
          ? const MainScreen()
          : const WelcomeScreen(),
    );
  }
}
