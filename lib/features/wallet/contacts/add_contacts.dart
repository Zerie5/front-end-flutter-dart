import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/features/wallet/contacts/models/contact_model.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/validators/validation.dart';

class LulAddContactScreen extends StatefulWidget {
  const LulAddContactScreen({super.key});

  @override
  State<LulAddContactScreen> createState() => _LulAddContactScreenState();
}

class _LulAddContactScreenState extends State<LulAddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final TextEditingController _idController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();
  final bool _isLoading = false;
  ContactModel? _foundContact;
  bool _showContactInfo = false;

  void _resetContactInfo() {
    setState(() {
      _showContactInfo = false;
      _foundContact = null;
    });
  }

  Future<void> _handleSaveButtonPress() async {
    if (_formKey.currentState!.validate()) {
      final id = _idController.text;

      _resetContactInfo();

      // Show loader
      LulLoaders.showLoadingDialog();

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // First check in myContacts
      final existingContact = myContacts.firstWhere(
        (contact) => contact.id == id,
        orElse: () => ContactModel(
          id: '',
          fullName: '',
          telephone: '',
          email: '',
        ),
      );

      // Dismiss loader before showing result
      Get.back(); // Dismisses the loader

      if (existingContact.id.isNotEmpty) {
        LulLoaders.lulinfoSnackBar(
          title: _languageController.getText('contact_exists_snack'),
          message: _languageController.getText('contact_exists_message_snack'),
        );
        return;
      }

      // If not in myContacts, search in databaseUsers
      final databaseContact = databaseUsers.firstWhere(
        (contact) => contact.id == id,
        orElse: () => ContactModel(
          id: '',
          fullName: '',
          telephone: '',
          email: '',
        ),
      );

      setState(() {
        if (databaseContact.id.isNotEmpty) {
          _foundContact = databaseContact;
          _showContactInfo = true;
        } else {
          LulLoaders.lulerrorSnackBar(
            title: _languageController.getText('not_found'),
            message: _languageController.getText('user_not_found_snack'),
          );
        }
      });
    }
  }

  // Add this method to build the contact info tile
  Widget _buildContactTile(ContactModel contact) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          contact.fullName,
          style: const TextStyle(
            color: TColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'ID: ${contact.id}',
              style: TextStyle(
                color: TColors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              contact.email,
              style: TextStyle(
                color: TColors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
        body: Stack(
          children: [
            Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Obx(() {
                    return Text(
                      _languageController.getText('add_contact'),
                      style: FormTextStyle.getHeaderStyle(context),
                    );
                  }),
                  centerTitle: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Obx(() => Text(
                              _languageController.getText('contact_id'),
                              style: FormTextStyle.getLabelStyle(context),
                            )),
                        const SizedBox(height: 8),
                        Obx(() => LulGeneralTextFormField(
                              controller: _idController,
                              focusNode: _idFocusNode,
                              hintText:
                                  _languageController.getText('enter_user_id'),
                              hintStyle: FormTextStyle.getHintStyle(context),
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                _resetContactInfo();
                                return LValidator()
                                    .validateUserIDEntry(value ?? "");
                              },
                              onChanged: (value) {
                                // This will trigger the validator and show error message
                                _formKey.currentState?.validate();

                                String? validationError =
                                    LValidator().validateUserIDEntry(value);
                                if (validationError == null &&
                                    value.length == 6) {
                                  _handleSaveButtonPress();
                                }
                              },
                            )),
                        const SizedBox(height: 20),
                        if (_showContactInfo && _foundContact != null)
                          _buildContactTile(_foundContact!),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: LulButton(
                      onPressed: () {
                        _resetContactInfo();
                        LulLoaders.lulsuccessSnackBar(
                          title: _languageController.getText('success'),
                          message: _languageController
                              .getText('contact_saved_message_snack'),
                        );
                      },
                      text: _languageController.getText('save'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _idFocusNode.dispose();
    super.dispose();
  }
}
