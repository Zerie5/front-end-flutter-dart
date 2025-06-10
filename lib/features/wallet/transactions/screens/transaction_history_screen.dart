import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lul/features/wallet/transactions/controllers/transaction_history_controller.dart';
import 'package:lul/features/wallet/transactions/models/transaction_model.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/common/widgets/custom_shapes/circular_container.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late final TransactionHistoryController _controller;
  late final LanguageController _languageController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    print('TransactionHistoryScreen: initState called');
    _controller = Get.put(TransactionHistoryController());
    _languageController = Get.find<LanguageController>();
    _scrollController = ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
    print('TransactionHistoryScreen: initState completed');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_controller.isLoadingMore.value &&
        _controller.hasNext.value) {
      _controller.loadMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('TransactionHistoryScreen: build method called');
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background with decorative circles
          Container(
            color: TColors.primary,
            child: SizedBox(
              height: double.infinity,
              child: Stack(
                children: [
                  // Circular Decorations
                  Positioned(
                    top: -150,
                    right: -250,
                    child: LCircularContainer(
                        backgroundColor: TColors.textWhite.withOpacity(0.1)),
                  ),
                  Positioned(
                    top: 100,
                    right: -300,
                    child: LCircularContainer(
                        backgroundColor: TColors.textWhite.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _languageController.getText('transactions'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () =>
                            _controller.refreshTransactionHistory(),
                      ),
                    ],
                  ),
                ),

                // Transaction count summary
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Transactions',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${_controller.totalItems.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                ),

                const SizedBox(height: 20),

                // Transaction list
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? TColors.dark : TColors.light,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: Obx(() => _buildTransactionList()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_controller.isFirstLoad) {
      return const Center(
        child: CircularProgressIndicator(color: TColors.primary),
      );
    }

    if (_controller.hasError.value && !_controller.hasTransactions) {
      return _buildErrorState();
    }

    if (!_controller.hasTransactions) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _controller.refreshTransactionHistory,
      color: TColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _controller.transactions.length +
            (_controller.hasNext.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _controller.transactions.length) {
            // Loading indicator for pagination
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: TColors.primary),
              ),
            );
          }

          final transaction = _controller.transactions[index];
          return _buildTransactionCard(transaction, index);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction, int index) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTransactionDetails(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction header
              Row(
                children: [
                  // Transaction type icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          _getTransactionTypeColor(transaction.transactionType)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTransactionTypeIcon(transaction.transactionType),
                      color:
                          _getTransactionTypeColor(transaction.transactionType),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Transaction details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _controller.getTransactionTypeDisplay(
                              transaction.transactionType),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: dark ? Colors.white : TColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'To: ${transaction.recipient.fullName}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                dark ? Colors.white70 : TColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Amount and status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _controller.getFormattedAmount(transaction),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: dark ? Colors.white : TColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction.transactionStatus),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _controller
                              .getStatusDisplay(transaction.transactionStatus),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Transaction footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: dark ? Colors.white54 : TColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _controller.formatDate(transaction.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: dark ? Colors.white54 : TColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'ID: ${transaction.transactionId.substring(transaction.transactionId.length - 6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: dark ? Colors.white54 : TColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.receipt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.exclamationTriangle,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Transactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _controller.refreshTransactionHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(_languageController.getText('retry') ?? 'Retry'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    final dark = THelperFunctions.isDarkMode(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 100),
        decoration: BoxDecoration(
          color: dark ? TColors.dark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _getTransactionTypeColor(transaction.transactionType)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTransactionTypeIcon(transaction.transactionType),
                      color:
                          _getTransactionTypeColor(transaction.transactionType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: dark ? Colors.white : TColors.textPrimary,
                          ),
                        ),
                        Text(
                          _controller.getFullDateTime(transaction.createdAt),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                dark ? Colors.white70 : TColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.transactionStatus),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _controller
                          .getStatusDisplay(transaction.transactionStatus),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Transaction ID', transaction.transactionId, dark),
                    _buildDetailRow(
                        'Type',
                        _controller.getTransactionTypeDisplay(
                            transaction.transactionType),
                        dark),
                    _buildDetailRow('Amount',
                        _controller.getFormattedAmount(transaction), dark),
                    _buildDetailRow(
                        'Fee', _controller.getFormattedFee(transaction), dark),
                    _buildDetailRow('Total Amount',
                        _controller.getFormattedTotalAmount(transaction), dark),
                    _buildDetailRow('Currency', transaction.currency, dark),
                    const SizedBox(height: 20),
                    Text(
                      'Recipient Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: dark ? Colors.white : TColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        'Name', transaction.recipient.fullName, dark),
                    if (transaction.recipient.workerId != null)
                      _buildDetailRow(
                          'Worker ID', transaction.recipient.workerId!, dark),
                    if (transaction.recipient.phoneNumber != null)
                      _buildDetailRow(
                          'Phone', transaction.recipient.phoneNumber!, dark),
                    if (transaction.recipient.email != null)
                      _buildDetailRow(
                          'Email', transaction.recipient.email!, dark),
                    if (transaction.recipient.country != null)
                      _buildDetailRow(
                          'Country', transaction.recipient.country!, dark),
                    _buildDetailRow('Recipient Type',
                        transaction.recipient.recipientType, dark),
                    if (transaction.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: dark ? Colors.white : TColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: dark ? Colors.white70 : TColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: dark ? Colors.white70 : TColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: dark ? Colors.white : TColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransactionTypeIcon(String type) {
    switch (type) {
      case 'WALLET_TO_WALLET':
        return FontAwesomeIcons.exchange;
      case 'NON_WALLET_TRANSFER':
        return FontAwesomeIcons.paperPlane;
      case 'DEPOSIT':
        return FontAwesomeIcons.arrowDown;
      case 'BUSINESS_PAYMENT':
        return FontAwesomeIcons.building;
      case 'CURRENCY_SWAP':
        return FontAwesomeIcons.sync;
      default:
        return FontAwesomeIcons.receipt;
    }
  }

  Color _getTransactionTypeColor(String type) {
    switch (type) {
      case 'WALLET_TO_WALLET':
        return TColors.primary;
      case 'NON_WALLET_TRANSFER':
        return Colors.blue;
      case 'DEPOSIT':
        return Colors.green;
      case 'BUSINESS_PAYMENT':
        return Colors.purple;
      case 'CURRENCY_SWAP':
        return Colors.orange;
      default:
        return TColors.darkGrey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      case 'REVERSED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
