import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/language/language_controller.dart';

class LanguageSelectionPage extends StatelessWidget {
  final LanguageController _languageController = Get.put(LanguageController());

  LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select Language",
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Obx(() => DropdownButton<int>(
                value: _languageController.selectedLanguage.value,
                items: const [
                  DropdownMenuItem(value: 1, child: Text("English")),
                  DropdownMenuItem(value: 2, child: Text("Tigrinya")),
                  DropdownMenuItem(value: 3, child: Text("French")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _languageController.updateLanguage(value);
                  }
                },
              )),
        ],
      ),
    );
  }
}
