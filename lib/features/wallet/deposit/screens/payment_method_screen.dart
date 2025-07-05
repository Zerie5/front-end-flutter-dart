import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../controllers/deposit_controller.dart';
import '../models/deposit_models.dart';
import 'card_details_screen.dart';
import 'bank_details_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositController>();
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        title: Text(
          'Payment Method',
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
              'Choose your payment method',
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: TColors.white,
                  ),
            ),
            const SizedBox(height: TSizes.sm),

            // Amount display
            Obx(() => Container(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Text(
                            controller.selectedWalletCurrencySymbol,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .apply(
                                  color: TColors.secondary,
                                  fontWeightDelta: 2,
                                ),
                          )),
                      const SizedBox(width: TSizes.xs),
                      Text(
                        controller
                            .getFormattedAmount(controller.depositAmount.value),
                        style:
                            Theme.of(context).textTheme.headlineMedium!.apply(
                                  color: TColors.white,
                                  fontWeightDelta: 2,
                                ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Payment Methods
            Text(
              'Select payment method',
              style: Theme.of(context).textTheme.titleMedium!.apply(
                    color: TColors.white,
                    fontWeightDelta: 1,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Credit/Debit Card Option
            _PaymentMethodCard(
              icon: FontAwesomeIcons.creditCard,
              title: 'Credit/Debit Card',
              subtitle: 'Instant processing • 2.9% + \$0.30 fee',
              processingTime: 'Instant',
              isRecommended: true,
              onTap: () {
                controller.setPaymentMethod(PaymentMethodType.card);
                Get.to(() => const CardDetailsScreen());
              },
              dark: dark,
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            // Bank Transfer Option
            _PaymentMethodCard(
              icon: FontAwesomeIcons.university,
              title: 'Bank Transfer',
              subtitle: 'ACH Transfer • \$1.50 flat fee',
              processingTime: '1-3 business days',
              isRecommended: false,
              onTap: () {
                controller.setPaymentMethod(PaymentMethodType.bank);
                Get.to(() => const BankDetailsScreen());
              },
              dark: dark,
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Security Information
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.shield,
                        color: TColors.secondary,
                        size: TSizes.iconSm,
                      ),
                      const SizedBox(width: TSizes.sm),
                      Text(
                        'Secure & Protected',
                        style: Theme.of(context).textTheme.titleSmall!.apply(
                              color: TColors.white,
                              fontWeightDelta: 1,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.xs),
                  Text(
                    'Your payment information is encrypted and secured with industry-standard protocols. We never store your full card details.',
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: TColors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String processingTime;
  final bool isRecommended;
  final VoidCallback onTap;
  final bool dark;

  const _PaymentMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.processingTime,
    required this.isRecommended,
    required this.onTap,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(TSizes.lg),
        decoration: BoxDecoration(
          color: TColors.primary,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(
            color: isRecommended
                ? TColors.secondary
                : TColors.secondary.withOpacity(0.6),
            width: isRecommended ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.secondary.withOpacity(isRecommended ? 0.4 : 0.2),
              blurRadius: isRecommended ? 12 : 8,
              spreadRadius: isRecommended ? 2 : 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(TSizes.sm),
                  decoration: BoxDecoration(
                    color: TColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: TColors.secondary,
                    size: TSizes.iconMd,
                  ),
                ),

                const SizedBox(width: TSizes.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:
                                Theme.of(context).textTheme.titleMedium!.apply(
                                      color: TColors.white,
                                      fontWeightDelta: 1,
                                    ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'RECOMMENDED',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .apply(
                                      color: TColors.primary,
                                      fontWeightDelta: 1,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: TColors.white.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: TColors.secondary,
                  size: TSizes.iconSm,
                ),
              ],
            ),

            const SizedBox(height: TSizes.sm),

            // Processing time
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.clock,
                  color: TColors.secondary,
                  size: TSizes.iconXs,
                ),
                const SizedBox(width: TSizes.xs),
                Text(
                  'Processing time: $processingTime',
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: TColors.secondary,
                        fontWeightDelta: 1,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
