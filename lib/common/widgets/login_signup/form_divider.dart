import 'package:flutter/material.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/language/language_controller.dart';

class LDivider extends StatelessWidget {
  const LDivider(
      {super.key,
      required this.dark,
      required LanguageController languageController,
      required this.dividertext})
      : _languageController = languageController;

  final bool dark;
  final LanguageController _languageController;
  final String dividertext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
            child: Divider(
          color: dark ? TColors.darkGrey : TColors.grey,
          thickness: 0.5,
          indent: 60,
          endIndent: 5,
        )),
        Text(_languageController.getText(dividertext),
            style: Theme.of(context).textTheme.labelMedium),
        Flexible(
            child: Divider(
          color: dark ? TColors.darkGrey : TColors.grey,
          thickness: 0.5,
          indent: 5,
          endIndent: 60,
        )),
      ],
    );
  }
}
