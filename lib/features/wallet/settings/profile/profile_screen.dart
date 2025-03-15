import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/tile_style.dart';
import 'package:lul/features/wallet/settings/profile/profile_menu/your_language.dart';
import 'package:lul/features/wallet/settings/profile/profile_menu/your_name.dart';
import 'package:lul/features/wallet/settings/profile/profile_menu/your_phone.dart';

import 'package:lul/features/wallet/settings/widgets/build_setting_tile.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  void _navigateToScreen(Widget Function() screenBuilder) {
    Get.to(
      screenBuilder,
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              _languageController.getText('profile'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  BuildMenuTile(
                    icon: Icons.email,
                    iconSize: 24.0,
                    title: _languageController.getText('email'),
                    description: "your_email@example.com",
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () =>
                        _showMessage(context, "Account Email is not editable."),
                    showArrow: false,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: Icons.person,
                    iconSize: 24.0,
                    title: _languageController.getText('name'),
                    description: _languageController.getText('namesubtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () =>
                        _navigateToScreen(() => const UpdateProfileScreen()),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: Icons.phone,
                    iconSize: 24.0,
                    title: _languageController.getText('phone'),
                    description: _languageController.getText('phonesubtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => _navigateToScreen(() => YourPhoneScreen()),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: Icons.language,
                    iconSize: 24.0,
                    title: _languageController.getText('language'),
                    description:
                        _languageController.getText('languagesubtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () =>
                        _navigateToScreen(() => const YourLanguageScreen()),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: Icons.delete,
                    iconSize: 24.0,
                    title: _languageController.getText('deleteaccount'),
                    description:
                        _languageController.getText('deleteaccountsubtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () =>
                        _showMessage(context, "Delete Account clicked."),
                    showArrow: false,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: Icons.logout,
                    iconSize: 24.0,
                    title: _languageController.getText('logout'),
                    description: _languageController.getText('logoutsubtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => _showMessage(context, "Log Out clicked."),
                    showArrow: false,
                  ),
                  const SizedBox(height: 16),
                ],
              )),
        ),
      ),
    );
  }
}
