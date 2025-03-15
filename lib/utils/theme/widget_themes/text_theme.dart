import 'package:flutter/material.dart';
import '../../constants/colors.dart';

/// Custom Class for Light & Dark Text Themes
class TTextTheme {
  TTextTheme._(); // To avoid creating instances

  /// Customizable Light Text Theme
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: TColors.primary, // Light primary color
      fontFamily: 'Roboto',
    ),
    headlineMedium: const TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: TColors.primary,
      fontFamily: 'Roboto',
    ),
    headlineSmall: const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: TColors.primary,
      fontFamily: 'Roboto',
    ),
    titleLarge: const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: TColors.textPrimary,
      fontFamily: 'Roboto',
    ),
    titleMedium: const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: TColors.textPrimary,
      fontFamily: 'Roboto',
    ),
    titleSmall: const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: TColors.textSecondary,
      fontFamily: 'Roboto',
    ),
    bodyLarge: const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: TColors.textPrimary,
      fontFamily: 'Roboto',
    ),
    bodyMedium: const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: TColors.textSecondary,
      fontFamily: 'Roboto',
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: TColors.textSecondary.withOpacity(0.6),
      fontFamily: 'Roboto',
    ),
    labelLarge: const TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: TColors.secondary,
      fontFamily: 'Roboto',
    ),
    labelMedium: const TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: TColors.accent,
      fontFamily: 'Roboto',
    ),
  );

  /// Customizable Dark Text Theme
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: const TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: TColors.light,
      fontFamily: 'Roboto',
    ),
    headlineMedium: const TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: TColors.light,
      fontFamily: 'Roboto',
    ),
    headlineSmall: const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: TColors.light,
      fontFamily: 'Roboto',
    ),
    titleLarge: const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: TColors.light,
      fontFamily: 'Roboto',
    ),
    titleMedium: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: TColors.light.withOpacity(0.9),
      fontFamily: 'Roboto',
    ),
    titleSmall: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      color: TColors.light.withOpacity(0.7),
      fontFamily: 'Roboto',
    ),
    bodyLarge: const TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: TColors.light,
      fontFamily: 'Roboto',
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      color: TColors.light.withOpacity(0.9),
      fontFamily: 'Roboto',
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: TColors.light.withOpacity(0.6),
      fontFamily: 'Roboto',
    ),
    labelLarge: const TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      color: TColors.accent,
      fontFamily: 'Roboto',
    ),
    labelMedium: TextStyle(
      fontSize: 10.0,
      fontWeight: FontWeight.normal,
      color: TColors.secondary.withOpacity(0.7),
      fontFamily: 'Roboto',
    ),
  );
}
