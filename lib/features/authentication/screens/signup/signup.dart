import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/widgets/login_signup/form_divider.dart';
import 'package:lul/features/authentication/screens/signup/widgets/sign_up_form.dart';
import '../../../../common/widgets/login_signup/social_buttons.dart';
import '../../../../utils/constants/sizes.dart';
import 'package:lul/utils/language/language_controller.dart';

import '../../../../utils/helpers/helper_functions.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();
  final RxBool isPasswordVisible = false.obs;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              ///*****Title

              Text(
                _languageController.getText('signupTitle'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              ///*******Form
              LSignupForm(
                  languageController: _languageController,
                  isPasswordVisible: isPasswordVisible,
                  dark: dark),

              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              ///Divider

              LDivider(
                dark: dark,
                languageController: _languageController,
                dividertext: _languageController.getText('or_use_other_signup'),
              ),

              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              ///Social Buttons

              const LFooter()
            ],
          ),
        ),
      ),
    );
  }
}
