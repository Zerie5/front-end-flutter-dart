import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class YourPhoneScreen extends StatelessWidget {
  YourPhoneScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final LanguageController _languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss keyboard
      },
      child: Scaffold(
        backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Obx(() {
            return Text(_languageController.getText('phone'),
                style: FormTextStyle.getHeaderStyle(context));
          }),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(_languageController.getText('phone'),
                      style: FormTextStyle.getLabelStyle(context)),
                  const SizedBox(height: 8),
                  LulPhoneTextFormField(
                    phoneController: _phoneController,
                    languageController: _languageController,
                    hintStyle: FormTextStyle.getHintStyle(context),
                    onRegionChanged: (String flag, IsoCode region) {},
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: LulButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            LulLoaders.lulsuccessSnackBar(
                              title: _languageController.getText('ok'),
                              message: _languageController
                                  .getText('phonesavedsnack'),
                            ),
                          );
                        }
                      },
                      text: _languageController.getText('save'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
