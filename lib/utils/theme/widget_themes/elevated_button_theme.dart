import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class TElevatedButtonTheme {
  TElevatedButtonTheme._(); // To avoid creating instances

  /* -- Light Theme -- */
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2, // Slight elevation for depth
      shadowColor: TColors.grey.withOpacity(0.2), // Subtle shadow
      foregroundColor: TColors.textWhite, // Text/Icon color
      backgroundColor: TColors.primary, // Primary button color
      disabledForegroundColor: TColors.lightGrey, // Disabled text/icon color
      disabledBackgroundColor: TColors.buttonDisabled, // Disabled button color
      side: const BorderSide(color: TColors.primary), // Button border
      padding: const EdgeInsets.symmetric(
          vertical: TSizes.buttonHeight), // Internal padding
      textStyle: const TextStyle(
        fontSize: 16,
        color: TColors.textWhite, // Text color inside button
        fontWeight: FontWeight.w600, // Medium weight for text
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(TSizes.buttonRadius), // Rounded corners
      ),
    ),
  );

  /* -- Dark Theme -- */
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2, // Slight elevation for depth
      shadowColor: TColors.black.withOpacity(0.3), // Subtle shadow in dark mode
      foregroundColor: TColors.textWhite, // Text/Icon color
      backgroundColor: TColors.primary, // Primary button color
      disabledForegroundColor: TColors.darkGrey, // Disabled text/icon color
      disabledBackgroundColor: TColors.darkerGrey, // Disabled button color
      side: const BorderSide(color: TColors.primary), // Button border
      padding: const EdgeInsets.symmetric(
          vertical: TSizes.buttonHeight), // Internal padding
      textStyle: const TextStyle(
        fontSize: 16,
        color: TColors.textWhite, // Text color inside button
        fontWeight: FontWeight.w600, // Medium weight for text
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(TSizes.buttonRadius), // Rounded corners
      ),
    ),
  );
}
