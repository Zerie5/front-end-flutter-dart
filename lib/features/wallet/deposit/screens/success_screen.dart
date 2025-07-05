import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lul/navigation_menu.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/theme/widget_themes/lul_button_style.dart';
import '../controllers/deposit_controller.dart';
import '../models/deposit_models.dart';
import '../services/deposit_api_service.dart';

class SuccessScreen extends StatelessWidget {
  final double amount;
  final PaymentMethodType paymentMethod;
  final String transactionId;
  final String depositId;
  final DateTime timestamp;
  final DepositApiResponse? apiResponse;

  const SuccessScreen({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.depositId,
    required this.timestamp,
    this.apiResponse,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositController>();

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        title: Text(
          'Deposit Successful',
          style: Theme.of(context).textTheme.headlineMedium!.apply(
                color: TColors.white,
                fontWeightDelta: 1,
              ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: TColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),

            // Success Icon
            Container(
              padding: const EdgeInsets.all(TSizes.xl),
              decoration: BoxDecoration(
                color: TColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: TColors.success,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.success.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: const Icon(
                FontAwesomeIcons.check,
                color: TColors.success,
                size: TSizes.iconLg * 2,
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Success Message
            Text(
              'Deposit Successful!',
              style: Theme.of(context).textTheme.headlineLarge!.apply(
                    color: TColors.white,
                    fontWeightDelta: 2,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: TSizes.sm),

            Text(
              'Your deposit has been processed successfully',
              style: Theme.of(context).textTheme.bodyLarge!.apply(
                    color: TColors.white.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: TSizes.spaceBtwSections * 2),

            // Amount Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TSizes.lg),
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
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
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.selectedWalletCurrencySymbol,
                        style: Theme.of(context).textTheme.displayMedium!.apply(
                              color: TColors.secondary,
                              fontWeightDelta: 2,
                            ),
                      ),
                      const SizedBox(width: TSizes.xs),
                      Text(
                        controller.getFormattedAmount(amount),
                        style: Theme.of(context).textTheme.displayMedium!.apply(
                              color: TColors.white,
                              fontWeightDelta: 2,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    apiResponse != null
                        ? 'Added to your ${apiResponse!.wallet.currency} Wallet'
                        : 'Added to your ${controller.selectedWalletCurrencyCode} Wallet',
                    style: Theme.of(context).textTheme.titleMedium!.apply(
                          color: TColors.secondary,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Wallet Balance Update (if API response available)
            if (apiResponse != null) ...[
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
                    Text(
                      'Wallet Balance Updated',
                      style: Theme.of(context).textTheme.titleMedium!.apply(
                            color: TColors.white,
                            fontWeightDelta: 1,
                          ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Previous Balance:',
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: TColors.white.withOpacity(0.8),
                              ),
                        ),
                        Text(
                          controller.getFormattedAmount(
                              apiResponse!.wallet.previousBalance),
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: TColors.white,
                                fontWeightDelta: 1,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Balance:',
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: TColors.white.withOpacity(0.8),
                              ),
                        ),
                        Text(
                          controller.getFormattedAmount(
                              apiResponse!.wallet.newBalance),
                          style: Theme.of(context).textTheme.bodyLarge!.apply(
                                color: TColors.success,
                                fontWeightDelta: 2,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],

            // Transaction Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TSizes.lg),
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
                  Text(
                    'Transaction Details',
                    style: Theme.of(context).textTheme.titleLarge!.apply(
                          color: TColors.white,
                          fontWeightDelta: 1,
                        ),
                  ),
                  const SizedBox(height: TSizes.md),

                  // Transaction ID
                  _buildDetailRow(
                    context,
                    'Transaction ID',
                    transactionId,
                    FontAwesomeIcons.receipt,
                  ),

                  const SizedBox(height: TSizes.sm),

                  // Deposit ID
                  _buildDetailRow(
                    context,
                    'Deposit ID',
                    depositId,
                    FontAwesomeIcons.hashtag,
                  ),

                  const SizedBox(height: TSizes.sm),

                  // Payment Method
                  _buildDetailRow(
                    context,
                    'Payment Method',
                    paymentMethod == PaymentMethodType.card
                        ? 'Credit/Debit Card'
                        : 'Bank Transfer',
                    paymentMethod == PaymentMethodType.card
                        ? FontAwesomeIcons.creditCard
                        : FontAwesomeIcons.buildingColumns,
                  ),

                  const SizedBox(height: TSizes.sm),

                  // Date & Time
                  _buildDetailRow(
                    context,
                    'Date & Time',
                    '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                    FontAwesomeIcons.calendar,
                  ),

                  const SizedBox(height: TSizes.sm),

                  // Status
                  _buildDetailRow(
                    context,
                    'Status',
                    apiResponse?.transaction.status ?? 'Completed',
                    FontAwesomeIcons.check,
                    valueColor: TColors.success,
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Processing Info
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
                    FontAwesomeIcons.circleInfo,
                    color: TColors.secondary,
                    size: TSizes.iconSm,
                  ),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: Text(
                      paymentMethod == PaymentMethodType.card
                          ? 'Your funds are now available in your wallet and ready to use immediately.'
                          : 'Your bank transfer has been initiated. Funds will be available in your wallet within 1-3 business days.',
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: TColors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections * 2),

            // Action Buttons
            Column(
              children: [
                // View Transaction History Button
                LulButton(
                  onPressed: () {
                    // Navigate to transaction history
                    Get.back();
                    Get.back();
                    Get.back();
                    Get.back(); // Go back to home screen
                    // You could also navigate directly to transaction history here
                  },
                  text: 'View Transaction History',
                  backgroundColor: TColors.secondary,
                  foregroundColor: TColors.primary,
                ),

                const SizedBox(height: TSizes.md),

                // Done Button
                LulButton(
                  onPressed: () {
                    // Go back to home screen
                    Get.offAll(() => const NavigationMenu());
                  },
                  text: 'Done',
                  backgroundColor: TColors.success,
                  foregroundColor: TColors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: TColors.secondary,
          size: TSizes.iconXs,
        ),
        const SizedBox(width: TSizes.sm),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium!.apply(
                      color: TColors.white.withOpacity(0.8),
                    ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                        color: valueColor ?? TColors.white,
                        fontWeightDelta: 1,
                      ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
