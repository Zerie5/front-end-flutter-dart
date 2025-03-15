import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/tile_style.dart';
import 'package:lul/features/wallet/settings/help_setting/help_menu/faq_screen.dart';
import 'package:lul/features/wallet/settings/help_setting/help_menu/knowledge_base_screen.dart';
import 'package:lul/features/wallet/settings/help_setting/help_menu/help_center_screen.dart';
import 'package:lul/features/wallet/settings/widgets/build_setting_tile.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';

class YourHelpScreen extends StatelessWidget {
  YourHelpScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  void _navigateToStatefulScreen(Widget Function() screenBuilder) {
    Get.to(
      screenBuilder,
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
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
              _languageController.getText('help'),
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
                    icon: FontAwesomeIcons.book,
                    iconSize: 24.0,
                    title: _languageController.getText('knowledge_base'),
                    description:
                        _languageController.getText('knowledge_base_subtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () =>
                        _navigateToStatefulScreen(() => KnowledgeBaseScreen()),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: FontAwesomeIcons.circleQuestion,
                    iconSize: 24.0,
                    title: _languageController
                        .getText('frequently_asked_questions'),
                    description: _languageController
                        .getText('frequently_asked_questions_subtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => _navigateToStatefulScreen(() => FAQScreen()),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                  BuildMenuTile(
                    icon: FontAwesomeIcons.headset,
                    iconSize: 24.0,
                    title: _languageController.getText('help_center'),
                    description:
                        _languageController.getText('help_center_subtitle'),
                    titleStyle: TileStyles.getTitleStyle(context),
                    subtitleStyle: TileStyles.getSubtitleStyle(context),
                    onTap: () => _navigateToStatefulScreen(
                        () => const HelpCenterScreen()),
                    showArrow: true,
                  ),
                  const SizedBox(height: TSizes.spaceBtwTiles),
                ],
              )),
        ),
      ),
    );
  }
}
