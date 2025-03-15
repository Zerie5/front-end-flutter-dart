import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/tile_style.dart';
import 'package:lul/features/wallet/settings/security_setting/security_menu/accesshistory_screen.dart';
import 'package:lul/features/wallet/settings/security_setting/security_menu/pin_updatescreen.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_check.dart';
import 'package:lul/features/wallet/settings/widgets/build_setting_tile.dart';

import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';

class LulSecurityScreen extends StatelessWidget {
  LulSecurityScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back(); // Return to the previous screen
          },
        ),
        title: Obx(() {
          return Text(
            _languageController
                .getText('accountsecurity'), // Title as 'Security'
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Align children
              children: [
                const SizedBox(height: 10), // Consistent spacing at the top
                BuildMenuTile(
                  icon: Icons.lock,
                  iconSize: 24.0,
                  title: _languageController.getText('pin'),
                  description: _languageController.getText('pinsubtitle'),
                  titleStyle: TileStyles.getTitleStyle(context),
                  subtitleStyle: TileStyles.getSubtitleStyle(context),
                  onTap: () {
                    Get.to(
                      () => LulCheckPinScreen(
                        maxAttempts: 3,
                        onSuccess: () {
                          // First, explicitly pop the PIN check screen…
                          Get.back();
                          // …then push the LulUpdatePinScreen.
                          Get.to(() => const LulUpdatePinScreen(),
                              transition: Transition.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 600));
                        },
                      ),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 600),
                    );
                  },
                  showArrow: true,
                ),

                const SizedBox(
                    height: TSizes.spaceBtwTiles), // Add spacing between tiles
                BuildMenuTile(
                  icon: Icons.history,
                  iconSize: 24.0,
                  title: _languageController.getText('accesshistory'),
                  description:
                      _languageController.getText('accesshistorysubtitle'),
                  titleStyle: TileStyles.getTitleStyle(context),
                  subtitleStyle: TileStyles.getSubtitleStyle(context),
                  onTap: () => Get.to(
                    () => LulAccessHistoryScreen(),
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 300),
                  ),
                  showArrow: true,
                ),
                const SizedBox(height: 16), // Spacing at the bottom
              ],
            );
          }),
        ),
      ),
    );
  }
}
