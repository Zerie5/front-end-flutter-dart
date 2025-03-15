import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/wallet/send/widgets/transfer_controller.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'dart:math';
import 'package:lul/common/widgets/pin/transaction_pin.dart';
import 'package:lul/utils/popups/full_screen_loader.dart';

class LulSendNonMoneyReviewScreen extends StatelessWidget {
  LulSendNonMoneyReviewScreen({super.key});

  final TransferController _transferController = Get.find();
  final LanguageController _languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find();

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          languageController.getText('review_transfer'),
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: TColors.white,
              ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 90),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
            child: Text(
              languageController.getText('transfer_details'),
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: TColors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Container(
                width:
                    MediaQuery.of(context).size.width * 0.99, // Dynamic width
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColors.secondary.withOpacity(0.1),
                      TColors.primary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  border: Border.all(color: TColors.white.withOpacity(0.1)),
                ),
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          _languageController.getText('contact_id'),
                          _transferController.contactId.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('transfer_to'),
                          _transferController.fullName.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('document_type'),
                          _transferController.documentType.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('email'),
                          _transferController.email.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('phone'),
                          _transferController.phone.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('country'),
                          _transferController.country.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('state'),
                          _transferController.state.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('city'),
                          _transferController.city.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('send_amount'),
                          '${_formatAmount(_transferController.sendAmount.value)} ${_transferController.currency.value.toUpperCase()}',
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('transfer_fee'),
                          '${_formatAmount(_transferController.fee.value)} ${_transferController.currency.value.toUpperCase()}',
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        _buildDetailRow(
                          _languageController.getText('total_amount'),
                          '${_formatAmount(_transferController.totalAmount.value)} ${_transferController.currency.value.toUpperCase()}',
                          isTotal: true,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Add description field
                        TextField(
                          decoration: InputDecoration(
                            hintText: _languageController
                                    .getText('description_hint') ??
                                'Add a description (optional)',
                            hintStyle: TextStyle(
                              color: TColors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: TColors.white.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                  color: TColors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: TColors.white),
                            ),
                          ),
                          style: const TextStyle(color: TColors.white),
                          maxLines: 2,
                          onChanged: (value) {
                            _transferController.description.value = value;
                          },
                        ),
                      ],
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: TColors.white),
                      foregroundColor: TColors.white,
                    ),
                    child: Text(languageController.getText('cancel')),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: LulButton(
                    onPressed: () {
                      // Create a unique idempotency key with more entropy
                      final String idempotencyKey =
                          'txn-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}-${Random().nextInt(100000)}';

                      print(
                          'SendNonMoneyReview: Generated idempotency key: $idempotencyKey');

                      // Show transaction-specific PIN check screen
                      Get.to(
                        () => TransactionPinCheckScreen(
                          onPinVerified: (String pin) {
                            // This will be called when PIN is successfully verified
                            // and will receive the verified PIN value
                            print(
                                'PIN verified, initiating non-wallet transaction with PIN: ${pin.length} digits');

                            // Show loading dialog immediately
                            TFullScreenLoader.openLoadingDialog(
                              _languageController
                                      .getText('executing_transaction') ??
                                  'Transaction Executing...',
                              'assets/lottie/lottie.json',
                            );

                            // Initiate the non-wallet transaction with the verified PIN
                            _transferController.initiateNonWalletTransaction(
                                idempotencyKey, pin);
                          },
                        ),
                        fullscreenDialog: true,
                        transition: Transition.fade,
                      );
                    },
                    text: languageController.getText('continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2, // Label takes slightly less space
          child: Text(
            label,
            style: TextStyle(
              color: TColors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 16), // Space between label and value
        Expanded(
          flex: 3, // Value takes more space
          child: Text(
            value,
            style: TextStyle(
              color: TColors.white,
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis, // Handle long text gracefully
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    // Split the number into integer and decimal parts
    List<String> parts = amount.toStringAsFixed(2).split('.');

    // Format the integer part with commas
    String integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    // Return with decimal part
    return '$integerPart.${parts[1]}';
  }
}
