import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  // Brand colors from app icon
  static const primary = Color(0xFF3A61E1); // #3a61e1 - Cobalt Blue
  static const primaryContainer = Color(0xFFB3BCF8); // #b3bcf8 - Soft Periwinkle
  static const secondary = Color(0xFFB3BCF8); // #b3bcf8
  static const secondaryContainer = Color(0xFFDEE3FC);
  static const accent = Color(0xFFFA9384); // #fa9384 - Coral
  static const tertiary = Color(0xFFFA9384); // #fa9384
  static const tertiaryContainer = Color(0xFFFFDDD7);

  // Surfaces
  static const background = Color(0xFFF6F8FE);
  static const surface = Color(0xFFFFFFFF); // #ffffff - White
  static const surfaceVariant = Color(0xFFEEF1F8);

  // Text
  static const textPrimary = Color(0xFF1A1D26);
  static const textSecondary = Color(0xFF6B7280);

  // Feedback
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFDC2626);
  static const outline = Color(0xFFE2E6F0);
}

abstract final class AppColorSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.surface,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: Color(0xFF00174D),
    secondary: Color(0xFF4C578A),
    onSecondary: AppColors.surface,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: Color(0xFF0A1544),
    tertiary: Color(0xFF9E382A),
    onTertiary: AppColors.surface,
    tertiaryContainer: AppColors.accent,
    onTertiaryContainer: Color(0xFF3B0905),
    error: AppColors.error,
    onError: AppColors.surface,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.outline,
    outlineVariant: Color(0xFFECEFF6),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF2E3036),
    onInverseSurface: Color(0xFFF1F0F7),
    inversePrimary: AppColors.secondary,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB3BCF8),
    onPrimary: Color(0xFF001F6E),
    primaryContainer: Color(0xFF2045C8),
    onPrimaryContainer: Color(0xFFDCE2FD),
    secondary: Color(0xFFBAC3EB),
    onSecondary: Color(0xFF232D51),
    secondaryContainer: Color(0xFF3A446B),
    onSecondaryContainer: Color(0xFFDCE2FD),
    tertiary: Color(0xFFFA9384),
    onTertiary: Color(0xFF5C140A),
    tertiaryContainer: Color(0xFF7A251A),
    onTertiaryContainer: Color(0xFFFFDAD4),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF141724),
    onSurface: Color(0xFFE3E6F2),
    surfaceContainerHighest: Color(0xFF222638),
    onSurfaceVariant: Color(0xFFA1A7BE),
    outline: Color(0xFF363C52),
    outlineVariant: Color(0xFF262A3C),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE3E6F2),
    onInverseSurface: Color(0xFF141724),
    inversePrimary: AppColors.primary,
  );
}
