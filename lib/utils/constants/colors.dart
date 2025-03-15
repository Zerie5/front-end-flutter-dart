import 'package:flutter/material.dart';

class TColors {
  // Brand/Theme Colors
  static const Color primary =
      Color(0xFF18859A); // Primary color for light mode
  static const Color primaryDark =
      Color(0xFF0D4A54); // Primary color for dark mode
  static const Color secondary =
      Color(0xFFFFE24B); // Highlight or complementary color
  static const Color accent = Color(0xFFb0c7ff); // Subtle highlight color

  // Background Colors
  static const Color light = Color(0xFFF6F6F6); // Light background
  static const Color dark = Color(0xFF272727); // Dark background
  static const Color primaryBackground =
      Color(0xFFF3F5FF); // Background for primary UI elements
  static const Color lightContainer = Color(0xFFF6F6F6); // Light container
  static Color darkContainer = TColors.white.withOpacity(0.1); // Dark container

  // Text Colors
  static const Color textPrimary = Color(0xFF333333); // Primary text color
  static const Color textSecondary = Color(0xFF6C757D); // Secondary text color
  static const Color textWhite =
      Colors.white; // Common text color for dark backgrounds

  // Button Colors
  static const Color buttonPrimary =
      Color(0xFF4CAF50); // Green for primary buttons
  static const Color buttonSecondary =
      Color(0xFF6C757D); // Grey for secondary buttons
  static const Color buttonDisabled =
      Color(0xFFC4C4C4); // Disabled button color

  // Interaction Colors
  static const Color buttonRipple =
      Color(0x66FFFFFF); // Ripple effect for button presses
  static const Color rippleEffect =
      Color(0x66FFFFFF); // Ripple effect for interactions
  static const Color rippleEffectDark =
      Color(0x66CCCCCC); // Ripple effect for dark mode

  // Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9); // Primary border color
  static const Color borderSecondary =
      Color(0xFFE6E6E6); // Secondary border color

  // Status Colors
  static const Color error = Color(0xFFD32F2F); // Error (red)
  static const Color success = Color(0xFF388E3C); // Success (green)
  static const Color warning = Color(0xFFF57C00); // Warning (orange)
  static const Color info = Color(0xFF1976D2); // Info (blue)

  // Neutral Shades
  static const Color black = Color(0xFF232323); // Neutral black
  static const Color darkerGrey = Color(0xFF4F4F4F); // Dark grey
  static const Color darkGrey = Color(0xFF939393); // Grey
  static const Color grey = Color(0xFFE0E0E0); // Light grey
  static const Color softGrey = Color(0xFFF4F4F4); // Softer grey
  static const Color lightGrey = Color(0xFFF9F9F9); // Very light grey
  static const Color white = Color(0xFFFFFFFF); // Absolute white

  // Special Purpose Colors
  static const Color quickButtonHalo =
      Color(0xFF07CED5); // Quick button effect color

  // Common Opacity Values
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);
  static Color secondaryWithOpacity(double opacity) =>
      secondary.withOpacity(opacity);
  static Color whiteWithOpacity(double opacity) => white.withOpacity(opacity);
  static Color blackWithOpacity(double opacity) => black.withOpacity(opacity);

  // Common Gradients
  static LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primary.withOpacity(0.7)],
  );

  static LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondary.withOpacity(0.7)],
  );

  static LinearGradient primaryToSecondaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryDark.withOpacity(0.7)],
  );
}
