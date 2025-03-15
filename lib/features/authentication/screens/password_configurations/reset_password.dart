import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/utils/constants/image_strings.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final LanguageController _languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    _languageController.updateLanguage(1);

    void movetoLogin() {
      // Snackbar for OTP resend
      Get.off(
        () => LoginScreen(),
      );
      // Add logic to resend OTP here
    }

    void resendEmail() {
      // Snackbar for OTP resend
      LulLoaders.lulsuccessSnackBar(
        title: _languageController.getText('changepasswordemailsend'),
        message: _languageController.getText('changepasswordemailresend'),
      );

      // Add logic to resend OTP here
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(CupertinoIcons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              ///Image
              Image(
                image: const AssetImage(TImages.deliveredEmailIllustration),
                width: THelperFunctions.screenWidth() * 0.6,
              ),

              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              ///Title and Subtitle

              Obx(
                () => Text(
                  _languageController.getText('resetpasswordtitle'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              Text(
                "Support@lulpay.com",
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              Obx(
                () => Text(_languageController.getText('resetpasswordsubtitle'),
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              ///Buttons
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: movetoLogin,
                    child: Text(_languageController.getText('continue')),
                  ),
                ),
              ),

              const SizedBox(
                height: TSizes.spaceBtwItems,
              ),

              /// Resend OTP Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => OutlinedButton(
                    onPressed: resendEmail,
                    child: Text(_languageController.getText('resendemail')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
