import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/services/pin_service.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/numkey/numeric_keypad.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/utils/constants/sizes.dart';
// Reusable keypad widget

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final LanguageController _languageController = Get.find<LanguageController>();
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final RxBool isLoading = false.obs;
  final RxBool isPinVisible = false.obs;

  @override
  void dispose() {
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Combines the four controllers into a PIN string.
  String get _enteredPin =>
      _pinControllers.map((controller) => controller.text).join();

  /// Clears the PIN inputs.
  void _clearPinControllers() {
    for (final controller in _pinControllers) {
      controller.clear();
    }
    setState(() {});
  }

  Future<void> _handlePinSubmit() async {
    try {
      // 1. Ensure the user is authenticated.
      final token = await AuthStorage.getToken();
      if (token == null) {
        Get.find<LulLoaders>().errorDialog(
          title: _languageController.getText('error'),
          message: _languageController.getText('no_user_signed_in'),
          onPressed: () => Get.offAll(() => LoginScreen()),
        );
        return;
      }

      // 2. Validate the PIN format.
      final pin = _enteredPin;
      if (!_validatePin(pin)) return;

      // 3. Confirm with the user.
      final shouldProceed = await LulLoaders.alertDialog(
        title: _languageController.getText('confirm_pin'),
        message: _languageController.getText('confirm_pin_message'),
        confirmText: _languageController.getText('yes'),
        cancelText: _languageController.getText('no'),
      );
      if (!shouldProceed) return;

      // 4. Update the PIN via backend.
      isLoading.value = true;
      final response = await PinService.createPin(pin);

      if (response['status'] == 'success') {
        // Default to stage 4 if registrationStatus is not in response
        final registrationStatus = response['registrationStatus'] ?? 4;

        await AuthStorage.saveRegistrationStage(registrationStatus);
        await AuthStorage.clearToken();
        _clearPinControllers();

        Get.find<LulLoaders>().successDialog(
          title: _languageController.getText('success'),
          message: _languageController.getText('pin_created_login'),
          onPressed: () => Get.offAll(() => LoginScreen()),
        );
      } else {
        // Handle specific error codes.
        String errorMessage;
        switch (response['code']) {
          case 'ERR_602':
            errorMessage = _languageController.getText('pin_creation_failed');
            break;
          case 'ERR_502':
            errorMessage = _languageController.getText('session_expired');
            Get.offAll(() => LoginScreen());
            break;
          default:
            errorMessage = _languageController.getText('something_went_wrong');
        }
        Get.find<LulLoaders>().errorDialog(
          title: _languageController.getText('error'),
          message: errorMessage,
        );
      }
    } catch (e) {
      Get.find<LulLoaders>().errorDialog(
        title: _languageController.getText('error'),
        message: _languageController.getText('something_went_wrong'),
      );
      print('PIN creation error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Validates that the PIN is exactly 4 digits, numeric, and not overly simple.
  bool _validatePin(String pin) {
    if (pin.length != 4) {
      Get.find<LulLoaders>().errorDialog(
        title: _languageController.getText('error'),
        message: _languageController.getText('enter_complete_pin'),
      );
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      Get.find<LulLoaders>().errorDialog(
        title: _languageController.getText('error'),
        message: _languageController.getText('pin_must_be_numbers'),
      );
      return false;
    }
    if ([
      '1234',
      '4321',
      '0000',
      '1111',
      '2222',
      '3333',
      '4444',
      '5555',
      '6666',
      '7777',
      '8888',
      '9999'
    ].contains(pin)) {
      Get.find<LulLoaders>().errorDialog(
        title: _languageController.getText('error'),
        message: _languageController.getText('pin_too_simple'),
      );
      return false;
    }
    return true;
  }

  /// Handles digit input from the keypad.
  void _onDigitEntered(String digit) {
    for (int i = 0; i < 4; i++) {
      if (_pinControllers[i].text.isEmpty) {
        _pinControllers[i].text = digit;
        break;
      }
    }
    setState(() {});
  }

  /// Handles backspace action from the keypad.
  void _onBackspacePressed() {
    for (int i = 3; i >= 0; i--) {
      if (_pinControllers[i].text.isNotEmpty) {
        _pinControllers[i].clear();
        break;
      }
    }
    setState(() {});
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
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 70),
              Obx(() => Text(
                    _languageController.getText('create_pin'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      _languageController.getText('pin_description'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      4,
                      (index) => Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Obx(() => TextField(
                              controller: _pinControllers[index],
                              readOnly: true,
                              obscureText: !isPinVisible.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Obx(() => Icon(
                            isPinVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white.withOpacity(0.5),
                            size: 22,
                          )),
                      onPressed: () => isPinVisible.value = !isPinVisible.value,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              // Use the reusable numeric keypad.
              NumericKeypad2(
                onDigitPressed: _onDigitEntered,
                onBackspacePressed: _onBackspacePressed,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.defaultSpace,
                  vertical: TSizes.sm,
                ),
                child: Obx(() => LulButton(
                      onPressed: _handlePinSubmit,
                      text: _languageController.getText('save'),
                      isLoading: isLoading.value,
                      foregroundColor: Colors.white,
                      height: 55,
                    )),
              ),
              const SizedBox(height: TSizes.defaultSpace),
            ],
          ),
        ),
      ),
    );
  }
}
