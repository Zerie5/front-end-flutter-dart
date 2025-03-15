import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController otpController = TextEditingController();
  final LanguageController _languageController = Get.put(LanguageController());
  final FocusNode otpFocusNode = FocusNode();
  Color otpBorderColor = Colors.grey;

  void verifyEmail() {
    if (otpController.text.isEmpty) {
      setState(() {
        otpBorderColor = Colors.red; // Change border color to red
      });
      otpFocusNode.requestFocus();
      LulLoaders.lulerrorSnackBar(
        /// context: context,
        title: _languageController.getText('errorhead'),
        message: _languageController.getText('enteremailmessage'),
      );
    } else {
      setState(() {
        otpBorderColor = Colors.grey; // Change border color to default grey
      });
      otpFocusNode.unfocus();
      LulLoaders.lulsuccessSnackBar(
        /// context: context,
        title: _languageController.getText('successhead'),
        message: _languageController.getText('changepasswordemailsend'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _languageController.updateLanguage(2);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Headings
            Obx(
              () => Text(
                _languageController.getText('forgetpasswordtitle'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(
              height: TSizes.spaceBtwItems,
            ),

            Obx(
              () => Text(
                _languageController.getText('forgetpasswordsubtitle'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(
              height: TSizes.spaceBtwSections * 2,
            ),

            ///TextField

            Obx(
              () => TextFormField(
                controller: otpController,
                focusNode: otpFocusNode,
                decoration: InputDecoration(
                  labelText: _languageController.getText('enteremail'),
                  prefixIcon: const Icon(Iconsax.direct_right),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: otpBorderColor)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: otpBorderColor, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),

            const SizedBox(
              height: TSizes.spaceBtwSections,
            ),

            ///Submit Button

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: verifyEmail,
                  child: Text(_languageController.getText('sendemail'))),
            ),
          ],
        ),
      ),
    );
  }
}
