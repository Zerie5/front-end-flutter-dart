import 'package:get/get.dart';
import 'language_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  var selectedLanguage = 1.obs;

  String get currentLanguage => selectedLanguage.value == 1 ? 'en' : 'ti';

  @override
  void onInit() {
    super.onInit();
    _loadLanguagePreference();
  }

  /// Load language preference from storage
  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedLanguage.value =
        prefs.getInt('selectedLanguage') ?? 1; // Default to 1 (English)
  }

  /// Update the language preference
  void updateLanguage(int value) async {
    selectedLanguage.value = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'selectedLanguage', value); // Save the choice permanently
  }

  /// Reset the language preference to null (default to English)
  Future<void> resetLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedLanguage'); // Remove the preference
    selectedLanguage.value = 1; // Reset to default language
  }

  /// A helper function to get the translated text
  String getText(String key) {
    return LanguageTexts.getText(selectedLanguage.value, key);
  }
}
