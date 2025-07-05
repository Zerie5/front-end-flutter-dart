import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/navigation_menu.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../controllers/deposit_controller.dart';
import '../models/unified_deposit_models.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import '../../home/home.dart';

class UnifiedSuccessScreen extends StatelessWidget {
  final UnifiedDepositResponse response;

  const UnifiedSuccessScreen({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositController>();
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        backgroundColor: TColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),

            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: TColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Title
            Text(
              'Deposit Successful!',
              style: Theme.of(context).textTheme.headlineMedium!.apply(
                    color: TColors.white,
                    fontWeightDelta: 1,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: TSizes.sm),

            // Subtitle
            Text(
              _getSuccessMessage(),
              style: Theme.of(context).textTheme.bodyLarge!.apply(
                    color: TColors.white.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Transaction Details
            _buildTransactionDetails(context, dark),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Done Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.offAll(() => const NavigationMenu()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSuccessMessage() {
    if (response.isBlockchainWallet) {
      return 'Your blockchain wallet has been funded successfully using ${response.data.fundingSource ?? "external service"}.';
    } else {
      return 'Your deposit has been processed successfully via ${response.data.depositResponse?.deposit.paymentProcessor ?? "payment processor"}.';
    }
  }

  Widget _buildTransactionDetails(BuildContext context, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? TColors.dark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Transaction Details'),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Transaction ID', response.data.transaction.transactionId),
          _buildDetailRow('Amount', _getFormattedAmount()),
          _buildDetailRow('Currency', response.data.transaction.currency),
          if (response.isBackendWallet &&
              response.data.depositResponse != null) ...[
            _buildDetailRow(
                'Fee', response.data.depositResponse!.transaction.formattedFee),
            _buildDetailRow(
                'Total Amount',
                response
                    .data.depositResponse!.transaction.formattedTotalAmount),
            _buildDetailRow(
                'Status', response.data.depositResponse!.transaction.status),
          ],
          if (response.isBlockchainWallet &&
              response.data.transaction.txHash != null) ...[
            _buildDetailRow(
                'Blockchain Hash', response.data.transaction.txHash!,
                isHash: true),
            _buildDetailRow('Network', 'Stellar'),
          ],
          _buildDetailRow('Timestamp', _formatTimestamp()),
          const SizedBox(height: 24),
          _buildSectionHeader('Wallet Information'),
          const SizedBox(height: 16),
          if (response.isBlockchainWallet) ...[
            _buildDetailRow('Previous Balance',
                response.data.wallet.formattedPreviousBalance),
            _buildDetailRow(
                'New Balance', response.data.wallet.formattedNewBalance),
            if (response.data.wallet.publicKey != null)
              _buildDetailRow('Public Key', response.data.wallet.publicKey!,
                  isHash: true),
          ] else if (response.data.depositResponse != null) ...[
            _buildDetailRow(
                'Wallet ID',
                response.data.depositResponse!.transaction.wallet.walletId
                    .toString()),
            _buildDetailRow(
                'New Balance',
                response.data.depositResponse!.transaction.wallet
                    .formattedNewBalance),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader('Payment Information'),
          const SizedBox(height: 16),
          if (response.isBackendWallet &&
              response.data.depositResponse != null) ...[
            _buildDetailRow('Payment Method',
                response.data.depositResponse!.deposit.paymentMethodType),
            _buildDetailRow('Payment Processor',
                response.data.depositResponse!.deposit.paymentProcessor),
            if (response.data.depositResponse!.deposit.confirmationCode != null)
              _buildDetailRow('Confirmation Code',
                  response.data.depositResponse!.deposit.confirmationCode!),
            if (response.data.depositResponse!.deposit.cardInfo != null) ...[
              _buildDetailRow('Card',
                  '**** **** **** ${response.data.depositResponse!.deposit.cardInfo!.lastFour}'),
              _buildDetailRow('Card Brand',
                  response.data.depositResponse!.deposit.cardInfo!.brand),
              _buildDetailRow('Card Type',
                  response.data.depositResponse!.deposit.cardInfo!.type),
            ],
            if (response.data.depositResponse!.deposit.bankInfo != null) ...[
              _buildDetailRow('Bank',
                  response.data.depositResponse!.deposit.bankInfo!.bankName),
              _buildDetailRow('Account Type',
                  response.data.depositResponse!.deposit.bankInfo!.accountType),
              _buildDetailRow(
                  'Account Number',
                  response
                      .data.depositResponse!.deposit.bankInfo!.accountNumber),
            ],
          ] else if (response.isBlockchainWallet) ...[
            _buildDetailRow('Funding Source',
                response.data.fundingSource ?? 'External Service'),
            _buildDetailRow('Service', response.data.service),
            _buildDetailRow('Routed To', response.data.routedTo),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: TColors.primary,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHash = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isHash
                ? Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getFormattedAmount() {
    final amount = response.data.transaction.formattedAmount;
    final currency = response.data.transaction.currency;
    return '$amount $currency';
  }

  String _formatTimestamp() {
    try {
      final timestamp = DateTime.parse(response.data.transaction.timestamp);
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return response.data.transaction.timestamp;
    }
  }
}
