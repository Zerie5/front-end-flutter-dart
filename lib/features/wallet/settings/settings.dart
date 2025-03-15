import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/tile_style.dart';
import 'package:lul/features/wallet/settings/about_us_setting/about_us.dart';
import 'package:lul/features/wallet/settings/currency_setting/currency_setting.dart';
import 'package:lul/features/wallet/settings/help_setting/help_screen.dart';
import 'package:lul/features/wallet/settings/invitefriends_setting/invite_friends_screen.dart';
import 'package:lul/features/wallet/settings/profile/profile_screen.dart';
import 'package:lul/features/wallet/settings/security_setting/security_screen.dart';
import 'package:lul/features/wallet/settings/socialmedia_setting/socialmedia_screen.dart';
import 'package:lul/features/wallet/settings/widgets/build_setting_tile.dart';

import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  // Add this navigation helper method
  void _navigateToScreen(Widget screen) {
    Get.to(
      () => screen,
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Settings Title
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                child: Row(
                  children: [
                    const Spacer(),
                    Obx(() => Text(
                          _languageController.getText('setting'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    const Spacer(flex: 4),
                  ],
                ),
              ),
              // Settings List
              Obx(() {
                return Column(
                  children: [
                    BuildMenuTile(
                      icon: FontAwesomeIcons.user,
                      iconSize: 24.0,
                      title: _languageController.getText('profile'),
                      description:
                          _languageController.getText('profilesubtitle'),
                      titleStyle: TileStyles.getTitleStyle(context),
                      subtitleStyle: TileStyles.getSubtitleStyle(context),
                      onTap: () => _navigateToScreen(ProfileScreen()),
                    ),
                    const SizedBox(height: TSizes.spaceBtwTiles),
                    BuildMenuTile(
                      icon: FontAwesomeIcons.coins,
                      iconSize: 24.0,
                      title: _languageController.getText('currency'),
                      description:
                          _languageController.getText('currencysubtitle'),
                      titleStyle: TileStyles.getTitleStyle(context),
                      subtitleStyle: TileStyles.getSubtitleStyle(context),
                      onTap: () =>
                          _navigateToScreen(const YourCurrencyScreen()),
                    ),
                    const SizedBox(height: TSizes.spaceBtwTiles),
                    BuildMenuTile(
                      icon: FontAwesomeIcons.lock,
                      iconSize: 24.0,
                      title: _languageController.getText('accountsecurity'),
                      description:
                          _languageController.getText('securitysubtitle'),
                      titleStyle: TileStyles.getTitleStyle(context),
                      subtitleStyle: TileStyles.getSubtitleStyle(context),
                      onTap: () => _navigateToScreen(LulSecurityScreen()),
                    ),
                    const SizedBox(height: TSizes.spaceBtwTiles),
                    BuildMenuTile(
                      icon: FontAwesomeIcons.circleInfo,
                      iconSize: 24.0,
                      title: _languageController.getText('help'),
                      description: _languageController.getText('helpsubtitle'),
                      titleStyle: TileStyles.getTitleStyle(context),
                      subtitleStyle: TileStyles.getSubtitleStyle(context),
                      onTap: () => _navigateToScreen(YourHelpScreen()),
                    ),
                    const SizedBox(height: TSizes.spaceBtwTiles),
                    BuildMenuTile(
                      icon: FontAwesomeIcons.globe,
                      iconSize: 24.0,
                      title: _languageController.getText('socialmedia'),
                      description:
                          _languageController.getText('socialmediasubtitle'),
                      titleStyle: TileStyles.getTitleStyle(context),
                      subtitleStyle: TileStyles.getSubtitleStyle(context),
                      onTap: () => _navigateToScreen(LulSocialMediaScreen()),
                    ),
                    const SizedBox(height: TSizes.spaceBtwTiles),
                    BuildMenuTile(
                      icon: FontAwesomeIcons.networkWired,
                      iconSize: 24.0,
                      title: _languageController.getText('invite_friends'),
                      description: _languageController
                          .getText('invite_friends_subtitle'),
                      titleStyle: TileStyles.getTitleStyle(context),
                      subtitleStyle: TileStyles.getSubtitleStyle(context),
                      onTap: () => _navigateToScreen(LulInviteFriendsScreen()),
                    ),
                    const SizedBox(height: TSizes.spaceBtwTiles),
                    BuildMenuTile(
                      icon: FontAwesomeIcons.fileLines,
                      iconSize: 24.0,
                      title: _languageController.getText('aboutus'),
                      description:
                          _languageController.getText('aboutussubtitle'),
                      titleStyle: TileStyles.getTitleStyle(context),
                      subtitleStyle: TileStyles.getSubtitleStyle(context),
                      onTap: () => _navigateToScreen(LulAboutUsScreen()),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
