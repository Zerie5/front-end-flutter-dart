import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';

import 'package:lul/features/wallet/settings/security_setting/widgets/pin_controller.dart';

import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/full_screen_loader.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/validators/validation.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/services/pin_service.dart';

class LulUpdatePinScreen extends StatefulWidget {
  const LulUpdatePinScreen({super.key});

  @override
  State<LulUpdatePinScreen> createState() => _LulUpdatePinScreenState();
}

class _LulUpdatePinScreenState extends State<LulUpdatePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  final PINController _pinController = Get.find<PINController>();
  final LanguageController _languageController = Get.find<LanguageController>();

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _clearAllFields() {
    _currentPinController.clear();
    _newPinController.clear();
    _confirmPinController.clear();
  }

  bool _isSequentialPin(String pin) {
    const ascending = '0123456789';
    const descending = '9876543210';
    return ascending.contains(pin) || descending.contains(pin);
  }

  bool _isRepeatedPin(String pin) {
    return pin.split('').toSet().length == 1; // e.g., '1111', '0000'
  }

  void _savePin() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      // Check if new PIN matches confirmation PIN
      if (_newPinController.text != _confirmPinController.text) {
        Get.find<LulLoaders>().warningDialog(
          title: _languageController.getText('warning'),
          message: _languageController.getText('pin_mismatch'),
        );
        return;
      }

      // Check if new PIN is same as current PIN
      if (_currentPinController.text == _newPinController.text) {
        Get.find<LulLoaders>().warningDialog(
          title: _languageController.getText('warning'),
          message: _languageController.getText('new_pin_same_as_current'),
        );
        return;
      }

      // Check for sequential numbers
      if (_isSequentialPin(_newPinController.text)) {
        Get.find<LulLoaders>().warningDialog(
          title: _languageController.getText('warning'),
          message: _languageController.getText('pin_sequential'),
        );
        return;
      }

      // Check for repeated numbers
      if (_isRepeatedPin(_newPinController.text)) {
        Get.find<LulLoaders>().warningDialog(
          title: _languageController.getText('warning'),
          message: _languageController.getText('pin_repeated'),
        );
        return;
      }

      // First verify current PIN
      TFullScreenLoader.openLoadingDialog(
        _languageController.getText('validating_pin'),
        'assets/lottie/lottie.json',
      );

      try {
        final isCurrentPinValid =
            await _pinController.validatePin(_currentPinController.text);

        // Always stop loading immediately after validation
        Get.back(); // Dismiss the loader explicitly
        TFullScreenLoader
            .stopLoading(); // Extra safety to ensure loader is gone

        if (!mounted) return;

        if (!isCurrentPinValid['isValid']) {
          Get.find<LulLoaders>().errorDialog(
            title: _languageController.getText('error'),
            message: _languageController.getText('current_pin_incorrect'),
          );
          return;
        }

        // If current PIN is valid, proceed with update
        TFullScreenLoader.openLoadingDialog(
          _languageController.getText('updating_pin'),
          'assets/lottie/lottie.json',
        );

        final response = await PinService.updatePin(_newPinController.text);

        // Always stop loading before showing any messages
        TFullScreenLoader.stopLoading(); // Dismiss the loader

        ///if (!mounted) return;

        if (response['status'] == 'success') {
          // Show success dialog and navigate back to security screen
          Get.find<LulLoaders>().successDialog(
            title: _languageController.getText('success'),
            message: _languageController.getText('pin_update_success'),
            onPressed: () {
              _clearAllFields();
              Get.back(); // Return to security screen
            },
          );
        } else {
          Get.find<LulLoaders>().errorDialog(
            title: _languageController.getText('error'),
            message: _languageController.getText('pin_update_failed'),
          );
        }
      } catch (e) {
        // Ensure loader is stopped in case of errors
        Get.back(); // Dismiss the loader explicitly
        TFullScreenLoader
            .stopLoading(); // Extra safety to ensure loader is gone

        if (!mounted) return;

        Get.find<LulLoaders>().errorDialog(
          title: _languageController.getText('error'),
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back(); // Proper back navigation
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            title: Obx(() {
              return Text(_languageController.getText('update_pin'),
                  style: FormTextStyle.getHeaderStyle(context));
            }),
            centerTitle: true,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(_languageController.getText('current_pin'),
                            style: FormTextStyle.getLabelStyle(context)),
                        const SizedBox(height: 8),
                        LulGeneralTextFormField(
                          hintText:
                              _languageController.getText('current_pin_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          obscureText: true,
                          controller: _currentPinController,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              LValidator().validatePINEntry(value ?? ""),
                        ),
                        const SizedBox(height: 16),
                        Text(_languageController.getText('new_pin'),
                            style: FormTextStyle.getLabelStyle(context)),
                        const SizedBox(height: 8),
                        LulGeneralTextFormField(
                          hintText: _languageController.getText('new_pin_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          obscureText: true,
                          controller: _newPinController,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              LValidator().validatePINEntry(value ?? ""),
                        ),
                        const SizedBox(height: 16),
                        Text(_languageController.getText('confirm_pin'),
                            style: FormTextStyle.getLabelStyle(context)),
                        const SizedBox(height: 8),
                        LulGeneralTextFormField(
                          hintText:
                              _languageController.getText('confirm_pin_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          obscureText: true,
                          controller: _confirmPinController,
                          textInputAction: TextInputAction.done,
                          validator: (value) =>
                              LValidator().validatePINEntry(value ?? ""),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: LulButton(
                            onPressed: _savePin,
                            text: _languageController.getText('save'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
