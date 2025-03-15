import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/constants/country_list_enabled.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/theme/widget_themes/lul_dropdown_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/validators/validation.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class LSignupForm extends StatelessWidget {
  LSignupForm({
    super.key,
    required LanguageController languageController,
    required this.isPasswordVisible,
    required this.dark,
  }) : _languageController = languageController;

  final LanguageController _languageController;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final RxBool isPasswordVisible;
  final bool dark;

  // Add these controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Add form key
  final _formKey = GlobalKey<FormState>();

  // Add validator instance
  final _validator = LValidator();

  // Add loading state
  final RxBool isLoading = false.obs;

  // Add location selection variables
  final RxString selectedCountry = ''.obs;
  final RxString selectedState = ''.obs;
  final RxString selectedCity = ''.obs;

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      _languageController.getText(text),
      style: FormTextStyle.getLabelStyle(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Container(
        color: THelperFunctions.getScreenBackgroundColor(context),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ///First Name
              Expanded(
                  child: Obx(
                () => LulGeneralTextFormField(
                  controller: _firstNameController,
                  hintText: _languageController.getText('firstname'),
                  prefixIcon: const Icon(Iconsax.user),
                  validator: (value) => _validator.validateEmpty(
                    value,
                    _languageController.getText('firstname'),
                  ),
                ),
              )),

              const SizedBox(
                width: 10,
              ),

              ///Last Name
              Expanded(
                  child: Obx(() => LulGeneralTextFormField(
                        controller: _lastNameController,
                        hintText: _languageController.getText('lastname'),
                        prefixIcon: const Icon(Iconsax.user),
                        validator: (value) => _validator.validateEmpty(
                          value,
                          _languageController.getText('lastname'),
                        ),
                      ))),
            ]),

            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            ///User Name

            Obx(() => LulGeneralTextFormField(
                  controller: _usernameController,
                  hintText: _languageController.getText('username'),
                  prefixIcon: const Icon(Iconsax.user_edit),
                  validator: (value) => _validator.validateEmpty(
                    value,
                    _languageController.getText('username'),
                  ),
                )),

            ///Email
            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            Obx(() => LulGeneralTextFormField(
                  controller: _emailController,
                  hintText: _languageController.getText('emailid'),
                  prefixIcon: const Icon(Iconsax.direct),
                  validator: (value) => _validator.validateEmail(value),
                )),

            ///Phone
            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            Obx(
              () => LulPhoneTextFormField(
                languageController: _languageController,
                hintText: _languageController.getText('phonehint'),
                phoneController: _phoneController,
                onRegionChanged: (String flag, IsoCode region) {},
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            ///WhatsApp Phone
            Obx(
              () => LulPhoneTextFormField(
                languageController: _languageController,
                hintText: _languageController.getText('whatsapp_phone'),
                phoneController: _whatsappController,
                onRegionChanged: (String flag, IsoCode region) {},
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            ///Password
            Obx(() => LulGeneralTextFormField(
                  controller: _passwordController,
                  obscureText: !isPasswordVisible.value,
                  hintText: _languageController.getText('password'),
                  prefixIcon: const Icon(Iconsax.password_check),
                  validator: (value) => _validator.validateEmpty(
                    value,
                    _languageController.getText('password'),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      isPasswordVisible.value = !isPasswordVisible.value;
                    },
                  ),
                )),

            const SizedBox(
              height: TSizes.spaceBtwSections,
            ),

            ///Terms & Conditions Checkbox

            //  TermsConditions(
            // languageController: _languageController, dark: dark),

            const SizedBox(
              height: TSizes.spaceBtwSections,
            ),

            // Country Dropdown
            _buildLabel(context, 'country'),
            const SizedBox(height: 8),
            Obx(() => LulDropdown<String>(
                  value: selectedCountry.value.isNotEmpty
                      ? selectedCountry.value
                      : null,
                  items: countriesenabled
                      .map((country) => DropdownMenuItem(
                            value: country,
                            child: Text(
                              _languageController.getText(country),
                              style: const TextStyle(),
                            ),
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
                    _languageController.getText('country'),
                  ),
                  hintText: _languageController.getText('country_hint'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                )),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            // State/Province Dropdown
            _buildLabel(context, 'state'),
            const SizedBox(height: 8),
            Obx(() => LulDropdown<String>(
                  value: selectedState.value.isNotEmpty
                      ? selectedState.value
                      : null,
                  items: selectedCountry.value.isNotEmpty
                      ? statesenabled[selectedCountry.value]
                              ?.map((state) => DropdownMenuItem(
                                    value: state,
                                    child: Text(
                                      _languageController.getText(state),
                                    ),
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
                    _languageController.getText('state'),
                  ),
                  hintText: _languageController.getText('state_hint'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                )),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            // City Dropdown
            _buildLabel(context, 'city'),
            const SizedBox(height: 8),
            Obx(() => LulDropdown<String>(
                  value:
                      selectedCity.value.isNotEmpty ? selectedCity.value : null,
                  items: selectedState.value.isNotEmpty &&
                          selectedCountry.value.isNotEmpty
                      ? (citiesByState[selectedCountry.value]
                                  ?[selectedState.value]
                              ?.map((city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(
                                      _languageController.getText(city),
                                    ),
                                  ))
                              .toList() ??
                          [])
                      : [],
                  onChanged: (value) {
                    if (value != null) selectedCity.value = value;
                  },
                  validator: (_) => _validator.validateDropdownSelection(
                    selectedCity.value,
                    _languageController.getText('city'),
                  ),
                  hintText: _languageController.getText('city_hint'),
                  hintStyle: FormTextStyle.getHintStyle(context),
                )),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            ///Sign Up Button

            /*  SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              isLoading.value = true;
                              final response = await THttpHelper.registerUser(
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                username: _usernameController.text.trim(),
                                email: _emailController.text.trim(),
                                phoneNumber: _phoneController.text.trim(),
                                whatsappNumber: _whatsappController.text.trim(),
                                password: _passwordController.text,
                              );

                              if (response['status'] == 'success') {
                                LulLoaders.successDialog(
                                  title: _languageController
                                      .getText('registration_success'),
                                  message:
                                      '${_languageController.getText('user_registered')}: ${response['userId']}',
                                );
                                // Handle successful registration (e.g., navigate to next screen)
                              } else {
                                LulLoaders.errorDialog(
                                  title: _languageController
                                      .getText('registration_failed'),
                                  message: _languageController
                                      .getText(response['code']),
                                );
                              }
                            } finally {
                              isLoading.value = false;
                            }
                          }
                        },
                  child: isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_languageController.getText('signup')),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
