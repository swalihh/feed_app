import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  bool _isDarkMode = true;
  static const String _themeKey = 'isDarkMode';

  bool get isDarkMode => _isDarkMode;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true; // Default to dark mode
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkMode ? _getDarkTheme() : _getLightTheme();

  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF6C5CE7),
        primaryContainer: const Color(0xFF5742D3),
        secondary: const Color(0xFF00CEC9),
        surface: const Color(0xFF21262D),
        background: const Color(0xFF0F0F23),
        error: const Color(0xFFF85149),
        onSurface: const Color(0xFFE1E3E6),
        onBackground: const Color(0xFFE1E3E6),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F23),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F0F23),
        foregroundColor: Color(0xFFE1E3E6),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E3F),
        elevation: 8,
        shadowColor: Color(0x40000000),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
  }

  ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF6C5CE7),
        primaryContainer: const Color(0xFFE8E5FF),
        secondary: const Color(0xFF00CEC9),
        surface: const Color(0xFFFFFFFF),
        background: const Color(0xFFF5F7FA),
        error: const Color(0xFFDC3545),
        onSurface: const Color(0xFF1A1D29),
        onBackground: const Color(0xFF1A1D29),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F7FA),
        foregroundColor: Color(0xFF1A1D29),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 2,
        shadowColor: Color(0x1A000000),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
  }
}