import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/constants/country_list_enabled.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_date_field.dart';
import 'package:lul/utils/theme/widget_themes/lul_dropdown_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/validators/validation.dart';
import 'package:lul/services/profile_service.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
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
  final TextEditingController _dateOfBirthController = TextEditingController();

  // Observable variables
  final RxString selectedCountry = ''.obs;
  final RxString selectedState = ''.obs;
  final RxString selectedCity = ''.obs;
  final RxString selectedGender = ''.obs;
  final RxBool isLoading = false.obs;

  // At the top of the class, add unique keys
  final _dateFieldKey = GlobalKey();
  final _phoneFieldKey = GlobalKey();
  final _whatsappFieldKey = GlobalKey();
  final _genderFieldKey = GlobalKey();
  final _countryFieldKey = GlobalKey();
  final _stateFieldKey = GlobalKey();
  final _cityFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    isLoading.value = true;
    try {
      final response = await ProfileService.getUserProfile();
      print('Profile Response: $response');

      if (response['status'] == 'success') {
        final userData = response['data'];
        print('User Data: $userData'); // Debug print

        // Text fields
        _firstNameController.text = userData['firstName'] ?? '';
        _lastNameController.text = userData['lastName'] ?? '';
        _usernameController.text = userData['username'] ?? '';
        _emailController.text = userData['email'] ?? '';

        // Phone fields
        if (userData['phoneNumber'] != null) {
          print('Setting phone: ${userData['phoneNumber']}'); // Debug print
          _phoneController.text = userData['phoneNumber'];
          // Force rebuild of phone field
          if (mounted) {
            setState(() {});
          }
        }

        if (userData['whatsappNumber'] != null) {
          print(
              'Setting whatsapp: ${userData['whatsappNumber']}'); // Debug print
          _whatsappController.text = userData['whatsappNumber'];
          // Force rebuild of phone field
          if (mounted) {
            setState(() {});
          }
        }

        // Date field
        if (userData['dateOfBirth'] != null) {
          print('Setting DOB: ${userData['dateOfBirth']}'); // Debug print
          _dateOfBirthController.text = userData['dateOfBirth'];
          // Force rebuild of date field
          if (mounted) {
            setState(() {});
          }
        }

        // Dropdowns
        if (userData['country'] != null) {
          print('Setting country: ${userData['country']}'); // Debug print
          selectedCountry.value = userData['country'];
        }

        if (userData['state'] != null) {
          print('Setting state: ${userData['state']}'); // Debug print
          selectedState.value = userData['state'];
        }

        if (userData['city'] != null) {
          print('Setting city: ${userData['city']}'); // Debug print
          selectedCity.value = userData['city'];
        }

        if (userData['gender'] != null) {
          print('Setting gender: ${userData['gender']}'); // Debug print
          selectedGender.value = userData['gender'].toLowerCase();
        }

        // Force UI update
        if (mounted) {
          setState(() {});
        }
      } else {
        _handleError(response['code']);
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(String code) {
    String message;
    switch (code) {
      case 'ERR_501':
        message = _languageController.getText('err_501');
        break;
      case 'ERR_502':
        message = _languageController.getText('err_502');
        break;
      default:
        message = _languageController.getText('err_503');
    }

    Get.find<LulLoaders>().errorDialog(
      title: _languageController.getText('error'),
      message: message,
    );
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final response = await ProfileService.updateProfile({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'whatsappNumber': _whatsappController.text,
          'gender': selectedGender.value,
          'dateOfBirth': _dateOfBirthController.text,
          'country': selectedCountry.value,
          'state': selectedState.value,
          'city': selectedCity.value,
        });

        if (response['status'] == 'success') {
          Get.find<LulLoaders>().successDialog(
            title: _languageController.getText('success'),
            message: _languageController.getText('profile_update_success'),
            onPressed: () => Get.back(),
          );
        } else {
          // Handle specific error codes
          switch (response['code']) {
            case 'ERR_703':
              Get.find<LulLoaders>().warningDialog(
                title: _languageController.getText('warning'),
                message: _languageController
                    .getText('err_703'), // "Email already in use"
              );
              break;
            case 'ERR_704':
              Get.find<LulLoaders>().warningDialog(
                title: _languageController.getText('warning'),
                message: _languageController
                    .getText('err_704'), // "Phone number already in use"
              );
              break;
            default:
              _handleUpdateError(response['code']);
          }
        }
      } finally {
        isLoading.value = false;
      }
    }
  }

  void _handleUpdateError(String code) {
    String title = _languageController.getText('error');
    String message;

    switch (code) {
      // Duplicate Errors
      case 'ERR_101':
        message =
            _languageController.getText('ERR_101'); // "Email already exists"
        title = _languageController.getText('warning');
        break;
      case 'ERR_102':
        message =
            _languageController.getText('ERR_102'); // "Username already exists"
        title = _languageController.getText('warning');
        break;
      case 'ERR_103':
        message = _languageController
            .getText('ERR_103'); // "Phone number already exists"
        title = _languageController.getText('warning');
        break;

      // Validation Errors
      case 'ERR_706':
        message =
            _languageController.getText('ERR_706'); // "Invalid date format"
        break;
      case 'ERR_707':
        message =
            _languageController.getText('ERR_707'); // "Invalid gender value"
        break;
      case 'ERR_708':
        message =
            _languageController.getText('err_708'); // "Missing required fields"
        break;

      // Authentication Errors
      case 'ERR_502':
        message =
            _languageController.getText('err_502'); // "Invalid/expired token"
        break;

      // Not Found
      case 'ERR_501':
        message = _languageController.getText('err_501'); // "User not found"
        break;

      // Server Error
      case 'ERR_700':
        message =
            _languageController.getText('err_700'); // "Profile update failed"
        break;

      default:
        message = _languageController.getText('err_700');
    }

    // Show warning dialog for duplicate errors, error dialog for others
    if (code.startsWith('ERR_10')) {
      // Duplicate errors start with ERR_10
      Get.find<LulLoaders>().warningDialog(
        title: title,
        message: message,
      );
    } else {
      Get.find<LulLoaders>().errorDialog(
        title: title,
        message: message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            _languageController.getText('update_profile'),
            style: FormTextStyle.getHeaderStyle(context),
          ),
          centerTitle: true,
        ),
        body: Obx(() => isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal Information Group
                        _buildLabel(context, 'firstname'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        LulGeneralTextFormField(
                          controller: _firstNameController,
                          hintText:
                              _languageController.getText('firstname_hint'),
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
                          hintText:
                              _languageController.getText('lastname_hint'),
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
                        LulGeneralTextFormField(
                          controller: _usernameController,
                          hintText:
                              _languageController.getText('username_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          prefixIcon: const Icon(Iconsax.user_edit),
                          validator: (value) => _validator.validateEmpty(
                            value,
                            _languageController.getText('username'),
                          ),
                        ),

                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Gender Dropdown
                        _buildLabel(context, 'gender'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        Obx(() => LulDropdown<String>(
                              key: _genderFieldKey,
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
                              hintText:
                                  _languageController.getText('gender_hint'),
                              hintStyle: FormTextStyle.getHintStyle(context),
                              prefixIcon: const Icon(Iconsax.user_square),
                            )),

                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Date of Birth
                        _buildLabel(context, 'date_of_birth'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        LulDateField(
                          key: _dateFieldKey,
                          controller: _dateOfBirthController,
                          initialValue: _dateOfBirthController.text,
                          hintText: _languageController.getText('dob_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          validator: (value) => _validator.validateEmpty(
                            value,
                            _languageController.getText('date_of_birth'),
                          ),
                          onDateSelected: (date) {
                            _dateOfBirthController.text =
                                DateFormat('yyyy-MM-dd').format(date);
                            setState(() {});
                          },
                          prefixIcon: const Icon(Iconsax.calendar_1),
                        ),

                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Location Information
                        _buildLabel(context, 'country'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        _buildCountryDropdown(isDark),

                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        _buildLabel(context, 'state'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        _buildStateDropdown(isDark),

                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        _buildLabel(context, 'city'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        _buildCityDropdown(isDark),

                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        // Contact Information
                        _buildLabel(context, 'email'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        LulGeneralTextFormField(
                          controller: _emailController,
                          hintText: _languageController.getText('email_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          prefixIcon: const Icon(Iconsax.direct),
                          validator: (value) => _validator.validateEmail(value),
                        ),

                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        _buildLabel(context, 'phone'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        LulPhoneTextFormField(
                          key: _phoneFieldKey,
                          languageController: _languageController,
                          hintText: _languageController.getText('phone_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          phoneController: _phoneController,
                          initialValue: _phoneController.text,
                          onRegionChanged: (String flag, IsoCode region) {},
                        ),

                        const SizedBox(height: TSizes.spaceBtwInputFields),

                        _buildLabel(context, 'whatsapp'),
                        const SizedBox(height: TSizes.spaceBtwInputFields),
                        LulPhoneTextFormField(
                          key: _whatsappFieldKey,
                          languageController: _languageController,
                          hintText:
                              _languageController.getText('whatsapp_hint'),
                          hintStyle: FormTextStyle.getHintStyle(context),
                          phoneController: _whatsappController,
                          initialValue: _whatsappController.text,
                          onRegionChanged: (String flag, IsoCode region) {},
                        ),

                        const SizedBox(height: TSizes.spaceBtwSections),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: LulButton(
                            onPressed: _saveForm,
                            text: _languageController.getText('save'),
                            isLoading: isLoading.value,
                          ),
                        ),

                        const SizedBox(height: TSizes.spaceBtwSections),
                      ],
                    ),
                  ),
                ),
              )),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      _languageController.getText(text),
      style: FormTextStyle.getLabelStyle(context),
    );
  }

  Widget _buildCountryDropdown(bool isDark) {
    return Obx(() => LulDropdown<String>(
          key: _countryFieldKey,
          value:
              selectedCountry.value.isNotEmpty ? selectedCountry.value : null,
          items: countriesenabled
              .map((country) => DropdownMenuItem(
                    value: country,
                    child: Text(
                      _languageController.getText(country),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
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
          prefixIcon: const Icon(Iconsax.global),
        ));
  }

  Widget _buildStateDropdown(bool isDark) {
    return Obx(() => LulDropdown<String>(
          key: _stateFieldKey,
          value: selectedState.value.isNotEmpty ? selectedState.value : null,
          items: selectedCountry.value.isNotEmpty
              ? statesenabled[selectedCountry.value]
                      ?.map((state) => DropdownMenuItem(
                            value: state,
                            child: Text(
                              _languageController.getText(state),
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black),
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
          prefixIcon: const Icon(Iconsax.map),
        ));
  }

  Widget _buildCityDropdown(bool isDark) {
    return Obx(() => LulDropdown<String>(
          key: _cityFieldKey,
          value: selectedCity.value.isNotEmpty ? selectedCity.value : null,
          items: selectedState.value.isNotEmpty &&
                  selectedCountry.value.isNotEmpty
              ? (citiesByState[selectedCountry.value]?[selectedState.value] ??
                      [])
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(
                          city,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ))
                  .toList()
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
          prefixIcon: const Icon(Iconsax.location),
        ));
  }
}
