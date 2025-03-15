import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/navigation_menu.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class TransactionSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  const TransactionSuccessScreen({
    super.key,
    required this.transactionData,
  });

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format the timestamp if available
    String formattedDate = '';
    if (transactionData['timestamp'] != null) {
      try {
        final DateTime timestamp = DateTime.parse(transactionData['timestamp']);
        formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp);
      } catch (e) {
        formattedDate = transactionData['timestamp'];
      }
    }

    // Format currency amounts
    String formatAmount(dynamic amount, String currency) {
      if (amount == null) return '0.00 $currency';

      final formatter = NumberFormat.currency(
        symbol: '',
        decimalDigits: 2,
      );

      return '${formatter.format(amount is double ? amount : double.tryParse(amount.toString()) ?? 0.0)} $currency';
    }

    return Scaffold(
      backgroundColor: isDark ? TColors.primaryDark : TColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Success Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: TColors.success.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.tick_circle,
                          color: TColors.success,
                          size: 60,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Success Title
                      Text(
                        languageController.getText('Transfer Successful') ??
                            'Transfer Successful!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: TColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 8),

                      // Transaction ID
                      Text(
                        '${languageController.getText('Transaction ID') ?? 'Transaction ID'}: ${transactionData['transactionId'] ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: TColors.white.withOpacity(0.7),
                            ),
                      ),

                      const SizedBox(height: 4),

                      // Transaction Date
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: TColors.white.withOpacity(0.7),
                            ),
                      ),

                      const SizedBox(height: 40),

                      // Transaction Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(TSizes.defaultSpace),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TColors.secondary.withOpacity(0.1),
                              TColors.primary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(TSizes.cardRadiusLg),
                          border:
                              Border.all(color: TColors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            // Amount
                            _buildDetailRow(
                              context,
                              languageController.getText('Amount') ?? 'Amount',
                              formatAmount(
                                transactionData['amount'],
                                transactionData['currency'] ?? '',
                              ),
                              isHighlighted: true,
                            ),

                            const SizedBox(height: TSizes.spaceBtwItems),

                            // Fee
                            _buildDetailRow(
                              context,
                              languageController.getText('Fee') ?? 'Fee',
                              formatAmount(
                                transactionData['fee'],
                                transactionData['currency'] ?? '',
                              ),
                            ),

                            const SizedBox(height: TSizes.spaceBtwItems),

                            // Total
                            _buildDetailRow(
                              context,
                              languageController.getText('Total') ?? 'Total',
                              formatAmount(
                                transactionData['totalAmount'],
                                transactionData['currency'] ?? '',
                              ),
                              isTotal: true,
                            ),

                            const Divider(
                                color: TColors.white,
                                height: 32,
                                thickness: 0.5),

                            // Recipient
                            _buildDetailRow(
                              context,
                              languageController.getText('Recipient') ??
                                  'Recipient',
                              transactionData['receiverName'] ??
                                  transactionData['recipientName'] ??
                                  '',
                            ),

                            const SizedBox(height: TSizes.spaceBtwItems),

                            // Recipient Phone (for non-wallet transfers)
                            if (transactionData['recipientPhoneNumber'] != null)
                              Column(
                                children: [
                                  _buildDetailRow(
                                    context,
                                    languageController
                                            .getText('Recipient Phone') ??
                                        'Recipient Phone',
                                    transactionData['recipientPhoneNumber'] ??
                                        '',
                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),
                                ],
                              ),

                            // Disbursement Stage (for non-wallet transfers)
                            if (transactionData['disbursementStageName'] !=
                                null)
                              Column(
                                children: [
                                  _buildDetailRow(
                                    context,
                                    languageController.getText('Status') ??
                                        'Status',
                                    transactionData['disbursementStageName'] ??
                                        '',
                                    isHighlighted: true,
                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),
                                ],
                              ),

                            // Description
                            _buildDetailRow(
                              context,
                              languageController.getText('description') ??
                                  'Description',
                              transactionData['description'] ?? '',
                            ),

                            const SizedBox(height: TSizes.spaceBtwItems),

                            // Remaining Balance
                            _buildDetailRow(
                              context,
                              languageController.getText('Remaining Balance') ??
                                  'Remaining Balance',
                              formatAmount(
                                transactionData['senderWalletBalanceAfter'],
                                transactionData['currency'] ?? '',
                              ),
                            ),

                            // Add state information
                            if (transactionData['country'] != null &&
                                transactionData['country'].isNotEmpty)
                              Column(
                                children: [
                                  _buildDetailRow(
                                    context,
                                    languageController.getText('country'),
                                    transactionData['country'],
                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),
                                ],
                              ),
                            if (transactionData['country'] != null &&
                                transactionData['country'].isNotEmpty)
                              const SizedBox(height: TSizes.spaceBtwItems),

                            if (transactionData['state'] != null &&
                                transactionData['state'].isNotEmpty)
                              Column(
                                children: [
                                  _buildDetailRow(
                                    context,
                                    languageController.getText('state'),
                                    transactionData['state'],
                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),
                                ],
                              ),
                            if (transactionData['state'] != null &&
                                transactionData['state'].isNotEmpty)
                              const SizedBox(height: TSizes.spaceBtwItems),

                            if (transactionData['city'] != null &&
                                transactionData['city'].isNotEmpty)
                              Column(
                                children: [
                                  _buildDetailRow(
                                    context,
                                    languageController.getText('city'),
                                    transactionData['city'],
                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAll(() => const NavigationMenu()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.secondary,
                    foregroundColor: TColors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                    ),
                  ),
                  child: Text(
                    languageController.getText('back_to_home') ??
                        'Back to Home',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: TColors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: isHighlighted ? TColors.secondary : TColors.white,
              fontSize: isTotal || isHighlighted ? 18 : 16,
              fontWeight: isTotal || isHighlighted
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
