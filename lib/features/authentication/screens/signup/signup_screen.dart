import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/features/authentication/screens/otp/otp_verify.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/country_list_enabled.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/device/device_info_helper.dart';
import 'package:lul/utils/formatters/phone_number_formatter.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_date_field.dart';
import 'package:lul/utils/theme/widget_themes/lul_dropdown_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/utils/validators/validation.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:lul/utils/constants/refered_by.dart';
import 'package:lul/features/authentication/screens/signup/widgets/terms_conditions.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:intl/intl.dart';

class SignUpScreen2 extends StatelessWidget {
  SignUpScreen2({super.key});

  final _formKey = GlobalKey<FormState>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final LValidator _validator = LValidator();

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralSourceController =
      TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString selectedCountry = ''.obs;
  final RxString selectedState = ''.obs;
  final RxString selectedCity = ''.obs;
  final RxString selectedReferralSource = ''.obs;
  final RxBool acceptedTerms = false.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedDateOfBirth = ''.obs;

  // Add focus nodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // Add GlobalKeys for fields
  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _usernameKey = GlobalKey();
  final GlobalKey _phoneKey = GlobalKey();

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      _languageController.getText(text),
      style: FormTextStyle.getLabelStyle(context),
    );
  }

  void _scrollToField(BuildContext context, GlobalKey fieldKey) {
    final RenderObject? renderObject =
        fieldKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero);
      _scrollController.animateTo(
        position.dy,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleError(String errorCode, BuildContext context) {
    switch (errorCode) {
      case 'ERR_101':
        _emailFocusNode.requestFocus();
        _scrollToField(context, _emailKey);
        break;
      case 'ERR_102':
        _usernameFocusNode.requestFocus();
        _scrollToField(context, _usernameKey);
        break;
      case 'ERR_103':
        _phoneFocusNode.requestFocus();
        _scrollToField(context, _phoneKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Title
              Text(
                _languageController.getText('signupTitle'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Group
                    _buildLabel(context, 'firstname'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    LulGeneralTextFormField(
                      controller: _firstNameController,
                      hintText: _languageController.getText('firstname_hint'),
                      hintStyle: FormTextStyle.getHintStyle(context),
                      prefixIcon: const Icon(Iconsax.user),
                      validator: (value) => _validator.validateEmpty(
                        value,
                        _languageController.getText('firstname'),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    _buildLabel(context, 'lastname'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    LulGeneralTextFormField(
                      controller: _lastNameController,
                      hintText: _languageController.getText('lastname_hint'),
                      hintStyle: FormTextStyle.getHintStyle(context),
                      prefixIcon: const Icon(Iconsax.user),
                      validator: (value) => _validator.validateEmpty(
                        value,
                        _languageController.getText('lastname'),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    _buildLabel(context, 'username'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    Container(
                      key: _usernameKey,
                      child: LulGeneralTextFormField(
                        controller: _usernameController,
                        focusNode: _usernameFocusNode,
                        hintText: _languageController.getText('username_hint'),
                        hintStyle: FormTextStyle.getHintStyle(context),
                        prefixIcon: const Icon(Iconsax.user_edit),
                        validator: (value) => _validator.validateEmpty(
                          value,
                          _languageController.getText('username'),
                        ),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // Gender Dropdown
                    _buildLabel(context, 'gender'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    Obx(() => LulDropdown<String>(
                          value: selectedGender.value.isNotEmpty
                              ? selectedGender.value
                              : null,
                          items: ['male', 'female']
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(
                                      _languageController.getText(gender),
                                      style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) selectedGender.value = value;
                          },
                          validator: (_) =>
                              _validator.validateDropdownSelection(
                            selectedGender.value,
                            _languageController.getText('gender'),
                          ),
                          hintText: _languageController.getText('gender_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          prefixIcon: const Icon(Iconsax.user_square),
                        )),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // Date of Birth
                    _buildLabel(context, 'dateofbirth'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    LulDateField(
                      controller: _dateOfBirthController,
                      hintText: _languageController.getText('dateofbirth_hint'),
                      hintStyle: FormTextStyle.getHintStyle(context),
                      validator: (value) => _validator.validateEmpty(
                        value,
                        _languageController.getText('date_of_birth'),
                      ),
                      onDateSelected: (date) {
                        selectedDateOfBirth.value =
                            DateFormat('yyyy-MM-dd').format(date);
                      },
                      prefixIcon: const Icon(Iconsax.calendar_1),
                    ),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // Location Information Group
                    _buildLabel(context, 'country'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
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
                                        _languageController.getText(country),
                                        style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black),
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
                            validator: (_) =>
                                _validator.validateDropdownSelection(
                              selectedCountry.value,
                              _languageController.getText('country'),
                            ),
                            hintText:
                                _languageController.getText('country_hint'),
                            hintStyle: FormTextStyle.getHintStyle(context),
                            prefixIcon: const Icon(Iconsax.global),
                          ),
                        )),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    _buildLabel(context, 'state'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
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
                                              child: Text(
                                                _languageController
                                                    .getText(state),
                                                style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black),
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
                            validator: (_) =>
                                _validator.validateDropdownSelection(
                              selectedState.value,
                              _languageController.getText('state'),
                            ),
                            hintText: _languageController.getText('state_hint'),
                            hintStyle: FormTextStyle.getHintStyle(context),
                            prefixIcon: const Icon(Iconsax.map),
                          ),
                        )),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    _buildLabel(context, 'city'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
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
                                        child: Text(
                                          city,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : [],
                          onChanged: (value) {
                            if (value != null) selectedCity.value = value;
                          },
                          validator: (_) =>
                              _validator.validateDropdownSelection(
                            selectedCity.value,
                            _languageController.getText('city'),
                          ),
                          hintText: _languageController.getText('city_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          prefixIcon: const Icon(Iconsax.location),
                        )),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // Contact Information Group
                    _buildLabel(context, 'email'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    Container(
                      key: _emailKey,
                      child: LulGeneralTextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        hintText: _languageController.getText('email_hint'),
                        hintStyle: FormTextStyle.getHintStyle(context),
                        prefixIcon: const Icon(Iconsax.direct),
                        validator: (value) => _validator.validateEmail(value),
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    _buildLabel(context, 'phone'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    Container(
                      key: _phoneKey,
                      child: LulPhoneTextFormField(
                        languageController: _languageController,
                        hintText: _languageController.getText('phone_hint'),
                        hintStyle: FormTextStyle.getHintStyle(context),
                        phoneController: _phoneController,
                        focusNode: _phoneFocusNode,
                        onRegionChanged: (String flag, IsoCode region) {},
                      ),
                    ),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    _buildLabel(context, 'whatsapp_phone'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    LulPhoneTextFormField(
                      languageController: _languageController,
                      hintText:
                          _languageController.getText('whatsapp_phone_hint'),
                      hintStyle: FormTextStyle.getHintStyle(context),
                      phoneController: _whatsappController,
                      onRegionChanged: (String flag, IsoCode region) {},
                    ),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // Security Group
                    _buildLabel(context, 'password'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    Obx(() => LulGeneralTextFormField(
                          controller: _passwordController,
                          obscureText: !isPasswordVisible.value,
                          hintText:
                              _languageController.getText('password_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          prefixIcon: const Icon(Iconsax.password_check),
                          validator: _validator.validatePassword,
                          suffixIcon: IconButton(
                            icon: Icon(isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => isPasswordVisible.value =
                                !isPasswordVisible.value,
                          ),
                        )),

                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // Additional Information Group
                    _buildLabel(context, 'how_did_you_find_us'),
                    const SizedBox(height: TSizes.spaceBtwInputFields),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: LulDropdown<String>(
                            value: selectedReferralSource.value.isNotEmpty
                                ? selectedReferralSource.value
                                : null,
                            items: referralSources
                                .map((source) => DropdownMenuItem(
                                      value: source,
                                      child: Text(
                                        source,
                                        style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedReferralSource.value = value;
                                _referralSourceController.text = value;
                              }
                            },
                            validator: (_) =>
                                _validator.validateDropdownSelection(
                              selectedReferralSource.value,
                              _languageController
                                  .getText('how_did_you_find_us'),
                            ),
                            hintText: _languageController
                                .getText('referral_source_hint'),
                            hintStyle: FormTextStyle.getHintStyle(context),
                            prefixIcon: const Icon(Iconsax.search_normal),
                          ),
                        )),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Form Divider
                    const Divider(
                      color: TColors.grey,
                      height: TSizes.dividerHeight,
                      thickness: TSizes.dividerHeight,
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Terms and Conditions
                    Obx(() => TermsConditions(
                          languageController: _languageController,
                          dark: isDark,
                          value: acceptedTerms.value,
                          onChanged: (bool? value) {
                            acceptedTerms.value = value ?? false;
                          },
                        )),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Submit Button using LulButton
                    Obx(() => LulButton(
                          onPressed: acceptedTerms.value
                              ? () => _handleSignUp(context)
                              : null,
                          text: _languageController.getText('signup'),
                          isLoading: isLoading.value,
                          backgroundColor: acceptedTerms.value
                              ? Colors.green
                              : TColors.grey.withOpacity(0.3),
                          foregroundColor: acceptedTerms.value
                              ? TColors.white
                              : TColors.grey,
                        )),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    // Add this somewhere in your test UI
                    /*  ElevatedButton(
                      onPressed: () async {
                        await AuthStorage.clearAllStorage();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Storage cleared for new test')),
                          );
                        }
                      },
                      child: const Text('Clear Storage for New Test'),
                    ),

                    const SizedBox(height: TSizes.spaceBtwSections),

                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => const CreatePinScreen());
                      },
                      child: const Text('Go to Create PIN'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        THttpHelper.testConnection();
                      },
                      child: const Text('Test Connection'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => const LulOtpVerifyScreen(
                              phoneNumber: "+256703241464",
                            ));
                      },
                      child: const Text('Open Verify OTP'),
                    ),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        isLoading.value = true;

        // Get device information
        final deviceInfo = await DeviceInfoHelper.getLoginDeviceInfo();
        final formatedPhoneNumber =
            TPhoneNumberFormatter.removeCountryCodePrefix(
                _phoneController.text);

        // Construct registration data with proper structure
        final userData = {
          "username": _usernameController.text.trim(),
          "password": _passwordController.text,
          "email": _emailController.text.trim(),
          "firstName": _firstNameController.text.trim(),
          "lastName": _lastNameController.text.trim(),
          "phoneNumber": formatedPhoneNumber,
          "whatsappNumber": _whatsappController.text.trim(),
          "gender": selectedGender.value,
          "dateOfBirth": selectedDateOfBirth.value,
          "country": selectedCountry.value,
          "state": selectedState.value,
          "city": selectedCity.value,
          "referredBy": selectedReferralSource.value,
          "termsAgreed": true,
          "deviceInfo": {
            "deviceId": deviceInfo['deviceId'],
            "deviceName": deviceInfo['deviceName'],
            "os": deviceInfo['os']
          }
        };

        print(
            'Registration data being sent: ${userData.toString()}'); // Log the data

        final response = await THttpHelper.registerUser(userData);

        if (response['status'] == 'error') {
          final errorCode = response['code'];
          print('SignUp: Error code received: $errorCode');
          _handleError(errorCode, context);
          Get.find<LulLoaders>().errorDialog(
            title: _languageController.getText('error'),
            message: _languageController.getText(errorCode),
          );
          return;
        }

        if (response['status'] == 'success') {
          final userId = response['userId'] as String;
          final token = response['token'] as String;

          // Debug the value before casting
          print('RegisterStatus raw value: ${response['registerStatus']}');
          print(
              'RegisterStatus type: ${response['registerStatus'].runtimeType}');

          // Safe conversion to int
          final registerStatus =
              int.parse(response['registerStatus'].toString());

          await AuthStorage.saveToken(token);
          await AuthStorage.saveRegistrationStage(registerStatus);

          Get.find<LulLoaders>().successDialog(
            title: _languageController.getText('success'),
            message:
                '${_languageController.getText('registration_success')}\nUser ID: $userId',
            onPressed: () => Get.to(() => LulOtpVerifyScreen(
                  phoneNumber: _phoneController.text.trim(),
                )),
          );
        } else {
          print('SignUp: Token was null in response');
          throw Exception('Token missing from response');
        }
      } catch (e) {
        print('SignUp: Unexpected error: $e');
        Get.find<LulLoaders>().errorDialog(
          title: _languageController.getText('error'),
          message: _languageController.getText('registration_failed'),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}
