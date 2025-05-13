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

class LulSendNonMoneyReviewScreen extends StatefulWidget {
  const LulSendNonMoneyReviewScreen({super.key});

  @override
  State<LulSendNonMoneyReviewScreen> createState() =>
      _LulSendNonMoneyReviewScreenState();
}

class _LulSendNonMoneyReviewScreenState
    extends State<LulSendNonMoneyReviewScreen> {
  final TransferController _transferController = Get.find();
  final LanguageController _languageController = Get.find<LanguageController>();

  // Loading state for fee calculation
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    // Calculate the fee when the screen loads
    _calculateFee();
  }

  Future<void> _calculateFee() async {
    _isLoading.value = true;

    try {
      // Calculate fees using the new delayed transfer fee calculation
      await _transferController.calculateDelayedNonWalletFee();

      // Add a small delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('Error calculating delayed transfer fee: $e');

      // Fallback to standard fee calculation if needed
      _transferController.calculateFee();
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _languageController.getText('review_transfer') ?? 'Review Transfer',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: TColors.white,
              ),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TColors.white),
            ),
          );
        }

        return Column(
          children: [
            const SizedBox(height: 90),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Text(
                _languageController.getText('transfer_details') ??
                    'Transfer Details',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_transferController.fullName.value.isNotEmpty)
                        _buildDetailRow(
                          _languageController.getText('transfer_to') ??
                              'Transfer To',
                          _transferController.fullName.value,
                        ),
                      if (_transferController.fullName.value.isNotEmpty)
                        const SizedBox(height: TSizes.spaceBtwItems),

                      if (_transferController.documentType.value.isNotEmpty)
                        _buildDetailRow(
                          _languageController.getText('document_type') ??
                              'Document Type',
                          _transferController.documentType.value,
                        ),
                      if (_transferController.documentType.value.isNotEmpty)
                        const SizedBox(height: TSizes.spaceBtwItems),

                      if (_transferController.contactId.value.isNotEmpty)
                        _buildDetailRow(
                          _languageController.getText('contact_id') ??
                              'Contact ID',
                          _transferController.contactId.value,
                        ),
                      if (_transferController.contactId.value.isNotEmpty)
                        const SizedBox(height: TSizes.spaceBtwItems),

                      if (_transferController.email.value.isNotEmpty)
                        _buildDetailRow(
                          _languageController.getText('email') ?? 'Email',
                          _transferController.email.value,
                        ),
                      if (_transferController.email.value.isNotEmpty)
                        const SizedBox(height: TSizes.spaceBtwItems),

                      if (_transferController.phone.value.isNotEmpty)
                        _buildDetailRow(
                          _languageController.getText('phone') ?? 'Phone',
                          _transferController.phone.value,
                        ),
                      if (_transferController.phone.value.isNotEmpty)
                        const SizedBox(height: TSizes.spaceBtwItems),

                      if (_transferController.country.value.isNotEmpty)
                        _buildDetailRow(
                          _languageController.getText('country') ?? 'Country',
                          _transferController.country.value,
                        ),
                      if (_transferController.country.value.isNotEmpty)
                        const SizedBox(height: TSizes.spaceBtwItems),

                      if (_transferController.state.value.isNotEmpty)
                        _buildDetailRow(
                          _languageController.getText('state') ?? 'State',
                          _transferController.state.value,
                        ),
                      if (_transferController.state.value.isNotEmpty)
                        const SizedBox(height: TSizes.spaceBtwItems),

                      if (_transferController.city.value.isNotEmpty)
                        _buildDetailRow(
                          _languageController.getText('city') ?? 'City',
                          _transferController.city.value,
                        ),
                      if (_transferController.city.value.isNotEmpty)
                        const SizedBox(height: TSizes.spaceBtwItems),

                      // Always show these fields
                      _buildDetailRow(
                        _languageController.getText('send_amount') ??
                            'Send Amount',
                        '${_formatAmount(_transferController.sendAmount.value)} ${_transferController.currency.value.toUpperCase()}',
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      _buildDetailRow(
                        _languageController.getText('transfer_fee') ??
                            'Transfer Fee',
                        '${_formatAmount(_transferController.fee.value)} ${_transferController.currency.value.toUpperCase()}',
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      _buildDetailRow(
                        _languageController.getText('total_amount') ??
                            'Total Amount',
                        '${_formatAmount(_transferController.totalAmount.value)} ${_transferController.currency.value.toUpperCase()}',
                        isTotal: true,
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      // Transaction ID if provided
                      if (_transferController
                          .transactionId.value.isNotEmpty) ...[
                        _buildDetailRow(
                          _languageController.getText('transaction_id') ??
                              'Transaction ID',
                          _transferController.transactionId.value,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                      ],

                      // Add description field
                      TextField(
                        decoration: InputDecoration(
                          hintText:
                              _languageController.getText('description_hint') ??
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
                            borderSide: const BorderSide(color: TColors.white),
                          ),
                        ),
                        style: const TextStyle(color: TColors.white),
                        maxLines: 2,
                        onChanged: (value) {
                          _transferController.description.value = value;
                        },
                      ),
                    ],
                  ),
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
                      child: Text(
                          _languageController.getText('cancel') ?? 'Cancel'),
                    ),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  Expanded(
                    child: LulButton(
                      onPressed: () {
                        // Create a unique idempotency key with more entropy
                        final String idempotencyKey =
                            'delayed-${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}-${Random().nextInt(100000)}';

                        print(
                            'SendNonMoneyReview: Generated idempotency key: $idempotencyKey');

                        // Show transaction-specific PIN check screen
                        Get.to(
                          () => TransactionPinCheckScreen(
                            onPinVerified: (String pin) {
                              // This will be called when PIN is successfully verified
                              // and will receive the verified PIN value
                              print(
                                  'PIN verified, initiating delayed non-wallet transaction with PIN: ${pin.length} digits');

                              // Show loading dialog immediately
                              TFullScreenLoader.openLoadingDialog(
                                _languageController
                                        .getText('executing_transaction') ??
                                    'Transaction Executing...',
                                'assets/lottie/lottie.json',
                              );

                              // Initiate the delayed non-wallet transaction with the verified PIN
                              _transferController
                                  .initiateDelayedNonWalletTransaction(
                                      idempotencyKey, pin);
                            },
                          ),
                          fullscreenDialog: true,
                          transition: Transition.fade,
                        );
                      },
                      text:
                          _languageController.getText('continue') ?? 'Continue',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
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
