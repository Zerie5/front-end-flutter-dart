import 'package:flutter/material.dart';

class TileStyles {
  static TextStyle? getTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white, // White color for titles
          fontWeight: FontWeight.bold,
        );
  }

  static TextStyle? getSubtitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white
              .withOpacity(0.8), // Slightly faded white for descriptions
        );
  }
}
