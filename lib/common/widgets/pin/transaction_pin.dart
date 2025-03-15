import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/popups/full_screen_loader.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_controller.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/common/widgets/pin/create_new_pin.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_controller.dart';

class TransactionPinCheckScreen extends StatefulWidget {
  final Function(String pin) onPinVerified;
  final int maxAttempts;

  const TransactionPinCheckScreen({
    super.key,
    required this.onPinVerified,
    this.maxAttempts = 3,
  });

  @override
  _TransactionPinCheckScreenState createState() =>
      _TransactionPinCheckScreenState();
}

class _TransactionPinCheckScreenState extends State<TransactionPinCheckScreen>
    with SingleTickerProviderStateMixin {
  final PINController _pinController = Get.find<PINController>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final LulLoaders _loaders = Get.find<LulLoaders>();

  // Controllers for the four PIN digit fields.
  final List<TextEditingController> _pinDigitControllers =
      List.generate(4, (_) => TextEditingController());
  int _wrongAttempts = 0;

  // Animation controller for shake effect
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Set the flag to disable currency refreshes
    CurrencyController.isPinCheckActive = true;
    print('TransactionPinScreen: Showing PIN check dialog');

    // Initialize shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  @override
  void dispose() {
    // Clear the flag when PIN check is dismissed
    CurrencyController.isPinCheckActive = false;
    print('TransactionPinScreen: PIN check dialog dismissed');

    for (final controller in _pinDigitControllers) {
      controller.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  /// Concatenates the 4 digits into a string.
  String get _enteredPin =>
      _pinDigitControllers.map((controller) => controller.text).join();

  /// Clears all digit inputs.
  void _clearPinInputs() {
    for (final controller in _pinDigitControllers) {
      controller.clear();
    }
    setState(() {});
  }

  /// Called when a digit is pressed on the keypad.
  void _onDigitPressed(String digit) {
    for (int i = 0; i < 4; i++) {
      if (_pinDigitControllers[i].text.isEmpty) {
        _pinDigitControllers[i].text = digit;
        break;
      }
    }
    setState(() {});
    if (_enteredPin.length == 4) {
      _verifyPin(_enteredPin);
    }
  }

  /// Called when the backspace button is pressed.
  void _onBackspacePressed() {
    for (int i = 3; i >= 0; i--) {
      if (_pinDigitControllers[i].text.isNotEmpty) {
        _pinDigitControllers[i].clear();
        break;
      }
    }
    setState(() {});
  }

  /// Triggers the shake animation for wrong PIN
  void _triggerShakeAnimation() {
    _shakeController.forward(from: 0.0);
  }

  /// Verifies the entered PIN using the PINController.
  Future<void> _verifyPin(String pin) async {
    print('TransactionPinScreen: Verifying PIN with length ${pin.length}');

    // Show a full-screen loading dialog while validating the PIN.
    TFullScreenLoader.openLoadingDialog(
      _languageController.getText('validating_pin'),
      'assets/lottie/lottie.json',
    );

    try {
      final validationResult = await _pinController.validatePin(pin);
      print(
          'TransactionPinScreen: PIN validation result: ${validationResult['isValid']}');

      // Dismiss the loading dialog if it's still open.
      TFullScreenLoader.stopLoading();

      if (validationResult['isValid']) {
        print(
            'TransactionPinScreen: PIN is valid, preparing to call onPinVerified');
        _wrongAttempts = 0;
        // Clear the flag when PIN validation is successful
        CurrencyController.isPinCheckActive = false;

        // Store the verified PIN
        final String verifiedPin = pin;

        // First close the PIN screen to avoid navigation issues
        print('TransactionPinScreen: Closing PIN screen');
        Get.back();

        // Then call the callback with the PIN value after a short delay
        // This ensures the screen is fully dismissed before the next screen is shown
        print('TransactionPinScreen: Scheduling callback with verified PIN');
        Future.delayed(const Duration(milliseconds: 100), () {
          print(
              'TransactionPinScreen: Calling onPinVerified with verified PIN');
          widget.onPinVerified(verifiedPin);
        });
      } else {
        // Handle different error types
        final errorType = validationResult['errorType'];
        final errorMessage = validationResult['errorMessage'];

        switch (errorType) {
          case 'session_expired':
            // Handle session expiry - redirect to login
            _loaders.errorDialog(
              title: _languageController.getText('session_expired'),
              message: errorMessage,
              onPressed: () {
                // Navigate to login screen directly
                Get.offAll(() => LoginScreen());
              },
            );
            break;

          case 'pin_not_set':
            // Handle PIN not set - redirect to PIN setup
            _loaders.warningDialog(
              title: _languageController.getText('pin_not_set'),
              message: errorMessage,
              onPressed: () {
                // Navigate to PIN setup screen directly
                Get.off(() => const CreatePinScreen());
              },
            );
            break;

          case 'connectivity':
            // Handle connectivity issues - don't count against attempts
            _loaders.warningDialog(
              title: _languageController.getText('connection_error'),
              message: errorMessage,
              onPressed: () {
                _clearPinInputs();
              },
            );
            break;

          case 'wrong_pin':
            // Handle wrong PIN - count against attempts and show shake animation
            _wrongAttempts++;
            _triggerShakeAnimation();

            if (_wrongAttempts >= widget.maxAttempts) {
              // If maximum wrong attempts are reached, show an error dialog and close the app.
              print('Max attempts reached, showing error dialog');
              _loaders.errorDialog(
                title: _languageController.getText('error'),
                message: _languageController.getText('max_attempts_reached'),
                onPressed: () => exit(0), // Exit app when OK is clicked
              );
            } else {
              final remainingAttempts = widget.maxAttempts - _wrongAttempts;
              print('Remaining attempts: $remainingAttempts');

              _loaders.warningDialog(
                title: _languageController.getText('warning'),
                message:
                    "${_languageController.getText('pin_incorrect')} $remainingAttempts ${_languageController.getText('pin_attempt')}",
                onPressed: () {
                  _clearPinInputs();
                },
              );
            }
            break;

          default:
            // Handle other errors
            _loaders.errorDialog(
              title: _languageController.getText('error'),
              message: errorMessage,
              onPressed: () {
                _clearPinInputs();
              },
            );
        }
      }
    } catch (e) {
      // In case of an exception, dismiss the loader and show an error dialog.
      TFullScreenLoader.stopLoading();
      _clearPinInputs();
      LulLoaders.lulerrorSnackBar(
        title: _languageController.getText('error'),
        message: e.toString(),
      );
    }
  }

  /// Builds the row of four PIN dots.
  Widget _buildPinDots() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * sin(_wrongAttempts * 3), 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          bool filled = _pinDigitControllers[index].text.isNotEmpty;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: 12,
              backgroundColor:
                  filled ? Colors.white : Colors.white.withOpacity(0.2),
            ),
          );
        }),
      ),
    );
  }

  /// Builds an individual keypad button.
  Widget _buildKeypadButton(String value) {
    if (value == "backspace") {
      return IconButton(
        icon: const Icon(Icons.backspace, color: Colors.white),
        onPressed: _onBackspacePressed,
      );
    } else if (value.isEmpty) {
      return const SizedBox();
    } else {
      return TextButton(
        onPressed: () => _onDigitPressed(value),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  /// Builds the numeric keypad grid.
  Widget _buildNumericKeypad() {
    final List<String> keypadItems = [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "",
      "0",
      "backspace"
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keypadItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
      ),
      itemBuilder: (context, index) {
        return _buildKeypadButton(keypadItems[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ? TColors.primaryDark : TColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _languageController.getText('Confirm Transaction'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: PopScope(
        canPop: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: dark ? TColors.primaryDark : TColors.primary,
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                _languageController.getText('Enter PIN to Confirm'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _buildPinDots(),
              const Spacer(),
              _buildNumericKeypad(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
