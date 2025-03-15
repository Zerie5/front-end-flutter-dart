import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/wallet/send/send_for_non_lul.dart';
import 'package:lul/features/wallet/send/send_has_account.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';

class LulSendChoiceScreen extends StatelessWidget {
  LulSendChoiceScreen({super.key});
  final LanguageController _languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Obx(() => Text(
              _languageController.getText('send_hm'),
              style: FormTextStyle.getHeaderStyle(context),
            )),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                    _languageController.getText('has_lul_account'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: TColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.06, // Responsive font size
                        ),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: screenWidth * 0.12), // Responsive spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: LulButton(
                      onPressed: () {
                        Get.to(() => const LulSendHasAccountScreen());
                      },
                      text: _languageController.getText('yes'),
                      height: 60, // Bigger button height
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.06), // Responsive spacing
                  Expanded(
                    child: LulButton(
                      onPressed: () {
                        Get.to(() => const SendForNonLulScreen());
                      },
                      text: _languageController.getText('no'),
                      height: 60, // Bigger button height
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
