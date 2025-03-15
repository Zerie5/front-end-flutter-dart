import 'package:flutter/material.dart';
import 'package:lul/utils/theme/widget_themes/appbar_theme.dart';
import 'package:lul/utils/theme/widget_themes/bottom_sheet_theme.dart';
import 'package:lul/utils/theme/widget_themes/checkbox_theme.dart';
import 'package:lul/utils/theme/widget_themes/chip_theme.dart';
import 'package:lul/utils/theme/widget_themes/elevated_button_theme.dart';
import 'package:lul/utils/theme/widget_themes/outlined_button_theme.dart';
import 'package:lul/utils/theme/widget_themes/text_field_theme.dart';
import 'package:lul/utils/theme/widget_themes/text_theme.dart';

import '../constants/colors.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    disabledColor: TColors.grey,
    brightness: Brightness.light,
    primaryColor: TColors.primary,
    scaffoldBackgroundColor: TColors.light,
    textTheme: TTextTheme.lightTextTheme,
    chipTheme: TChipTheme.lightChipTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
    splashColor: TColors.accent.withOpacity(0.15),
    hoverColor: TColors.accent.withOpacity(0.2),
    focusColor: TColors.primary.withOpacity(0.2),
    colorScheme: ColorScheme.fromSeed(
      seedColor: TColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      secondary: TColors.secondary, // Secondary color for widgets
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    disabledColor: TColors.darkGrey,
    brightness: Brightness.dark,
    primaryColor: TColors.primaryDark,
    scaffoldBackgroundColor: TColors.primaryDark,
    textTheme: TTextTheme.darkTextTheme,
    chipTheme: TChipTheme.darkChipTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
    splashColor: TColors.accent.withOpacity(0.15),
    hoverColor: TColors.accent.withOpacity(0.2),
    focusColor: TColors.primaryDark.withOpacity(0.2),
    colorScheme: ColorScheme.fromSeed(
      seedColor: TColors.primaryDark,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: TColors.secondary, // Secondary color for widgets
    ),
  );
}
