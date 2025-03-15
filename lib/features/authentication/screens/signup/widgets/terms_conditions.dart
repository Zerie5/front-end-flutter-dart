import 'package:flutter/material.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/helpers/helper_functions.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({
    super.key,
    required LanguageController languageController,
    required this.dark,
    required this.value,
    required this.onChanged,
  }) : _languageController = languageController;

  final LanguageController _languageController;
  final bool dark;
  final bool value;
  final Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    // Ensure high contrast for both dark and light modes
    final textColor = dark ? Colors.white70 : Colors.black87;
    final linkColor = TColors.primary.withOpacity(0.9);

    return Container(
      color: THelperFunctions.getScreenBackgroundColor(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: TColors.primary,
              checkColor: dark ? TColors.dark : TColors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'I Agree to the',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          height: 1.5,
                          fontSize: 14,
                        ),
                  ),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          height: 1.5,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  TextSpan(
                    text: 'and',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textColor,
                          height: 1.5,
                          fontSize: 14,
                        ),
                  ),
                  const WidgetSpan(child: SizedBox(width: 4)),
                  TextSpan(
                    text: 'Terms of Use',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          height: 1.5,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
