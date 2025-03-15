import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/utils/constants/image_strings.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/common/styles/spacing_styles.dart';

class SuccessScreen extends StatelessWidget {
  SuccessScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => Get.offAll(() => LoginScreen()),
              icon: const Icon(CupertinoIcons.clear))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight * 2,
          child: Column(
            children: [
              ///Image
              Image(
                image: const AssetImage(TImages.staticSuccessIllustration),
                width: THelperFunctions.screenWidth() * 0.6,
              ),

              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              ///Title and Subtitle

              Obx(
                () => Text(
                  _languageController.getText('youraccountcreatedtitle'),
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
                () => Text(
                    _languageController.getText('youraccountcreatedsubtitle'),
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
            ],
          ),
        ),
      ),
    );
  }
}
