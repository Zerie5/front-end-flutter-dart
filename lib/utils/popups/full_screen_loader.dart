import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../loaders/animation_loader.dart';
import '../helpers/helper_functions.dart'; // Import THelperFunctions

/// A utility class for managing a full-screen loading dialog.
class TFullScreenLoader {
  /// Opens a full-screen loading dialog with a provided text and animation.
  ///
  /// Parameters:
  ///   - text: The text to display below the animation.
  ///   - animation: The path to the Lottie animation file.
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (_) => PopScope(
        canPop: false, // Disable back button
        child: Builder(
          builder: (context) => Container(
            color: THelperFunctions.getScreenBackgroundColor(
                context), // Dynamically set background
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: TAnimationLoaderWidget(
                text: text, // Text to display below the loader
                animation: animation, // Path to the Lottie animation
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Stops the currently open loading dialog.
  static void stopLoading() {
    if (Navigator.of(Get.overlayContext!).canPop()) {
      Navigator.of(Get.overlayContext!).pop();
    }
  }
}
