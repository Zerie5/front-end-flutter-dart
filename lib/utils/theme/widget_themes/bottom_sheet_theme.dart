import 'package:flutter/material.dart';
import 'package:lul/utils/constants/colors.dart';

class TBottomSheetTheme {
  TBottomSheetTheme._();

  static BottomSheetThemeData lightBottomSheetTheme =
      const BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: TColors.light, // Light background color
    modalBackgroundColor: TColors.primary, // Primary color for modal sheets
    constraints: BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16), // Top corners rounded
      ),
    ),
  );

  static BottomSheetThemeData darkBottomSheetTheme = const BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: TColors.dark, // Dark background for persistent sheets
    modalBackgroundColor: TColors.dark, // Dark modal background
    constraints: BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16), // Top corners rounded
      ),
    ),
  );
}
