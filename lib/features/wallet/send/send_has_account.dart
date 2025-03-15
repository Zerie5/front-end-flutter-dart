import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/features/wallet/send/send_contact_detail.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/features/wallet/contacts/models/contact_model.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/validators/validation.dart';
import 'package:lul/services/user_lookup_service.dart';

class LulSendHasAccountScreen extends StatefulWidget {
  const LulSendHasAccountScreen({super.key});
  @override
  State<LulSendHasAccountScreen> createState() =>
      _LulSendHasAccountScreenState();
}

class _LulSendHasAccountScreenState extends State<LulSendHasAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final UserLookupService _userLookupService = Get.find<UserLookupService>();
  final TextEditingController _idController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();

  ///final bool _isLoading = false;
  ContactModel? _foundContact;
  bool _showContactInfo = false;
  bool _isSearching = false;

  void _resetContactInfo() {
    setState(() {
      _showContactInfo = false;
      _foundContact = null;
    });
  }

  Future<void> _handleSaveButtonPress() async {
    if (_formKey.currentState!.validate()) {
      final workId = _idController.text;

      // Don't proceed if already searching
      if (_isSearching) return;

      _resetContactInfo();
      setState(() {
        _isSearching = true;
      });

      // Show loader
      LulLoaders.showLoadingDialog();

      try {
        // Call the API to lookup the user
        final result = await _userLookupService.lookupUser(workId);

        // Dismiss loader before showing result
        Get.back(); // Dismisses the loader

        setState(() {
          _isSearching = false;
        });

        if (result['status'] == 'success') {
          setState(() {
            _foundContact = result['contact'];
            _showContactInfo = true;
          });
        } else {
          // Handle different error codes
          switch (result['code']) {
            case 'ERR_501':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('not_found'),
                message: _languageController.getText('user_not_found_snack'),
              );
              break;
            case 'ERR_003':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message: 'Database error occurred',
              );
              break;
            case 'ERR_002':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message: 'Internal server error',
              );
              break;
            case 'ERR_500':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message:
                    'The server encountered an error processing your request',
              );
              break;
            case 'ERR_404':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('not_found'),
                message: 'User with ID ${_idController.text} was not found',
              );
              break;
            case 'ERR_502':
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message: 'User lookup failed',
              );
              break;
            default:
              LulLoaders.lulerrorDialog(
                title: _languageController.getText('error'),
                message: result['message'] ?? 'Unknown error occurred',
              );
          }
        }
      } catch (e) {
        // Dismiss loader if still showing
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        setState(() {
          _isSearching = false;
        });

        LulLoaders.lulerrorDialog(
          title: _languageController.getText('error'),
          message: 'An unexpected error occurred',
        );
      }
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
        onTap: () => Get.to(() => LulSendContactDetailScreen(contact: contact)),
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
                      _languageController.getText('send_hm'),
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

                                // Trigger search when ID is 10 characters long
                                String? validationError =
                                    LValidator().validateUserIDEntry(value);
                                if (validationError == null &&
                                    value.length == 10) {
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
