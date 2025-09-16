import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_manager.dart';

class ThemeManager {
  static ThemeData getPremiumDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.dark(
        primary: ColorManager.primary,
        primaryContainer: ColorManager.primaryDark,
        secondary: ColorManager.secondary,
        secondaryContainer: ColorManager.secondaryLight,
        surface: ColorManager.surface,
        surfaceVariant: ColorManager.surfaceVariant,
        background: ColorManager.backgroundPrimary,
        error: ColorManager.error,
        onPrimary: ColorManager.textPrimary,
        onSecondary: ColorManager.textPrimary,
        onSurface: ColorManager.textPrimary,
        onBackground: ColorManager.textPrimary,
        onError: ColorManager.textPrimary,
        outline: ColorManager.border,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: ColorManager.backgroundPrimary,
        foregroundColor: ColorManager.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: ColorManager.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(
          color: ColorManager.textPrimary,
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        color: ColorManager.cardBackground,
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorManager.primary,
          foregroundColor: ColorManager.textPrimary,
          elevation: 6,
          shadowColor: ColorManager.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ColorManager.textSecondary,
          backgroundColor: ColorManager.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: ColorManager.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          color: ColorManager.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          color: ColorManager.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: ColorManager.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
        ),
        titleLarge: TextStyle(
          color: ColorManager.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: ColorManager.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        bodyLarge: TextStyle(
          color: ColorManager.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: ColorManager.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: ColorManager.textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorManager.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorManager.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorManager.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorManager.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorManager.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: ColorManager.textTertiary,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          color: ColorManager.textSecondary,
          fontSize: 16,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ColorManager.cardBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        elevation: 16,
      ),

      dividerTheme: DividerThemeData(
        color: ColorManager.divider,
        thickness: 1,
        space: 1,
      ),

      scaffoldBackgroundColor: ColorManager.backgroundPrimary,

      splashColor: ColorManager.rippleColor,
      highlightColor: ColorManager.hoverColor,
    );
  }
}
