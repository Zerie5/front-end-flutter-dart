import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TChipTheme {
  TChipTheme._();

  /// Light Theme Chip Customization
  static ChipThemeData lightChipTheme = ChipThemeData(
    backgroundColor:
        TColors.grey.withOpacity(0.2), // Background color for unselected chips
    disabledColor: TColors.grey.withOpacity(0.4), // Disabled chip background
    selectedColor: TColors.primary, // Selected chip background
    secondarySelectedColor:
        TColors.accent.withOpacity(0.6), // Secondary selected color
    labelStyle: const TextStyle(
      color: TColors.black, // Label text color for unselected chips
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: const TextStyle(
      color: TColors.white, // Label text color for secondary selected chips
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    ),
    padding: const EdgeInsets.symmetric(
        horizontal: 12.0, vertical: 8.0), // Internal padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0), // Rounded corners
    ),
    checkmarkColor: TColors.white, // Color of the checkmark
    elevation: 2, // Shadow depth
    shadowColor: TColors.grey, // Shadow color
    surfaceTintColor: TColors.light, // Tint color for elevation
  );

  /// Dark Theme Chip Customization
  static ChipThemeData darkChipTheme = ChipThemeData(
    backgroundColor:
        TColors.darkerGrey, // Background color for unselected chips
    disabledColor:
        TColors.darkGrey.withOpacity(0.4), // Disabled chip background
    selectedColor: TColors.primary, // Selected chip background
    secondarySelectedColor:
        TColors.accent.withOpacity(0.6), // Secondary selected color
    labelStyle: const TextStyle(
      color: TColors.white, // Label text color for unselected chips
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: const TextStyle(
      color: TColors.black, // Label text color for secondary selected chips
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    ),
    padding: const EdgeInsets.symmetric(
        horizontal: 12.0, vertical: 8.0), // Internal padding
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0), // Rounded corners
    ),
    checkmarkColor: TColors.white, // Color of the checkmark
    elevation: 2, // Shadow depth
    shadowColor: TColors.black, // Shadow color
    surfaceTintColor: TColors.dark, // Tint color for elevation
  );
}
