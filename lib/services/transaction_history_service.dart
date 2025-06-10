import 'package:dio/dio.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/features/wallet/transactions/models/transaction_model.dart';

class TransactionHistoryService {
  /// Fetches user transaction history with pagination
  ///
  /// [page] - Page number (0-based indexing)
  /// [size] - Number of transactions per page (max: 50)
  ///
  /// Returns a [TransactionResponse] containing transactions and pagination info
  static Future<TransactionResponse> getTransactionHistory({
    int page = 0,
    int size = 10,
  }) async {
    try {
      print(
          'TransactionHistoryService: getTransactionHistory called with page=$page, size=$size');

      // Get the JWT token
      final token = await AuthStorage.getToken();
      if (token == null) {
        print('TransactionHistoryService: No token found');
        return TransactionResponse(
          success: false,
          message: 'Authentication token not available',
          transactions: [],
          pagination: PaginationModel(
            currentPage: 0,
            pageSize: 10,
            totalItems: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            isFirst: true,
            isLast: true,
          ),
        );
      }

      print(
          'TransactionHistoryService: Fetching transactions for page $page, size $size');

      // Make the API call using Dio with proper headers
      final response = await THttpHelper.dio.get(
        '/api/user/transactions',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      print(
          'TransactionHistoryService: API response status: ${response.statusCode}');
      print('TransactionHistoryService: API response data: ${response.data}');

      if (response.statusCode == 200) {
        // Parse the response using our model
        final transactionResponse = TransactionResponse.fromJson(response.data);

        print(
            'TransactionHistoryService: Successfully parsed ${transactionResponse.transactions.length} transactions');
        return transactionResponse;
      } else {
        print(
            'TransactionHistoryService: API request failed with status ${response.statusCode}');
        return TransactionResponse(
          success: false,
          message:
              'Failed to retrieve transactions: Server returned status ${response.statusCode}',
          transactions: [],
          pagination: PaginationModel(
            currentPage: page,
            pageSize: size,
            totalItems: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            isFirst: true,
            isLast: true,
          ),
        );
      }
    } catch (e) {
      print(
          'TransactionHistoryService: Error fetching transaction history: $e');

      if (e is DioException) {
        print('TransactionHistoryService: DioError type: ${e.type}');
        print('TransactionHistoryService: DioError message: ${e.message}');
        if (e.response != null) {
          print(
              'TransactionHistoryService: Response status: ${e.response?.statusCode}');
          print(
              'TransactionHistoryService: Response data: ${e.response?.data}');
        }

        // Handle specific error cases
        String errorMessage;
        switch (e.response?.statusCode) {
          case 401:
            errorMessage = 'Unauthorized - Please login again';
            // Clear the token if it's invalid
            await AuthStorage.clearToken();
            break;
          case 500:
            errorMessage = 'Internal server error';
            break;
          default:
            errorMessage = 'Failed to retrieve transactions: ${e.message}';
        }

        return TransactionResponse(
          success: false,
          message: errorMessage,
          transactions: [],
          pagination: PaginationModel(
            currentPage: page,
            pageSize: size,
            totalItems: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            isFirst: true,
            isLast: true,
          ),
        );
      }

      return TransactionResponse(
        success: false,
        message: 'Failed to retrieve transactions: $e',
        transactions: [],
        pagination: PaginationModel(
          currentPage: page,
          pageSize: size,
          totalItems: 0,
          totalPages: 0,
          hasNext: false,
          hasPrevious: false,
          isFirst: true,
          isLast: true,
        ),
      );
    }
  }

  /// Helper method to format currency amounts
  static String formatAmount(double amount, String currency) {
    return '${_getCurrencySymbol(currency)}${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// Helper method to get currency symbol
  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'UGX':
        return 'UGX ';
      case 'ETB':
        return 'Br ';
      case 'ERN':
        return 'ERN ';
      default:
        return '$currency ';
    }
  }

  /// Helper method to get transaction status color
  static String getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'success';
      case 'PENDING':
        return 'warning';
      case 'FAILED':
        return 'error';
      case 'REVERSED':
        return 'error';
      default:
        return 'info';
    }
  }

  /// Helper method to get transaction type display text
  static String getTransactionTypeDisplay(String type) {
    switch (type) {
      case 'WALLET_TO_WALLET':
        return 'Wallet Transfer';
      case 'NON_WALLET_TRANSFER':
        return 'Money Transfer';
      case 'DEPOSIT':
        return 'Deposit';
      case 'BUSINESS_PAYMENT':
        return 'Business Payment';
      case 'CURRENCY_SWAP':
        return 'Currency Exchange';
      default:
        return type
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : word)
            .join(' ');
    }
  }
}
