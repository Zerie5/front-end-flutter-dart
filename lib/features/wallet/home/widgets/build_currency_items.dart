import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/image_strings.dart';
import 'package:lul/utils/language/language_controller.dart';

class BuildCurrencyItem extends StatelessWidget {
  const BuildCurrencyItem({
    super.key,
    required this.context,
    required this.countryCode,
    required this.nameKey, // Language key for name
    required this.descriptionKey, // Language key for description
    this.balance, // Add balance parameter
  });

  final BuildContext context;
  final String countryCode;
  final String nameKey;
  final String descriptionKey;
  final double? balance; // New field for balance

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController =
        Get.find<LanguageController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: TColors.secondary, // Using secondary color for the border
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${languageController.getText(nameKey)} clicked!"),
            ),
          );
        },
        splashColor: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: TColors.primary.withOpacity(0.2),
                child: ClipOval(
                  child: Image.asset(
                    '${TImages.countryFlag}$countryCode.png', // Dynamically load flag
                    fit: BoxFit.cover,
                    height: 32,
                    width: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.monetization_on,
                          color: Colors.white);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Wrap dynamic text in Obx for reactivity
              Expanded(
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageController
                              .getText(nameKey), // Translated name
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              languageController
                                  .getText(descriptionKey), // Description
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (balance != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 8),
                              decoration: BoxDecoration(
                                color: TColors.secondary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: TColors.secondary,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "Balance: ${balance!.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: TColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Options clicked")),
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
