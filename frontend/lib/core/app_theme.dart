import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  
  // Accent colors
  static const Color primaryBlue = Color(0xFF6C8EEF);
  static const Color primaryPurple = Color(0xFF9B8FEF);
  static const Color primaryGreen = Color(0xFF6BCFA1);
  static const Color softPink = Color(0xFFEF8FA3);
  static const Color softOrange = Color(0xFFEFAB6B);
  static const Color softTeal = Color(0xFF5CC2E0);
  static const Color softLavender = Color(0xFFB39DDB);
  static const Color softYellow = Color(0xFFF0D76B);
  static const Color softCoral = Color(0xFFFF8A80);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFFBFC5D2);
  
  // Functional colors
  static const Color productive = Color(0xFF6BCFA1);
  static const Color neutral = Color(0xFFEFAB6B);
  static const Color wasted = Color(0xFFEF8FA3);
  
  // Borders & Dividers
  static const Color border = Color(0xFFE8ECF2);
  static const Color divider = Color(0xFFF1F3F8);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C8EEF), Color(0xFF9B8FEF)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6BCFA1), Color(0xFF4DB88A)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFAB6B), Color(0xFFEF8FA3)],
  );

  // Category color map — deterministic pastel colors per category
  static const List<Color> categoryPalette = [
    Color(0xFF6C8EEF), // Blue
    Color(0xFF6BCFA1), // Green
    Color(0xFF9B8FEF), // Purple
    Color(0xFFEFAB6B), // Orange
    Color(0xFFEF8FA3), // Pink
    Color(0xFF5CC2E0), // Teal
    Color(0xFFE88FEF), // Magenta
    Color(0xFFA3D977), // Lime
    Color(0xFFF0D76B), // Yellow
    Color(0xFFFF8A80), // Coral
    Color(0xFF80CBC4), // Mint
    Color(0xFFB39DDB), // Lavender
  ];

  static Color categoryColor(String category, [int? index]) {
    if (index != null) return categoryPalette[index % categoryPalette.length];
    final hash = category.hashCode.abs();
    return categoryPalette[hash % categoryPalette.length];
  }

  // Productivity Index color (0-100)
  static Color productivityIndexColor(double value) {
    if (value >= 75) return const Color(0xFF4CAF50);
    if (value >= 50) return const Color(0xFF8BC34A);
    if (value >= 30) return const Color(0xFFFFC107);
    return const Color(0xFFFF5252);
  }

  // Heatmap intensity colors (lightest to darkest)
  static const List<Color> heatmapColors = [
    Color(0xFFEBEDF0),
    Color(0xFFC6E48B),
    Color(0xFF7BC96F),
    Color(0xFF239A3B),
    Color(0xFF196127),
  ];

  static Color heatmapColor(int minutes, int maxMinutes) {
    if (minutes == 0) return heatmapColors[0];
    final ratio = minutes / maxMinutes;
    if (ratio <= 0.25) return heatmapColors[1];
    if (ratio <= 0.50) return heatmapColors[2];
    if (ratio <= 0.75) return heatmapColors[3];
    return heatmapColors[4];
  }
}

class AppShadows {
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF6C8EEF).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: const Color(0xFF6C8EEF).withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  static const TextStyle metric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );
}

ThemeData appTheme() {
  return ThemeData(
    fontFamily: 'Inter',
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryBlue,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.primaryPurple,
      surface: AppColors.surface,
      error: AppColors.wasted,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h3,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
  );
}
