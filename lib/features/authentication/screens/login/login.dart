import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/spacing_styles.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/language/language_controller.dart';
import 'package:lul/features/authentication/screens/login/widgets/login_header.dart';
import 'package:lul/features/authentication/screens/login/widgets/login_form.dart';
import 'package:lul/common/widgets/login_signup/form_divider.dart';
import 'package:lul/common/widgets/login_signup/social_buttons.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final RxBool isPasswordVisible = false.obs;

    ///_languageController.updateLanguage(2);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              ///********Login Title & Sub-Title
              ///
              LLoginHeader(dark: dark, languageController: _languageController),

              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              ///**********Form

              LoginForm(
                  languageController: _languageController,
                  isPasswordVisible: isPasswordVisible),

              ///******Divider

              LDivider(
                dark: dark,
                languageController: _languageController,
                dividertext: _languageController.getText('or_use_other_login'),
              ),

              const SizedBox(
                height: 10,
              ),

              ///*******Footer

              const LFooter()
            ],
          ),
        ),
      ),
    );
  }
}
