import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_check.dart';
import 'package:lul/features/wallet/settings/security_setting/security_menu/pin_updatescreen.dart';

enum PinNavigationMode { replace, pop }

/// Shows the PIN check screen and awaits a successful verification.
/// - In replace mode, if [targetScreen] is provided, the PIN check screen is replaced by the target screen.
/// - In pop mode, the PIN check screen is simply dismissed.
/// An optional [successMessage] is displayed as a SnackBar.
Future<void> navigateWithPinCheck({
  required Widget targetScreen,
  bool shouldNavigateBack = false,
  String successMessage = "",
}) async {
  print('NavigationUtil: Starting PIN check navigation');

  final result = await Get.to<bool>(
    () => LulCheckPinScreen(
      maxAttempts: 3,
      onSuccess: () {},
    ),
  );

  print('NavigationUtil: PIN check result: $result');

  if (result == true) {
    print('NavigationUtil: PIN check successful, navigating to target screen');
    await Get.to(() => targetScreen);
  }
}

/// For screens that require PIN protection.
/// After a successful PIN check, the target screen is shown.
Future<void> navigateToProtectedScreen(Widget screen,
    {String successMessage = ""}) async {
  await navigateWithPinCheck(
    targetScreen: screen,
    shouldNavigateBack: false,
    successMessage: successMessage,
  );
}

/// For scenarios where only PIN verification is required (e.g. resuming the active screen).
Future<void> verifyPinAndReturn({String successMessage = ""}) async {
  await navigateWithPinCheck(
    targetScreen: LulCheckPinScreen(maxAttempts: 3, onSuccess: () {}),
    shouldNavigateBack: true,
    successMessage: successMessage,
  );
}

Future<void> navigateToPinUpdate() async {
  final result = await Get.to<bool>(
    () => LulCheckPinScreen(maxAttempts: 3, onSuccess: () {}),
  );

  if (result == true) {
    await Get.to(() => const LulUpdatePinScreen());
  }
}
