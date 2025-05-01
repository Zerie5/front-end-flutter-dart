import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/features/wallet/send/set_amount_screen.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/theme/widget_themes/lul_dropdown_style.dart';
import 'package:lul/utils/validators/validation.dart';
import 'package:lul/utils/constants/country_list_enabled.dart';
import 'package:lul/utils/constants/document_type.dart';
import 'package:lul/features/wallet/send/widgets/transfer_controller.dart';

class SendForNonLulScreen extends StatefulWidget {
  const SendForNonLulScreen({super.key});

  @override
  State<SendForNonLulScreen> createState() => _SendForNonLulScreenState();
}

class _SendForNonLulScreenState extends State<SendForNonLulScreen> {
  final _formKey = GlobalKey<FormState>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final LValidator _validator = LValidator();
  final TransferController _transferController = Get.put(TransferController());

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Dropdown values
  final RxString selectedIdType = ''.obs;
  final RxString selectedCountry = ''.obs;
  final RxString selectedState = ''.obs;
  final RxString selectedCity = ''.obs;

  // Dropdown items
  final List<String> idTypes = defaultDocumentTypes;
  final List<String> countries = countriesenabled;
  final Map<String, List<String>> cities = citiesenabled;

  @override
  void dispose() {
    _fullNameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationshipController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _languageController.getText('fill_details'),
            style: FormTextStyle.getHeaderStyle(context),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Full Name Field
                _buildLabel('full_name'),
                const SizedBox(height: 8),
                LulGeneralTextFormField(
                  hintText: _languageController.getText('full_namehint'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validator.validateEmpty(
                      value, _languageController.getText('full_name')),
                ),

                const SizedBox(height: 16),

                // ID Type Dropdown
                _buildLabel('id_type'),
                Obx(() {
                  return LulDropdown<String>(
                    value: selectedIdType.value.isNotEmpty
                        ? selectedIdType.value
                        : null,
                    items: idTypes
                        .map((idTypes) => DropdownMenuItem(
                            value: idTypes,
                            child: Text(_languageController.getText(idTypes))))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) selectedIdType.value = value;
                    },
                    validator: (_) => _validator.validateDropdownSelection(
                        selectedIdType.value,
                        _languageController.getText('id_type')),
                    hintText: _languageController.getText('id_type_hint'),
                    hintStyle: FormTextStyle.getHintStyle(context),
                  );
                }),

                const SizedBox(height: 16),

                // ID Field
                _buildLabel('doc_id'),
                const SizedBox(height: 8),
                LulGeneralTextFormField(
                  hintText: _languageController.getText('doc_id_hint'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                  controller: _idController,
                  textInputAction: TextInputAction.next,
                  validator: (value) => _validator.validateEmpty(
                      value, _languageController.getText('doc_id')),
                ),

                const SizedBox(height: 16),

                // Phone Field
                _buildLabel('phone'),
                const SizedBox(height: 8),
                LulPhoneTextFormField(
                  phoneController: _phoneController,
                  languageController: _languageController,
                  hintStyle: FormTextStyle.getHintStyle(context),
                ),

                const SizedBox(height: 16),

                // Email Field
                _buildLabel('email'),
                const SizedBox(height: 8),
                LulGeneralTextFormField(
                  hintText: _languageController.getText('reciever_email_hint'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value?.isNotEmpty == true
                      ? _validator.validateEmail(value)
                      : null,
                ),

                const SizedBox(height: 16),

                // Country Dropdown
                _buildLabel('country'),
                const SizedBox(height: 8),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: LulDropdown<String>(
                        value: selectedCountry.value.isNotEmpty
                            ? selectedCountry.value
                            : null,
                        items: countriesenabled
                            .map((country) => DropdownMenuItem(
                                  value: country,
                                  child: Text(
                                      _languageController.getText(country)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCountry.value = value;
                            selectedState.value = '';
                            selectedCity.value = '';
                          }
                        },
                        validator: (_) => _validator.validateDropdownSelection(
                            selectedCountry.value,
                            _languageController.getText('reciever_country')),
                        hintText: _languageController
                            .getText('reciever_country_hint'),
                        hintStyle: FormTextStyle.getHintStyle(context),
                      ),
                    )),

                const SizedBox(height: 16),

                // State Dropdown
                _buildLabel('state'),
                const SizedBox(height: 8),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: LulDropdown<String>(
                        value: selectedState.value.isNotEmpty
                            ? selectedState.value
                            : null,
                        items: selectedCountry.value.isNotEmpty
                            ? statesenabled[selectedCountry.value]
                                    ?.map((state) => DropdownMenuItem(
                                          value: state,
                                          child: Text(_languageController
                                              .getText(state)),
                                        ))
                                    .toList() ??
                                []
                            : [],
                        onChanged: (value) {
                          if (value != null) {
                            selectedState.value = value;
                            selectedCity.value = '';
                          }
                        },
                        validator: (_) => _validator.validateDropdownSelection(
                            selectedState.value,
                            _languageController.getText('state')),
                        hintText: _languageController.getText('state_hint'),
                        hintStyle: FormTextStyle.getHintStyle(context),
                      ),
                    )),

                const SizedBox(height: 16),

                // City Dropdown
                _buildLabel('city'),
                const SizedBox(height: 8),
                Obx(() => LulDropdown<String>(
                      value: selectedCity.value.isNotEmpty
                          ? selectedCity.value
                          : null,
                      items: selectedState.value.isNotEmpty &&
                              selectedCountry.value.isNotEmpty
                          ? (citiesByState[selectedCountry.value]
                                      ?[selectedState.value] ??
                                  [])
                              .map((city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  ))
                              .toList()
                          : [],
                      onChanged: (value) {
                        if (value != null) selectedCity.value = value;
                      },
                      validator: (_) => _validator.validateDropdownSelection(
                          selectedCity.value,
                          _languageController.getText('reciever_city')),
                      hintText:
                          _languageController.getText('reciever_city_hint'),
                      hintStyle: FormTextStyle.getHintStyle(context),
                    )),

                const SizedBox(height: 16),

                // Relationship Field
                _buildLabel('reciever_relationship'),
                const SizedBox(height: 8),
                LulGeneralTextFormField(
                  hintText:
                      _languageController.getText('reciever_relationship_hint'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                  controller: _relationshipController,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // Description Field
                _buildLabel('description'),
                const SizedBox(height: 8),
                LulGeneralTextFormField(
                  hintText: _languageController.getText('description_hint') ??
                      'Add a description',
                  hintStyle: FormTextStyle.getHintStyle(context),
                  controller: _descriptionController,
                  textInputAction: TextInputAction.done,
                  maxLines: 3, // Multiline
                ),

                const SizedBox(height: 20),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: LulButton(
                    onPressed: _saveForm,
                    text: _languageController.getText('continue'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      _languageController.getText(text),
      style: FormTextStyle.getLabelStyle(context),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      // Transfer data using the new method
      _transferController.setNonLulRecipientDetails(
        _idController.text,
        _fullNameController.text,
        selectedIdType.value,
        _emailController.text,
        _phoneController.text,
        selectedCountry.value,
        selectedState.value,
        selectedCity.value,
        _relationshipController.text,
      );

      // Set description
      _transferController.description.value = _descriptionController.text;

      // Navigate to SetAmountScreen
      Get.to(() => const SetAmountScreen());
    } else {
      LulLoaders.lulerrorSnackBar(
        title: _languageController.getText('error'),
        message: _languageController.getText('fillrequiredfields'),
      );
    }
  }
}
