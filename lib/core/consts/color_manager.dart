
import 'package:flutter/material.dart';

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class ColorManager {
  static Color primary = HexColor.fromHex("#6C5CE7");
  static Color primaryLight = HexColor.fromHex("#A29BFE");
  static Color primaryDark = HexColor.fromHex("#5742D3");

  static Color secondary = HexColor.fromHex("#00CEC9");
  static Color secondaryLight = HexColor.fromHex("#00E5E1");
  static Color accent = HexColor.fromHex("#FF7675");

  static Color backgroundPrimary = HexColor.fromHex("#0F0F23");
  static Color backgroundSecondary = HexColor.fromHex("#1A1A2E");
  static Color backgroundTertiary = HexColor.fromHex("#16213E");
  static Color cardBackground = HexColor.fromHex("#1E1E3F");

  static Color textPrimary = HexColor.fromHex("#FFFFFF");
  static Color textSecondary = HexColor.fromHex("#B0B3B8");
  static Color textTertiary = HexColor.fromHex("#8B949E");
  static Color textMuted = HexColor.fromHex("#6E7681");

  static Color surface = HexColor.fromHex("#21262D");
  static Color surfaceVariant = HexColor.fromHex("#2D333B");
  static Color divider = HexColor.fromHex("#30363D");
  static Color border = HexColor.fromHex("#21262D");

  static Color success = HexColor.fromHex("#238636");
  static Color warning = HexColor.fromHex("#D29922");
  static Color error = HexColor.fromHex("#F85149");
  static Color info = HexColor.fromHex("#58A6FF");

  static List<Color> primaryGradient = [
    HexColor.fromHex("#667EEA"),
    HexColor.fromHex("#764BA2"),
  ];

  static List<Color> accentGradient = [
    HexColor.fromHex("#FF416C"),
    HexColor.fromHex("#FF4B2B"),
  ];

  static List<Color> cardGradient = [
    HexColor.fromHex("#2D333B"),
    HexColor.fromHex("#21262D"),
  ];

  static Color rippleColor = primary.withOpacity(0.1);
  static Color hoverColor = primary.withOpacity(0.05);
  static Color selectedColor = primary.withOpacity(0.15);

  static Color shimmerBase = HexColor.fromHex("#2D333B");
  static Color shimmerHighlight = HexColor.fromHex("#30363D");

  static Color gold = HexColor.fromHex("#FFD700");
  static Color premium = HexColor.fromHex("#FF6B35");
  static Color verified = HexColor.fromHex("#1DA1F2");
}
