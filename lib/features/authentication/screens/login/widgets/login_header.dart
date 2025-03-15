import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/widgets/logo/app_logo.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/language/language_controller.dart';

class LLoginHeader extends StatelessWidget {
  const LLoginHeader({
    super.key,
    required this.dark,
    required LanguageController languageController,
  }) : _languageController = languageController;

  final bool dark;
  final LanguageController _languageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LulLogo(size: 150),
        Obx(() => Text(
              _languageController.getText('loginTitle'),
              style: Theme.of(context).textTheme.headlineMedium,
            )),
        const SizedBox(
          height: TSizes.sm,
        ),
        Obx(() => Text(
              _languageController.getText('loginsubTitle'),
              style: Theme.of(context).textTheme.bodyMedium,
            )),
      ],
    );
  }
}
