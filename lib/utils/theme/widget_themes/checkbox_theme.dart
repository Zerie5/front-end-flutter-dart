import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/// Custom Class for Light & Dark Checkbox Themes
class TCheckboxTheme {
  TCheckboxTheme._(); // Private constructor to prevent instantiation

  /// Light Mode Checkbox Theme
  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.xs), // Rounded corners
    ),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.white; // White check color when selected
      } else {
        return TColors.black; // Black check color when not selected
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary; // Primary color when selected
      } else {
        return TColors.grey; // Grey outline when not selected
      }
    }),
  );

  /// Dark Mode Checkbox Theme
  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.xs), // Rounded corners
    ),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.black; // Black check color in dark mode
      } else {
        return TColors.white; // White check color when not selected
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return TColors.primary; // Primary color when selected
      } else {
        return TColors.darkGrey; // Subtle dark grey when not selected
      }
    }),
  );
}
