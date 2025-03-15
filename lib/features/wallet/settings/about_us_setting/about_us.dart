import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/tile_style.dart';
import 'package:lul/features/wallet/settings/about_us_setting/aboutus_menu/our_company.dart';
import 'package:lul/features/wallet/settings/widgets/build_setting_tile.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/version_getter/version_getter.dart';
import 'package:url_launcher/url_launcher.dart';

class LulAboutUsScreen extends StatelessWidget {
  LulAboutUsScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  Future<void> _launchStoreURL() async {
    final Uri url = Uri.parse('');
    if (!await launchUrl(url)) {
      Get.snackbar(
        'Error',
        'Could not launch store page',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
              _languageController.getText('aboutus'),
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
                    icon: Icons.info,
                    iconSize: 24.0,
                    title: _languageController.getText('our_company'),
                    description:
                        _languageController.getText('our_company_subtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => Get.to(
                      () => LulOurCompanyScreen(),
                      transition: Transition.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
                    ),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: Icons.star,
                    iconSize: 24.0,
                    title: _languageController.getText('rate_us'),
                    description:
                        _languageController.getText('rate_us_subtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: _launchStoreURL,
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: Icons.info_outline,
                    iconSize: 24.0,
                    title: _languageController.getText('version'),
                    description: VersionGetter.getAppVersion(),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => {},
                    showArrow: false,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                ],
              )),
        ),
      ),
    );
  }
}
