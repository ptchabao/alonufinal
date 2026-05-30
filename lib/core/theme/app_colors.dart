import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFACC15);
  static const Color primaryDark = Color(0xFFEAB308);
  static const Color primaryLight = Color(0xFFFEF9C3);

  // Secondary and Accent
  static const Color secondary = Color(0xFF1B5E20);
  static const Color accent = Color(0xFFC62828);
  static const Color tertiary = Color(0xFF4A4A4A);

  // Functional Colors
  static const Color background = Color(0xFFFAF8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFFF5F0EB);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFACC15);
  static const Color info = Color(0xFF1565C0);

  // Text Colors
  static const Color onPrimary = Color(0xFF1A1A1A);
  static const Color onBackground = Color(0xFF1A1A1A);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF6B6B6B);
  static const Color onSurfaceMuted = Color(0xFF9E9E9E);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Transparent
  static const Color transparent = Color(0x00000000);
  static const Color overlay = Color(0x80000000);

  // Badges
  static const Color activeStatus = success;
  static const Color pendingStatus = warning;
  static const Color cancelledStatus = error;

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [transparent, Color(0xB3000000)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, surface],
  );

  static const LinearGradient badgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFFEAB308)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF1B5E20)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFB71C1C)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, Color(0xFFCA8A04)],
  );

  static const LinearGradient infoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [info, Color(0xFF0D47A1)],
  );

  // Shadow
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow cardShadowElevated = BoxShadow(
    color: Color(0x2D000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const List<BoxShadow> cardShadows = [cardShadow];
  static const List<BoxShadow> cardShadowsElevated = [cardShadowElevated];
}