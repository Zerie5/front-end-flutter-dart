import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Outlined Button Themes -- */
class TOutlinedButtonTheme {
  TOutlinedButtonTheme._(); // To avoid creating instances

  /* -- Light Theme -- */
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.primary, // Primary text color in light mode
      side: const BorderSide(color: TColors.primary), // Primary border color
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: TColors.primary,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: TSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return TColors.primary.withOpacity(0.1); // Ripple effect
        }
        return null;
      }),
    ),
  );

  /* -- Dark Theme -- */
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.light, // Light text color in dark mode
      side: const BorderSide(color: TColors.light), // Light border color
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: TColors.light,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: TSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.buttonRadius),
      ),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return TColors.light.withOpacity(0.1); // Ripple effect
        }
        return null;
      }),
    ),
  );
}
