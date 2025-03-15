import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  /// Style for user-entered text (applies to all text fields)
  static TextStyle getTextStyle(BuildContext context) {
    return const TextStyle(
      color: TColors.white, // User-entered text color
      fontSize: TSizes.fontSizeMd, // User-entered text size
    );
  }

  /// Hint style (color and size)

  /// Light theme InputDecoration
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    filled: true,
    fillColor: TColors.light.withOpacity(0.2),
    prefixIconColor: TColors.darkGrey,
    suffixIconColor: TColors.darkGrey,
    labelStyle:
        const TextStyle(fontSize: TSizes.fontSizeLg, color: TColors.white),
    floatingLabelStyle: const TextStyle(color: TColors.white),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.grey),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.grey),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.primary),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.error),
    ),
  );

  /// Dark theme InputDecoration
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    filled: true,
    fillColor: TColors.grey.withOpacity(0.2),
    prefixIconColor: TColors.grey,
    suffixIconColor: TColors.grey,
    labelStyle:
        const TextStyle(fontSize: TSizes.fontSizeMd, color: TColors.white),
    floatingLabelStyle: const TextStyle(color: TColors.white),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.darkGrey),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.darkGrey),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.primary),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(TSizes.inputFieldRadius)),
      borderSide: BorderSide(color: TColors.error),
    ),
  );

  /// Method to dynamically provide `InputDecoration` based on the current theme
  static InputDecoration getInputDecoration(
      BuildContext context, String hintText) {
    final theme = Theme.of(context).brightness;
    final InputDecorationTheme themeData = theme == Brightness.dark
        ? darkInputDecorationTheme
        : lightInputDecorationTheme;

    return InputDecoration(
      hintText: hintText,
      labelStyle: themeData.labelStyle,
      hintStyle: themeData.hintStyle, // Apply centralized hint style
      floatingLabelStyle: themeData.floatingLabelStyle,
      border: themeData.border,
      enabledBorder: themeData.enabledBorder,
      focusedBorder: themeData.focusedBorder,
      errorBorder: themeData.errorBorder,
      focusedErrorBorder: themeData.focusedErrorBorder,
      prefixIconColor: themeData.prefixIconColor,
      suffixIconColor: themeData.suffixIconColor,
    );
  }
}
