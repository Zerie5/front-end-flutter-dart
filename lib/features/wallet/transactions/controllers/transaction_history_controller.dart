import 'package:get/get.dart';
import 'package:lul/features/wallet/transactions/models/transaction_model.dart';
import 'package:lul/services/transaction_history_service.dart';
import 'package:lul/utils/popups/loaders.dart';

class TransactionHistoryController extends GetxController {
  // Observable variables
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination variables
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalItems = 0.obs;
  final RxBool hasNext = false.obs;
  final RxBool hasPrevious = false.obs;

  // Page size for pagination
  static const int pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    print('TransactionHistoryController: onInit called');
    // Load initial transaction data
    loadTransactionHistory();
  }

  /// Load transaction history (first page)
  Future<void> loadTransactionHistory() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      print('TransactionHistoryController: Loading transaction history');

      final response = await TransactionHistoryService.getTransactionHistory(
        page: 0,
        size: pageSize,
      );

      if (response.success) {
        transactions.clear();
        transactions.addAll(response.transactions);

        // Update pagination info
        currentPage.value = response.pagination.currentPage;
        totalPages.value = response.pagination.totalPages;
        totalItems.value = response.pagination.totalItems;
        hasNext.value = response.pagination.hasNext;
        hasPrevious.value = response.pagination.hasPrevious;

        print(
            'TransactionHistoryController: Loaded ${transactions.length} transactions');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;

        // Show error to user
        LulLoaders.lulerrorSnackBar(
          title: 'Error',
          message: response.message,
        );
      }
    } catch (e) {
      print('TransactionHistoryController: Error loading transactions - $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load transaction history';

      LulLoaders.lulerrorSnackBar(
        title: 'Error',
        message: 'Failed to load transaction history',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more transactions (pagination)
  Future<void> loadMoreTransactions() async {
    if (isLoadingMore.value || !hasNext.value) return;

    try {
      isLoadingMore.value = true;

      print(
          'TransactionHistoryController: Loading more transactions, page ${currentPage.value + 1}');

      final response = await TransactionHistoryService.getTransactionHistory(
        page: currentPage.value + 1,
        size: pageSize,
      );

      if (response.success) {
        transactions.addAll(response.transactions);

        // Update pagination info
        currentPage.value = response.pagination.currentPage;
        totalPages.value = response.pagination.totalPages;
        totalItems.value = response.pagination.totalItems;
        hasNext.value = response.pagination.hasNext;
        hasPrevious.value = response.pagination.hasPrevious;

        print(
            'TransactionHistoryController: Loaded ${response.transactions.length} more transactions. Total: ${transactions.length}');
      } else {
        LulLoaders.lulerrorSnackBar(
          title: 'Error',
          message: response.message,
        );
      }
    } catch (e) {
      print(
          'TransactionHistoryController: Error loading more transactions - $e');
      LulLoaders.lulerrorSnackBar(
        title: 'Error',
        message: 'Failed to load more transactions',
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh transaction history
  Future<void> refreshTransactionHistory() async {
    currentPage.value = 0;
    await loadTransactionHistory();
  }

  /// Get formatted amount for display
  String getFormattedAmount(TransactionModel transaction) {
    return TransactionHistoryService.formatAmount(
      transaction.amount,
      transaction.currency,
    );
  }

  /// Get formatted total amount for display
  String getFormattedTotalAmount(TransactionModel transaction) {
    return TransactionHistoryService.formatAmount(
      transaction.totalAmount,
      transaction.currency,
    );
  }

  /// Get formatted fee for display
  String getFormattedFee(TransactionModel transaction) {
    return TransactionHistoryService.formatAmount(
      transaction.fee,
      transaction.currency,
    );
  }

  /// Get transaction status color based on status
  String getStatusColor(String status) {
    return TransactionHistoryService.getStatusColor(status);
  }

  /// Get transaction type display text
  String getTransactionTypeDisplay(String type) {
    return TransactionHistoryService.getTransactionTypeDisplay(type);
  }

  /// Format date for display
  String formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        // Today - show time
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        // Yesterday
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        // Within a week - show day name
        const days = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ];
        return days[date.weekday - 1];
      } else {
        // Older - show date
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      }
    } catch (e) {
      print(
          'TransactionHistoryController: Error formatting date $dateString - $e');
      return dateString;
    }
  }

  /// Get full formatted date and time
  String getFullDateTime(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print(
          'TransactionHistoryController: Error formatting full date $dateString - $e');
      return dateString;
    }
  }

  /// Get transaction status display text
  String getStatusDisplay(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Completed';
      case 'PENDING':
        return 'Pending';
      case 'FAILED':
        return 'Failed';
      case 'REVERSED':
        return 'Reversed';
      default:
        return status;
    }
  }

  /// Check if there are any transactions
  bool get hasTransactions => transactions.isNotEmpty;

  /// Check if this is the first load
  bool get isFirstLoad => transactions.isEmpty && isLoading.value;
}
