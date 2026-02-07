import 'dart:ui';
import 'package:flutter/material.dart';

/// 🎨 Advanced Theme System
/// Premium color palettes for Light & Dark modes

class AppColors {
  // ============ Light Mode Colors ============
  
  // Primary Colors
  static const primaryLight = Color(0xFF6366F1); // Indigo
  static const primaryLightVariant = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4F46E5);
  
  // Secondary Colors
  static const secondaryLight = Color(0xFF8B5CF6); // Purple
  static const secondaryLightVariant = Color(0xFFA78BFA);
  static const secondaryDark = Color(0xFF7C3AED);
  
  // Accent Colors
  static const accentLight = Color(0xFF10B981); // Emerald
  static const accentWarning = Color(0xFFF59E0B); // Amber
  static const accentError = Color(0xFFEF4444); // Red
  static const accentInfo = Color(0xFF3B82F6); // Blue
  
  // Background Colors - Light
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);
  
  // Text Colors - Light
  static const textPrimaryLight = Color(0xFF1E293B);
  static const textSecondaryLight = Color(0xFF64748B);
  static const textTertiaryLight = Color(0xFF94A3B8);
  
  // Border Colors - Light
  static const borderLight = Color(0xFFE2E8F0);
  static const dividerLight = Color(0xFFF1F5F9);
  
  // ============ Dark Mode Colors ============
  
  // Primary Colors - Dark
  static const primaryDarkMode = Color(0xFF818CF8);
  static const primaryDarkVariant = Color(0xFFA5B4FC);
  static const primaryDarkDark = Color(0xFF6366F1);
  
  // Secondary Colors - Dark
  static const secondaryDarkMode = Color(0xFFA78BFA);
  static const secondaryDarkVariant = Color(0xFFC4B5FD);
  static const secondaryDarkDark = Color(0xFF8B5CF6);
  
  // Accent Colors - Dark (Same as light but adjusted)
  static const accentDark = Color(0xFF34D399);
  static const accentWarningDark = Color(0xFFFBBF24);
  static const accentErrorDark = Color(0xFFF87171);
  static const accentInfoDark = Color(0xFF60A5FA);
  
  // Background Colors - Dark
  static const backgroundDark = Color(0xFF0F172A); // Slate 900
  static const surfaceDark = Color(0xFF1E293B); // Slate 800
  static const cardDark = Color(0xFF334155); // Slate 700
  
  // Text Colors - Dark
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFFCBD5E1);
  static const textTertiaryDark = Color(0xFF94A3B8);
  
  // Border Colors - Dark
  static const borderDark = Color(0xFF334155);
  static const dividerDark = Color(0xFF1E293B);
  
  // ============ Glassmorphism Colors ============
  static Color glassLight = Colors.white.withValues(alpha: 0.1);
  static Color glassDark = Colors.white.withValues(alpha: 0.05);
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.2);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.1);
}

/// 🌈 Gradient Library
class AppGradients {
  // Primary Gradients
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const errorGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Background Gradients
  static const lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Glassmorphism Gradients
  static LinearGradient glassGradientLight = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.3),
      Colors.white.withValues(alpha: 0.1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient glassGradientDark = LinearGradient(
    colors: [
      Colors.white.withValues(alpha: 0.15),
      Colors.white.withValues(alpha: 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 💫 Shadow System
class AppShadows {
  // Light Mode Shadows
  static const List<BoxShadow> smallShadowLight = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> mediumShadowLight = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> largeShadowLight = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> xlShadowLight = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
  
  // Dark Mode Shadows (subtle)
  static const List<BoxShadow> smallShadowDark = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> mediumShadowDark = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> largeShadowDark = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> xlShadowDark = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
  
  // Glow Effects
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primaryLight.withValues(alpha: 0.5),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> accentGlow = [
    BoxShadow(
      color: AppColors.accentLight.withValues(alpha: 0.5),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}

/// ⏱️ Animation Constants
class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  
  // Custom Curve
  static const Curve smooth = Curves.easeInOutCubic;
}

/// 📏 Spacing & Sizing
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  
  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 999;
}

/// 🔲 Border Radius Constants
class AppBorderRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;
}
