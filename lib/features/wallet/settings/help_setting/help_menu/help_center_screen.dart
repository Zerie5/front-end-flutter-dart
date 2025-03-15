import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_dropdown_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/validators/validation.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final LanguageController _languageController = Get.find<LanguageController>();

  String _selectedCategory = 'general'; // Default category key

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        LulLoaders.lulsuccessSnackBar(
          title: _languageController.getText('success'),
          message: _languageController.getText('message_sent_successfully'),
        ),
      );

      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedCategory = 'general';
      });
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
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
          title: Text(
            _languageController.getText('help_center'),
            style: FormTextStyle.getHeaderStyle(context),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: screenHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  _languageController.getText('problem_category'),
                  style: FormTextStyle.getLabelStyle(context),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  // Dynamically update dropdown items based on language
                  return LulDropdown(
                    value: _selectedCategory,
                    items: [
                      DropdownMenuItem(
                        value: 'general',
                        child: Text(
                            _languageController.getText('drop_down_general')),
                      ),
                      DropdownMenuItem(
                        value: 'technical',
                        child: Text(
                            _languageController.getText('drop_down_account')),
                      ),
                      DropdownMenuItem(
                        value: 'account',
                        child: Text(_languageController
                            .getText('drop_down_trasactions')),
                      ),
                      DropdownMenuItem(
                        value: 'security',
                        child: Text(
                            _languageController.getText('drop_down_security')),
                      ),
                      DropdownMenuItem(
                        value: 'technical',
                        child: Text(
                            _languageController.getText('drop_down_technical')),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(
                            _languageController.getText('drop_down_other')),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    hintText: _languageController.getText('select_category'),
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  _languageController.getText('problem_subject'),
                  style: FormTextStyle.getLabelStyle(context),
                ),
                const SizedBox(height: 8),
                LulGeneralTextFormField(
                  hintText: _languageController.getText('enter_subject'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                  controller: _subjectController,
                  textInputAction: TextInputAction.next,
                  validator: (value) => LValidator().validateEmpty(
                      value, _languageController.getText('problem_subject')),
                ),
                const SizedBox(height: 16),
                Text(
                  _languageController.getText('problem_message'),
                  style: FormTextStyle.getLabelStyle(context),
                ),
                const SizedBox(height: 8),
                LulGeneralTextFormField(
                  hintText: _languageController.getText('enter_message'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                  controller: _messageController,
                  textInputAction: TextInputAction.done,
                  validator: (value) => LValidator().validateEmpty(
                      value, _languageController.getText('problem_message')),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: LulButton(
                      onPressed: _submitForm,
                      text: _languageController.getText('save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
