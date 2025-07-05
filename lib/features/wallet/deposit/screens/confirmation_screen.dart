import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/theme/widget_themes/lul_button_style.dart';
import '../../../../common/widgets/pin/transaction_pin.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../controllers/deposit_controller.dart';
import '../models/deposit_models.dart';
import '../services/deposit_api_service.dart';
import 'unified_success_screen.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  /// Process the deposit after PIN verification
  void _processDepositWithPin(DepositController controller, String pin) async {
    try {
      controller.isProcessing.value = true;

      // Show loading dialog
      TFullScreenLoader.openLoadingDialog(
        'Processing your deposit...',
        'assets/lottie/lottie.json',
      );

      // Make API call to process deposit using unified endpoint
      final apiResponse = await DepositApiService.processUnifiedDeposit();

      // Dismiss loading dialog
      TFullScreenLoader.stopLoading();

      // Navigate to success screen with unified API response
      Get.off(() => UnifiedSuccessScreen(
            response: apiResponse,
          ));
    } catch (e) {
      // Dismiss loading dialog
      TFullScreenLoader.stopLoading();

      print('Deposit processing error: $e');

      Get.snackbar(
        'Deposit Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: TColors.error,
        colorText: TColors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      controller.isProcessing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositController>();

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        title: Text(
          'Confirm Deposit',
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
              'Review your deposit details',
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: TColors.white,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Amount Summary
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
                      Obx(() => Text(
                            controller.selectedWalletCurrencySymbol,
                            style:
                                Theme.of(context).textTheme.displaySmall!.apply(
                                      color: TColors.secondary,
                                      fontWeightDelta: 2,
                                    ),
                          )),
                      const SizedBox(width: TSizes.xs),
                      Obx(() => Text(
                            controller.getFormattedAmount(
                                controller.depositAmount.value),
                            style:
                                Theme.of(context).textTheme.displaySmall!.apply(
                                      color: TColors.white,
                                      fontWeightDelta: 2,
                                    ),
                          )),
                    ],
                  ),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    'Deposit Amount',
                    style: Theme.of(context).textTheme.titleMedium!.apply(
                          color: TColors.secondary,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Payment Method Details
            Obx(() {
              final paymentMethod = controller.selectedPaymentMethod.value;

              if (paymentMethod == PaymentMethodType.card) {
                return _buildCardDetailsSection(context, controller);
              } else {
                return _buildBankDetailsSection(context, controller);
              }
            }),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Fee Information
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
                    'Fee Information',
                    style: Theme.of(context).textTheme.titleMedium!.apply(
                          color: TColors.white,
                          fontWeightDelta: 1,
                        ),
                  ),
                  const SizedBox(height: TSizes.sm),
                  Obx(() {
                    final paymentMethod =
                        controller.selectedPaymentMethod.value;
                    final isCard = paymentMethod == PaymentMethodType.card;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Processing Fee',
                              style:
                                  Theme.of(context).textTheme.bodyMedium!.apply(
                                        color: TColors.white.withOpacity(0.8),
                                      ),
                            ),
                            Text(
                              isCard ? '2.9% + \$0.30' : '\$1.50',
                              style:
                                  Theme.of(context).textTheme.bodyMedium!.apply(
                                        color: TColors.secondary,
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
                              'Processing Time',
                              style:
                                  Theme.of(context).textTheme.bodyMedium!.apply(
                                        color: TColors.white.withOpacity(0.8),
                                      ),
                            ),
                            Text(
                              isCard ? 'Instant' : '1-3 business days',
                              style:
                                  Theme.of(context).textTheme.bodyMedium!.apply(
                                        color: TColors.secondary,
                                        fontWeightDelta: 1,
                                      ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Security Notice
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
                    FontAwesomeIcons.shieldHalved,
                    color: TColors.secondary,
                    size: TSizes.iconSm,
                  ),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: Text(
                      'Your payment information is encrypted and secure. This transaction will appear on your statement as "LulPay Deposit".',
                      style: Theme.of(context).textTheme.bodySmall!.apply(
                            color: TColors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections * 2),

            // Confirm Button
            Obx(() => LulButton(
                  onPressed: controller.isProcessing.value
                      ? null
                      : () {
                          // Show PIN verification screen
                          Get.to(() => TransactionPinCheckScreen(
                                onPinVerified: (String pin) {
                                  _processDepositWithPin(controller, pin);
                                },
                                maxAttempts: 3,
                              ));
                        },
                  text: controller.isProcessing.value
                      ? 'Processing...'
                      : 'Confirm Deposit',
                  backgroundColor: TColors.success,
                  foregroundColor: TColors.white,
                  isDisabled: controller.isProcessing.value,
                  showShadow: true,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDetailsSection(
      BuildContext context, DepositController controller) {
    return Container(
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
                FontAwesomeIcons.creditCard,
                color: TColors.secondary,
                size: TSizes.iconSm,
              ),
              const SizedBox(width: TSizes.sm),
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleMedium!.apply(
                      color: TColors.white,
                      fontWeightDelta: 1,
                    ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            'Credit/Debit Card',
            style: Theme.of(context).textTheme.bodyLarge!.apply(
                  color: TColors.secondary,
                  fontWeightDelta: 1,
                ),
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            '**** **** **** ${controller.cardNumberController.text.replaceAll('-', '').length >= 4 ? controller.cardNumberController.text.replaceAll('-', '').substring(controller.cardNumberController.text.replaceAll('-', '').length - 4) : controller.cardNumberController.text}',
            style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: TColors.white.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            controller.cardholderNameController.text,
            style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: TColors.white.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsSection(
      BuildContext context, DepositController controller) {
    return Container(
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
                FontAwesomeIcons.buildingColumns,
                color: TColors.secondary,
                size: TSizes.iconSm,
              ),
              const SizedBox(width: TSizes.sm),
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleMedium!.apply(
                      color: TColors.white,
                      fontWeightDelta: 1,
                    ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            'Bank Transfer',
            style: Theme.of(context).textTheme.bodyLarge!.apply(
                  color: TColors.secondary,
                  fontWeightDelta: 1,
                ),
          ),
          if (controller.selectedBank.value != null) ...[
            const SizedBox(height: TSizes.xs),
            Text(
              controller.selectedBank.value!.bankName,
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: TColors.white.withOpacity(0.8),
                  ),
            ),
          ],
          const SizedBox(height: TSizes.xs),
          Text(
            '**** ${controller.accountNumberController.text.length >= 4 ? controller.accountNumberController.text.substring(controller.accountNumberController.text.length - 4) : controller.accountNumberController.text}',
            style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: TColors.white.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}
