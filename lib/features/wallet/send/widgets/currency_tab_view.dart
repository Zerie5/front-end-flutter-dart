import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';

class CurrencyTabView extends StatelessWidget {
  final String currencyName;
  final String amount;
  final double availableBalance;
  final String Function(String) getTranslation;
  final String Function(String) formatAmount;

  const CurrencyTabView({
    super.key,
    required this.currencyName,
    required this.amount,
    required this.availableBalance,
    required this.getTranslation,
    required this.formatAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Obx(() => Text(
              formatAmount(amount),
              style: const TextStyle(
                color: TColors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            )),
        const SizedBox(height: TSizes.spaceBtwItems),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: TColors.white.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              '${getTranslation('available')}: ${formatAmount(availableBalance.toString())}',
              style: TextStyle(
                color: TColors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
