import 'package:flutter/material.dart';

class FormTextStyle {
  static TextStyle? getHeaderStyle(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white, // White color for titles
          fontWeight: FontWeight.bold,
        );
  }

  static TextStyle? getLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white, // White color for titles
          fontWeight: FontWeight.bold,
        );
  }

  static TextStyle? getHintStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.6), // Faded gray for hints
        );
  }

  static TextStyle? getInfoTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium; // Faded gray for hints
  }
}
