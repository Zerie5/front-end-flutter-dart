import 'package:flutter/material.dart';
import 'package:lul/utils/constants/sizes.dart';
import '../../constants/colors.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.primary, // Primary color for light mode
    surfaceTintColor: TColors.primary,
    iconTheme: IconThemeData(
        color: TColors.white, size: TSizes.iconMd), // White icons for contrast
    actionsIconTheme: IconThemeData(
        color: TColors.white, size: TSizes.iconMd), // White action icons
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: TColors.white, // White title for contrast
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: TColors.dark, // Dark primary color for dark mode
    surfaceTintColor: TColors.dark,
    iconTheme: IconThemeData(
        color: TColors.light, size: TSizes.iconMd), // Light icons for contrast
    actionsIconTheme: IconThemeData(
        color: TColors.light, size: TSizes.iconMd), // Light action icons
    titleTextStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: TColors.light, // Light title for contrast
    ),
  );
}
