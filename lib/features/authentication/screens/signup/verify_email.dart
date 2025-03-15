import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/widgets/success_screen/success_screen.dart';
import 'package:lul/utils/constants/image_strings.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  VerifyEmailScreenState createState() => VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final LanguageController _languageController = Get.put(LanguageController());
  final TextEditingController otpController =
      TextEditingController(); // Controller for OTP input
  final String correctOTP = "123"; // Simulated OTP for verification

  @override
  Widget build(BuildContext context) {
    _languageController.updateLanguage(2);

    void verifyOTP() {
      if (otpController.text.isEmpty) {
        // Snackbar for empty input
        Get.snackbar(
          _languageController.getText('errorhead'),
          _languageController.getText('enterotp'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else if (otpController.text != correctOTP) {
        // Snackbar for invalid OTP
        Get.snackbar(
          _languageController.getText('errorhead'),
          _languageController.getText('invalidotp'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } else {
        // Success Snackbar
        Get.snackbar(
          _languageController.getText('successhead'),
          _languageController.getText('successotp'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate to success screen
        Get.off(
            () => SuccessScreen()); // Replace with your actual success screen
      }
    }

    void resendOTP() {
      // Snackbar for OTP resend
      Get.snackbar(
        _languageController.getText('resendotphead'),
        _languageController.getText('resendotp'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
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
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Image
              Image(
                image: const AssetImage(TImages.deliveredEmailIllustration),
                width: THelperFunctions.screenWidth() * 0.6,
              ),

              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),

              /// Title and Subtitle
              Obx(
                () => Text(
                  _languageController.getText('confirmemailtitle'),
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
                  _languageController.getText('confirmemailsubtitle'),
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// OTP Input
              Obx(
                () => TextFormField(
                  controller: otpController,
                  decoration: InputDecoration(
                    labelText: _languageController.getText('enterotp'),
                    prefixIcon: const Icon(CupertinoIcons.lock),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: verifyOTP,
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
                    onPressed: resendOTP,
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

/// Dummy Success Screen for Navigation
