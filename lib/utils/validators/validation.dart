import 'package:get/get.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class LValidator {
  // Private constructor for Singleton
  LValidator._privateConstructor();

  // The single instance of the class
  static final LValidator _instance = LValidator._privateConstructor();

  // Factory constructor to return the same instance
  factory LValidator() {
    return _instance;
  }

  // LanguageController dependency
  final LanguageController _languageController = Get.find<LanguageController>();

  // Validator Methods

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return _languageController.getText('emailisreq');
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return _languageController.getText('emailisinvalid');
    }

    return null;
  }

  String? validateDropdownSelection(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${_languageController.getText('isreq')}';
    }
    return null;
  }

  String? validateEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ${_languageController.getText('isreq')}';
    }
    return null;
  }

  String? validatePhoneNumber(String? value, {IsoCode? regionCode}) {
    if (value == null || value.isEmpty) {
      return _languageController.getText('phoneisreq');
    }

    if (regionCode == null) {
      return _languageController.getText('invalidphonenocountry');
    }

    try {
      final parsedPhone =
          PhoneNumber.parse(value, destinationCountry: regionCode);
      if (!parsedPhone.isValid()) {
        return _languageController.getText('invalidphoneforregion');
      }
    } catch (e) {
      return _languageController.getText('invalidphoneformat');
    }

    return null;
  }

  String? validatePINEntry(String value) {
    {
      if (value.isEmpty) {
        return _languageController.getText('pin_required');
      }
      if (value.length != 4) {
        return _languageController.getText('pin_length_error');
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return _languageController.getText('pin_numeric_error');
      }
      return null;
    }
  }

  String? validateUserIDEntry(String value) {
    {
      if (value.isEmpty) {
        return _languageController.getText('id_required');
      }
      if (value.length != 10) {
        return _languageController.getText('id_length_error');
      }
      // if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      // return _languageController.getText('id_numeric_error');
      // }
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _languageController.getText('password_required');
    }

    // Check minimum length
    if (value.length < 8) {
      return _languageController.getText('password_length');
    }

    // Check for uppercase letters
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return _languageController.getText('password_uppercase');
    }

    // Check for lowercase letters
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return _languageController.getText('password_lowercase');
    }

    // Check for numbers
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return _languageController.getText('password_number');
    }

    return null;
  }
}
