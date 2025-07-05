import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';

import '../controllers/deposit_controller.dart';
import 'payment_method_screen.dart';
import '../../../../utils/theme/widget_themes/lul_button_style.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DepositController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        title: Text(
          'Deposit Funds',
          style: Theme.of(context).textTheme.headlineMedium!.apply(
                color: TColors.white,
                fontWeightDelta: 1,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: TColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'How much would you like to deposit?',
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: TColors.white,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Amount Input Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TSizes.lg),
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                border: Border.all(
                  color: TColors.secondary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.secondary.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: TColors.secondary.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Currency Symbol and Amount Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Text(
                            controller.selectedWalletCurrencySymbol,
                            style:
                                Theme.of(context).textTheme.displayLarge!.apply(
                                      color: TColors.secondary,
                                      fontWeightDelta: 2,
                                    ),
                          )),
                      const SizedBox(width: TSizes.sm),
                      Expanded(
                        child: TextFormField(
                          controller: controller.amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style:
                              Theme.of(context).textTheme.displayLarge!.apply(
                                    color: TColors.white,
                                    fontWeightDelta: 1,
                                  ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle:
                                Theme.of(context).textTheme.displayLarge!.apply(
                                      color: TColors.white.withOpacity(0.5),
                                    ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            final amount = double.tryParse(value) ?? 0.0;
                            controller.depositAmount.value = amount;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.sm),

                  // Deposit Limits Info
                  Text(
                    'Min: \$${controller.depositLimits.minAmount.toStringAsFixed(0)} • Max: \$${controller.depositLimits.maxAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: TColors.secondary,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Quick Amount Buttons
            Text(
              'Quick amounts',
              style: Theme.of(context).textTheme.titleMedium!.apply(
                    color: TColors.white,
                    fontWeightDelta: 1,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            Wrap(
              spacing: TSizes.sm,
              runSpacing: TSizes.sm,
              children: controller.quickAmounts.map((amount) {
                return Obx(() => _QuickAmountButton(
                      amount: amount,
                      isSelected: controller.depositAmount.value == amount,
                      onTap: () => controller.setDepositAmount(amount),
                      dark: dark,
                    ));
              }).toList(),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Deposit Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                border: Border.all(
                  color: TColors.secondary,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.infoCircle,
                    color: TColors.secondary,
                    size: TSizes.iconSm,
                  ),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: Obx(() => Text(
                          'Funds will be added to your ${controller.selectedWalletCurrencyCode} wallet. Processing fees may apply based on payment method.',
                          style: Theme.of(context).textTheme.bodySmall!.apply(
                                color: TColors.white,
                              ),
                        )),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections * 2),

            // Continue Button
            Obx(() => LulButton(
                  onPressed: controller.depositAmount.value >=
                          controller.depositLimits.minAmount
                      ? () => Get.to(() => const PaymentMethodScreen())
                      : null,
                  text: 'Continue',
                  backgroundColor: TColors.success,
                  foregroundColor: TColors.white,
                  isDisabled: controller.depositAmount.value <
                      controller.depositLimits.minAmount,
                  showShadow: true,
                )),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;
  final bool dark;

  const _QuickAmountButton({
    required this.amount,
    required this.isSelected,
    required this.onTap,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md,
          vertical: TSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? TColors.secondary : TColors.primary,
          borderRadius: BorderRadius.circular(TSizes.buttonRadius),
          border: Border.all(
            color: isSelected ? TColors.primary : TColors.secondary,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TColors.secondary.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ]
              : [
                  BoxShadow(
                    color: TColors.secondary.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
        ),
        child: Text(
          '\$${amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleSmall!.apply(
                color: isSelected ? TColors.primary : TColors.secondary,
                fontWeightDelta: isSelected ? 1 : 0,
              ),
        ),
      ),
    );
  }
}
