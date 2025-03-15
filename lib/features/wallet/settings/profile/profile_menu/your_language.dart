import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_dropdown_style.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/language/language_controller.dart';

class YourLanguageScreen extends StatefulWidget {
  const YourLanguageScreen({super.key});

  @override
  State<YourLanguageScreen> createState() => _YourLanguageScreenState();
}

class _YourLanguageScreenState extends State<YourLanguageScreen> {
  final _formKey = GlobalKey<FormState>();
  final LanguageController _languageController = Get.put(LanguageController());
  int? _selectedLanguage; // Store selected language locally for Save

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark
          ? TColors.primaryDark
          : TColors.primary, // Same background as Settin
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        title: Obx(() {
          return Text(_languageController.getText('languageselection'),
              style: FormTextStyle.getHeaderStyle(context));
        }),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Obx(() {
                return Text(
                  _languageController.getText('selectlanguage'),
                  style: FormTextStyle.getLabelStyle(context),
                  textAlign: TextAlign.center,
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                return LulDropdown<int>(
                  value: _selectedLanguage ??
                      _languageController.selectedLanguage.value,
                  hintText: 'Select Language', // Optional
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("English")),
                    DropdownMenuItem(value: 2, child: Text("Tigrinya")),
                    DropdownMenuItem(value: 3, child: Text("French")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedLanguage = value;
                    }
                  },
                );
              }),
              const Spacer(),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  return LulButton(
                    onPressed: () {
                      if (_selectedLanguage != null) {
                        _languageController.updateLanguage(_selectedLanguage!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          LulLoaders.lulsuccessSnackBar(
                            title: _languageController.getText('ok'),
                            message: _languageController
                                .getText('languagesavedsnack'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Please select a language before saving."),
                          ),
                        );
                      }
                    },
                    text: _languageController.getText('save'),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
