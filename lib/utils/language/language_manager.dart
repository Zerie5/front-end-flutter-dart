import 'package:flutter/material.dart';

// LanguageManager class to handle language settings and translations
class LanguageManager with ChangeNotifier {
  static int _selectedLanguage = 1; // Default language (1 = English)

  int get selectedLanguage => _selectedLanguage;

  void setLanguage(int languageCode) {
    _selectedLanguage = languageCode;
    notifyListeners(); // Notify listeners when the language changes
  }

  String getLanguageText(String key) {
    // Map for localized text
    Map<int, Map<String, String>> localizedText = {
      1: {
        // English
        'title_loginform': 'Lulpay',
        'nameLabel_loginform': 'Name',
        'emailLabel_loginform': 'Email',
        'submit_loginform': 'Submit',
      },
      2: {
        // Tigrigna
        'title_loginform': 'ሉል',
        'nameLabel_loginform': 'ሽም',
        'emailLabel_loginform': 'ኢ-መይል',
        'submit_loginform': 'ዕቖር',
      },
      // Additional languages can be added here
    };

    return localizedText[_selectedLanguage]?[key] ?? key;
  }
}

// Instantiate LanguageManager as a singleton
final languageManager = LanguageManager();
