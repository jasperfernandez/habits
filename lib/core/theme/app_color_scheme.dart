import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF477A59);
  static const primaryContainer = Color(0xFFD9EBDD);

  // Surfaces
  static const background = Color(0xFFF7F8F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEF1EB);

  // Text
  static const textPrimary = Color(0xFF202820);
  static const textSecondary = Color(0xFF737B72);

  // Feedback
  static const success = Color(0xFF388659);
  static const error = Color(0xFFBA3F3F);
  static const outline = Color(0xFFDDE2D9);
}

abstract final class AppColorSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: Color(0xFF173D25),
    secondary: Color(0xFF637A65),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE1EAE0),
    onSecondaryContainer: Color(0xFF253D29),
    tertiary: Color(0xFF8A7651),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFF1E5CD),
    onTertiaryContainer: Color(0xFF332710),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.outline,
    outlineVariant: Color(0xFFE8EBE4),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF2F332E),
    onInverseSurface: Color(0xFFF0F1EC),
    inversePrimary: Color(0xFFB5D8BB),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF75B58E),
    onPrimary: Color(0xFF0F381F),
    primaryContainer: Color(0xFF274D34),
    onPrimaryContainer: Color(0xFFD9EBDD),
    secondary: Color(0xFFA6BEA7),
    onSecondary: Color(0xFF1B3520),
    secondaryContainer: Color(0xFF324C35),
    onSecondaryContainer: Color(0xFFDCE6DB),
    tertiary: Color(0xFFD7C49E),
    onTertiary: Color(0xFF3B2F15),
    tertiaryContainer: Color(0xFF534529),
    onTertiaryContainer: Color(0xFFF4E2BD),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF161A17),
    onSurface: Color(0xFFE1E5DF),
    surfaceContainerHighest: Color(0xFF252B26),
    onSurfaceVariant: Color(0xFFA5ADA5),
    outline: Color(0xFF384039),
    outlineVariant: Color(0xFF2A312B),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE1E5DF),
    onInverseSurface: Color(0xFF161A17),
    inversePrimary: AppColors.primary,
  );
}
