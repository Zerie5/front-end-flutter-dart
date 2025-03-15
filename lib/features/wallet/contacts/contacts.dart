import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/features/wallet/contacts/models/contact_model.dart';
import 'package:lul/features/wallet/contacts/add_contacts.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';

class LulContactsScreen extends StatefulWidget {
  const LulContactsScreen({super.key});

  @override
  State<LulContactsScreen> createState() => _LulContactsScreenState();
}

class _LulContactsScreenState extends State<LulContactsScreen> {
  final LanguageController _languageController = Get.find<LanguageController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<ContactModel> _filteredContacts = myContacts;

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = myContacts.where((contact) {
        return contact.fullName.toLowerCase().contains(query.toLowerCase()) ||
            contact.id.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredContacts = myContacts;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
        body: Column(
          children: [
            // Top Title
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(
                        _languageController.getText('contacts'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
            ),
            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        _languageController.getText('search_contact'),
                        style: FormTextStyle.getLabelStyle(context),
                      )),
                  const SizedBox(height: 8),
                  Obx(() => LulGeneralTextFormField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        hintText: _languageController.getText('search_by_id'),
                        hintStyle: FormTextStyle.getHintStyle(context),
                        textInputAction: TextInputAction.search,
                        onChanged: _filterContacts,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Contacts List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: TColors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TColors.white.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      onTap: () {
                        // TODO: Navigate to contact details screen
                      },
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
                      subtitle: Text(
                        'ID: ${contact.id}',
                        style: TextStyle(
                          color: TColors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // Floating Add Button
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.to(() => const LulAddContactScreen()),
          backgroundColor: TColors.primary,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
