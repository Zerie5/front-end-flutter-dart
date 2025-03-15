import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/tile_style.dart';
import 'package:lul/features/wallet/settings/widgets/build_setting_tile.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LulSocialMediaScreen extends StatelessWidget {
  LulSocialMediaScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  Future<void> _launchFacebook() async {
    // Facebook app URI and web fallback URL
    const String fbProtocolUrl =
        "fb://page/YOUR_PAGE_ID"; // Replace with your Facebook page ID
    const String fallbackUrl =
        "https://www.facebook.com/YourPageName"; // Replace with your Facebook page URL

    try {
      bool launched = await launchUrl(Uri.parse(fbProtocolUrl));
      if (!launched) {
        // If app launch fails, try web URL
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      // If app launch throws error, try web URL
      try {
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not open Facebook page',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: TColors.secondary.withOpacity(0.9),
          colorText: TColors.textWhite,
        );
      }
    }
  }

  Future<void> _launchYouTube() async {
    const String youtubeUrl = "https://www.youtube.com/@YourChannelName";

    try {
      await launchUrl(
        Uri.parse(youtubeUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open YouTube channel',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.secondary.withOpacity(0.9),
        colorText: TColors.textWhite,
      );
    }
  }

  void _showComingSoon(BuildContext context) {
    LulLoaders.lulinfoSnackBar(
      title: 'Coming Soon',
      message: 'This social media link will be available soon!',
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
          icon: const Icon(Icons.arrow_back, color: TColors.textWhite),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              _languageController.getText('socialmedia'),
              style: const TextStyle(
                color: TColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
      ),
      body: Obx(() => SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  BuildMenuTile(
                    icon: FontAwesomeIcons.facebook,
                    iconSize: 24.0,
                    title: "Facebook",
                    description:
                        _languageController.getText('follow_us_facebook'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: _launchFacebook,
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: FontAwesomeIcons.xTwitter,
                    iconSize: 24.0,
                    title: "X (Twitter)",
                    description: _languageController.getText('follow_us_X'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => _showComingSoon(context),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: FontAwesomeIcons.instagram,
                    iconSize: 24.0,
                    title: "Instagram",
                    description:
                        _languageController.getText('follow_us_instagram'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => _showComingSoon(context),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: FontAwesomeIcons.tiktok,
                    iconSize: 24.0,
                    title: "TikTok",
                    description:
                        _languageController.getText('follow_us_tiktok'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => _showComingSoon(context),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: FontAwesomeIcons.youtube,
                    iconSize: 24.0,
                    title: "YouTube",
                    description:
                        _languageController.getText('follow_us_youtube'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => _showComingSoon(context),
                    showArrow: true,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
