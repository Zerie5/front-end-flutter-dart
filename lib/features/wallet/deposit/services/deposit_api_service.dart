import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deposit_models.dart';
import '../models/unified_deposit_models.dart';
import '../controllers/deposit_controller.dart';
import '../../../../utils/http/http_client.dart';
import 'package:get/get.dart';

class DepositApiService {
  static const String _depositEndpoint = '/api/user/deposit';
  static const String _unifiedDepositEndpoint = '/api/user/deposit/unified';

  /// Process deposit transaction via unified API
  static Future<UnifiedDepositResponse> processUnifiedDeposit() async {
    try {
      final controller = Get.find<DepositController>();

      // Get authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in again.');
      }

      // Build request body based on payment method
      final Map<String, dynamic> requestBody = {
        'amount': controller.depositAmount.value.toStringAsFixed(2),
        'currency': controller.selectedWalletCurrencyCode,
        'walletId': controller.selectedWalletId,
        'paymentMethodType':
            controller.selectedPaymentMethod.value == PaymentMethodType.card
                ? 'CARD'
                : 'BANK_TRANSFER',
        'paymentProcessor': controller.getPaymentProcessor(),
        'description':
            'Wallet top-up via ${controller.selectedPaymentMethod.value == PaymentMethodType.card ? 'card' : 'bank transfer'}',
        'additionalData': controller.getAdditionalData(),
        'idempotencyKey': generateIdempotencyKey(),
      };

      // Add card details for card payments
      if (controller.selectedPaymentMethod.value == PaymentMethodType.card) {
        final cardInfo = controller.getCardInfo();
        requestBody['cardDetails'] = {
          'lastFour':
              controller.cardNumberController.text.replaceAll('-', '').length >=
                      4
                  ? controller.cardNumberController.text
                      .replaceAll('-', '')
                      .substring(controller.cardNumberController.text
                              .replaceAll('-', '')
                              .length -
                          4)
                  : controller.cardNumberController.text.replaceAll('-', ''),
          'brand': cardInfo['brand'],
          'type': cardInfo['type'],
          'expiryMonth': controller.expiryMonthController.text,
          'expiryYear': controller.expiryYearController.text,
          'holderName': controller.cardholderNameController.text,
        };
      }

      // Add bank details for bank transfers
      if (controller.selectedPaymentMethod.value == PaymentMethodType.bank) {
        requestBody['bankDetails'] = {
          'bankName':
              controller.selectedBank.value?.bankName ?? 'Selected Bank',
          'accountType': 'SAVINGS', // Default for mock
          'routingNumber': controller.routingNumberController.text.isNotEmpty
              ? controller.routingNumberController.text
              : 'MOCK001234',
          'accountNumber': controller.accountNumberController.text.length >= 4
              ? '****${controller.accountNumberController.text.substring(controller.accountNumberController.text.length - 4)}'
              : '****${controller.accountNumberController.text}',
          'accountHolderName': controller.accountHolderNameController.text,
        };
      }

      // Add payment-specific details
      if (controller.selectedPaymentMethod.value == PaymentMethodType.card) {
        final cardInfo = controller.getCardInfo();
        requestBody['cardDetails'] = {
          'lastFour': controller.cardNumberController.text
              .replaceAll('-', '')
              .substring(controller.cardNumberController.text
                      .replaceAll('-', '')
                      .length -
                  4),
          'brand': cardInfo['brand'],
          'type': cardInfo['type'],
          'expiryMonth': controller.expiryMonthController.text,
          'expiryYear': controller.expiryYearController.text,
          'holderName': controller.cardholderNameController.text,
        };
      } else {
        requestBody['bankDetails'] = {
          'bankName': controller.selectedBank.value?.bankName ?? '',
          'accountType':
              controller.selectedBank.value?.accountType.name.toUpperCase() ??
                  'CHECKING',
          'routingNumber': controller.routingNumberController.text,
          'accountNumber': controller.accountNumberController.text.length > 4
              ? '****${controller.accountNumberController.text.substring(controller.accountNumberController.text.length - 4)}'
              : controller.accountNumberController.text,
          'accountHolderName': controller.accountHolderNameController.text,
        };
      }

      print(
          'UnifiedDepositApiService: Request body: ${requestBody.toString()}');

      // Make API request
      final response = await http.post(
        Uri.parse('${THttpHelper.baseUrl}$_unifiedDepositEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print(
          'UnifiedDepositApiService: Response status: ${response.statusCode}');
      print('UnifiedDepositApiService: Response body: ${response.body}');

      // Parse response
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success response
        return UnifiedDepositResponse.fromJson(responseData);
      } else {
        // Error response
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Unknown error occurred';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('UnifiedDepositApiService: Error processing deposit: $e');
      rethrow;
    }
  }

  /// Legacy process deposit method (kept for backward compatibility)
  static Future<DepositApiResponse> processDeposit({
    required double amount,
    required String currency,
    required int walletId,
    required PaymentMethodType paymentMethodType,
    required String description,
    CardModel? cardDetails,
    BankModel? bankDetails,
    String? paymentProcessor,
    String? externalTransactionId,
    String? idempotencyKey,
  }) async {
    try {
      // Get authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in again.');
      }

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'amount': amount,
        'currency': currency,
        'walletId': walletId,
        'paymentMethodType': _getPaymentMethodString(paymentMethodType),
        'description': description,
      };

      // Add payment processor if provided
      if (paymentProcessor != null && paymentProcessor.isNotEmpty) {
        requestBody['paymentProcessor'] = paymentProcessor;
      }

      // Add card details for card payments
      if (paymentMethodType == PaymentMethodType.card && cardDetails != null) {
        requestBody['cardDetails'] = {
          'lastFour': cardDetails.cardNumber.length >= 4
              ? cardDetails.cardNumber
                  .substring(cardDetails.cardNumber.length - 4)
              : cardDetails.cardNumber,
          'brand': _getCardBrand(cardDetails.cardNumber),
          'type': 'CREDIT', // Default to credit, could be enhanced
          'expiryMonth': cardDetails.expiryMonth,
          'expiryYear': cardDetails.expiryYear,
          'holderName': cardDetails.cardholderName,
        };
        requestBody['paymentProcessor'] = 'STRIPE'; // Default for cards
      }

      // Add bank details for bank transfers
      if (paymentMethodType == PaymentMethodType.bank && bankDetails != null) {
        requestBody['bankDetails'] = {
          'bankName': bankDetails.bankName,
          'accountNumber':
              bankDetails.maskedAccountNumber, // Use masked for security
          'routingNumber': bankDetails.routingNumber,
          'accountHolderName': bankDetails.accountHolderName,
          'accountType': bankDetails.accountType.name.toUpperCase(),
        };
        requestBody['paymentProcessor'] = 'PLAID'; // Default for bank transfers
      }

      // Add external transaction ID if provided
      if (externalTransactionId != null && externalTransactionId.isNotEmpty) {
        requestBody['externalTransactionId'] = externalTransactionId;
      }

      // Add idempotency key if provided
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
        requestBody['idempotencyKey'] = idempotencyKey;
      }

      print(
          'DepositApiService: Sending deposit request to ${THttpHelper.baseUrl}$_depositEndpoint');
      print('DepositApiService: Request body: ${jsonEncode(requestBody)}');

      // Make API request
      final response = await http.post(
        Uri.parse('${THttpHelper.baseUrl}$_depositEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('DepositApiService: Response status: ${response.statusCode}');
      print('DepositApiService: Response body: ${response.body}');

      // Parse response
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success response
        return DepositApiResponse.fromJson(responseData);
      } else {
        // Error response
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Unknown error occurred';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DepositApiService: Error processing deposit: $e');
      rethrow;
    }
  }

  /// Convert PaymentMethodType enum to API string
  static String _getPaymentMethodString(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.card:
        return 'CARD';
      case PaymentMethodType.bank:
        return 'BANK_TRANSFER';
    }
  }

  /// Determine card brand from card number (Mock - accepts any card)
  static String _getCardBrand(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');

    // For mock implementation, accept any card number
    if (cleaned.isEmpty) {
      return 'VISA'; // Default for empty numbers
    }

    if (cleaned.startsWith('4')) {
      return 'VISA';
    } else if (cleaned.startsWith('5') || cleaned.startsWith('2')) {
      return 'MASTERCARD';
    } else if (cleaned.startsWith('3')) {
      return 'AMEX';
    } else if (cleaned.startsWith('6')) {
      return 'DISCOVER';
    } else {
      // For mock: any other number defaults to VISA to ensure it works
      return 'VISA';
    }
  }

  /// Generate idempotency key
  static String generateIdempotencyKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'deposit_${timestamp}_${timestamp.hashCode.abs()}';
  }
}

/// API Response Models
class DepositApiResponse {
  final bool success;
  final String message;
  final DepositTransaction transaction;
  final WalletInfo wallet;

  DepositApiResponse({
    required this.success,
    required this.message,
    required this.transaction,
    required this.wallet,
  });

  factory DepositApiResponse.fromJson(Map<String, dynamic> json) {
    return DepositApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transaction: DepositTransaction.fromJson(json['transaction']),
      wallet: WalletInfo.fromJson(json['wallet']),
    );
  }
}

class DepositTransaction {
  final String transactionId;
  final double amount;
  final String currency;
  final String status;
  final DateTime timestamp;

  DepositTransaction({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.timestamp,
  });

  factory DepositTransaction.fromJson(Map<String, dynamic> json) {
    return DepositTransaction(
      transactionId: json['transactionId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'PENDING',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class WalletInfo {
  final int walletId;
  final String currency;
  final double previousBalance;
  final double depositAmount;
  final double newBalance;

  WalletInfo({
    required this.walletId,
    required this.currency,
    required this.previousBalance,
    required this.depositAmount,
    required this.newBalance,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      walletId: json['walletId'] ?? 2,
      currency: json['currency'] ?? 'USD',
      previousBalance: (json['previousBalance'] as num?)?.toDouble() ?? 0.0,
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
      newBalance: (json['newBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
