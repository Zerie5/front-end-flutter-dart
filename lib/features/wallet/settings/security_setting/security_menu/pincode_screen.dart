import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/tile_style.dart';
import 'package:lul/features/wallet/settings/security_setting/security_menu/pin_updatescreen.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_controller.dart';
import 'package:lul/features/wallet/settings/widgets/build_setting_tile.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/language/language_controller.dart';

class LulPinCodeScreen extends StatelessWidget {
  LulPinCodeScreen({super.key});

  final PINController _pinController = Get.put(PINController());
  final LanguageController _languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Obx(() {
          return Text(
            _languageController.getText('pinsettings'),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _languageController.getText('enablepin'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _pinController.isPinEnabled.value,
                      onChanged: (value) {
                        // Update the value in the controller
                        _pinController.togglePin(value);
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                ),
                if (_pinController.isPinEnabled.value)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: TSizes.spaceBtwTiles),
                      Text(
                        _languageController.getText('pininfo'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwTiles),
                    ],
                  ),
                BuildMenuTile(
                  icon: Icons.lock,
                  iconSize: 24.0,
                  title: _languageController.getText('changepin'),
                  description: _languageController.getText('changepinsubtitle'),
                  titleStyle: TileStyles.getTitleStyle(context),
                  subtitleStyle: TileStyles.getSubtitleStyle(context),
                  onTap: () {
                    Get.to(
                      () => const LulUpdatePinScreen(),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  showArrow: true,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
