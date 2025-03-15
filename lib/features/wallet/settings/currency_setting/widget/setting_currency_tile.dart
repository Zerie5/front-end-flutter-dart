import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/image_strings.dart';
import 'package:lul/utils/language/language_controller.dart';

class SettingCurrencyTile extends StatelessWidget {
  const SettingCurrencyTile({
    super.key,
    required this.context,
    required this.countryCode,
    required this.nameKey,
    required this.descriptionKey,
    required this.onTap,
    this.titleStyle,
    this.subtitleStyle,
    this.balance,
  });

  final BuildContext context;
  final String countryCode;
  final String nameKey;
  final String descriptionKey;
  final VoidCallback onTap;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double? balance;

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController =
        Get.find<LanguageController>();

    // Debug print to verify balance is received
    print("Building SettingCurrencyTile with balance: $balance");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: CircleAvatar(
          backgroundColor: TColors.primary.withOpacity(0.2),
          child: ClipOval(
            child: Image.asset(
              '${TImages.countryFlag}$countryCode.png',
              fit: BoxFit.cover,
              height: 32,
              width: 32,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image fails to load
                return const Icon(Icons.monetization_on,
                    color: TColors.primary);
              },
            ),
          ),
        ),
        title: Obx(() => Text(
              languageController.getText(nameKey),
              style: titleStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
            )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row: Currency code
            Obx(() => Text(
                  languageController.getText(descriptionKey),
                  style: subtitleStyle ??
                      TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                )),
            // Second row: Balance (always visible)
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Balance: ${balance?.toStringAsFixed(2) ?? '0.00'}",
                style: const TextStyle(
                  color: TColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white,
        ),
        onTap: onTap,
      ),
    );
  }
}
