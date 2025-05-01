import 'package:get/get.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:dio/dio.dart';

class TransactionService extends GetxService {
  Future<TransactionService> init() async {
    return this;
  }

  Future<Map<String, dynamic>> walletToWalletTransfer({
    required int senderWalletTypeId,
    required String receiverWorkerId,
    required double amount,
    required String pin,
    required String description,
    required String idempotencyKey,
  }) async {
    print(
        'TransactionService: walletToWalletTransfer called with PIN length ${pin.length} and idempotencyKey $idempotencyKey');

    try {
      final token = await AuthStorage.getToken();
      print(
          'TransactionService: Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        print('TransactionService: No token found, returning error');
        return {
          'status': 'error',
          'code': 'ERR_502',
          'message': 'Session expired. Please login again.'
        };
      }

      // Create the request data
      final Map<String, dynamic> requestData = {
        'senderWalletTypeId': senderWalletTypeId,
        'receiverWorkerId': receiverWorkerId,
        'amount': amount,
        'pin': pin,
        'description': description,
        'idempotencyKey': idempotencyKey,
      };

      print('TransactionService: Transaction request data: $requestData');

      // Use Dio with JWT token
      print(
          'TransactionService: Sending API request to /api/transactions/wallet-to-wallet');
      final response = await THttpHelper.dio.post(
        '/api/transactions/wallet-to-wallet',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print(
          'TransactionService: API response received: ${response.statusCode}');
      print('TransactionService: Response data: ${response.data}');
      return response.data;
    } catch (e) {
      print('TransactionService: Error during transaction: $e');

      // Handle specific error cases
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          // Handle authentication errors
          if (e.response?.data != null &&
              e.response?.data['code'] == 'ERR_651') {
            // Invalid PIN
            return {
              'status': 'error',
              'code': 'ERR_651',
              'message': 'The provided PIN is incorrect.'
            };
          } else {
            // Other authentication errors
            return {
              'status': 'error',
              'code': 'ERR_502',
              'message': 'Authentication failed. Please try logging in again.'
            };
          }
        } else if (e.response?.statusCode == 400) {
          // Handle bad request errors
          final errorCode = e.response?.data['code'];
          final errorMessage = e.response?.data['message'];

          // Return the specific error code and message
          return {
            'status': 'error',
            'code': errorCode ?? 'ERR_900',
            'message': errorMessage ?? 'Invalid request parameters.'
          };
        } else if (e.response?.statusCode == 404) {
          // Handle not found errors
          final errorCode = e.response?.data['code'];

          if (errorCode == 'ERR_501') {
            return {
              'status': 'error',
              'code': 'ERR_501',
              'message': 'Receiver with specified worker ID not found.'
            };
          } else if (errorCode == 'ERR_904') {
            return {
              'status': 'error',
              'code': 'ERR_904',
              'message': 'Sender or receiver wallet not found.'
            };
          } else {
            return {
              'status': 'error',
              'code': errorCode ?? 'ERR_900',
              'message': e.response?.data['message'] ?? 'Resource not found.'
            };
          }
        } else if (e.response?.statusCode == 403) {
          // Handle forbidden errors
          final errorCode = e.response?.data['code'];

          if (errorCode == 'ERR_905') {
            return {
              'status': 'error',
              'code': 'ERR_905',
              'message': 'You don\'t have access to the specified wallet.'
            };
          } else {
            return {
              'status': 'error',
              'code': errorCode ?? 'ERR_900',
              'message': e.response?.data['message'] ?? 'Access denied.'
            };
          }
        } else if (e.response?.statusCode == 500) {
          // Handle server errors
          return {
            'status': 'error',
            'code': 'ERR_901',
            'message': 'Transaction failed. Please try again later.'
          };
        }

        // If we have a response with error data, return it
        if (e.response?.data != null) {
          final errorCode = e.response?.data['code'];
          final errorMessage = e.response?.data['message'];

          return {
            'status': 'error',
            'code': errorCode ?? 'ERR_900',
            'message':
                errorMessage ?? 'An error occurred during the transaction.'
          };
        }
      }

      // Default error response
      return {
        'status': 'error',
        'code': 'ERR_700',
        'message': 'An unexpected error occurred during the transaction.'
      };
    }
  }

  Future<Map<String, dynamic>> nonWalletTransfer({
    required int senderWalletTypeId,
    required double amount,
    required String pin,
    required String recipientFullName,
    required String idDocumentType,
    required String idNumber,
    required String phoneNumber,
    String? email,
    required String country,
    String? state,
    String? city,
    String? relationship,
    String? description,
    required String idempotencyKey,
  }) async {
    print(
        'TransactionService: nonWalletTransfer called with PIN length ${pin.length} and idempotencyKey $idempotencyKey');

    try {
      final token = await AuthStorage.getToken();
      print(
          'TransactionService: Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        print('TransactionService: No token found, returning error');
        return {
          'status': 'error',
          'code': 'ERR_502',
          'message': 'Session expired. Please login again.'
        };
      }

      // Create the request data
      final Map<String, dynamic> requestData = {
        'senderWalletTypeId': senderWalletTypeId,
        'amount': amount,
        'pin': pin,
        'recipientFullName': recipientFullName,
        'idDocumentType': idDocumentType,
        'idNumber': idNumber,
        'phoneNumber': phoneNumber,
        'email': email,
        'country': country,
        'state': state,
        'city': city,
        'relationship': relationship,
        'description': description,
        'idempotencyKey': idempotencyKey,
      };

      // Remove null values
      requestData.removeWhere((key, value) => value == null);

      print(
          'TransactionService: Non-wallet transaction request data: $requestData');

      // Use Dio with JWT token
      print(
          'TransactionService: Sending API request to /api/v1/transfers/non-wallet');
      final response = await THttpHelper.dio.post(
        '/api/v1/transfers/non-wallet',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print(
          'TransactionService: API response received: ${response.statusCode}');
      print('TransactionService: Response data: ${response.data}');

      // Map the response to our expected format
      if (response.data['success'] == true) {
        return {
          'status': 'success',
          'data': response.data['data'] ?? {},
        };
      } else {
        return {
          'status': 'error',
          'code': response.data['errorCode'] ?? 'UNKNOWN_ERROR',
          'message': response.data['message'] ?? 'Transaction failed',
        };
      }
    } catch (e) {
      print('TransactionService: Error during non-wallet transaction: $e');

      // Handle specific error cases
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          // Handle authentication errors
          if (e.response?.data != null &&
              e.response?.data['errorCode'] == 'ERR_651') {
            // Invalid PIN
            return {
              'status': 'error',
              'code': 'ERR_651',
              'message': 'The provided PIN is incorrect.'
            };
          } else {
            // Other authentication errors
            return {
              'status': 'error',
              'code': 'ERR_502',
              'message': 'Authentication failed. Please try logging in again.'
            };
          }
        } else if (e.response?.statusCode == 400) {
          // Handle bad request errors
          final errorCode = e.response?.data['errorCode'];
          final errorMessage = e.response?.data['message'];

          // Return the specific error code and message
          return {
            'status': 'error',
            'code': errorCode ?? 'ERR_900',
            'message': errorMessage ?? 'Invalid request parameters.'
          };
        } else if (e.response?.statusCode == 404) {
          // Handle not found errors
          final errorCode = e.response?.data['errorCode'];

          if (errorCode == 'ERR_926') {
            return {
              'status': 'error',
              'code': 'ERR_926',
              'message': 'Recipient details not found.'
            };
          } else if (errorCode == 'ERR_904') {
            return {
              'status': 'error',
              'code': 'ERR_904',
              'message': 'Sender wallet not found.'
            };
          } else {
            return {
              'status': 'error',
              'code': errorCode ?? 'ERR_900',
              'message': e.response?.data['message'] ?? 'Resource not found.'
            };
          }
        } else if (e.response?.statusCode == 403) {
          // Handle forbidden errors
          final errorCode = e.response?.data['errorCode'];

          if (errorCode == 'ERR_905') {
            return {
              'status': 'error',
              'code': 'ERR_905',
              'message': 'You don\'t have access to the specified wallet.'
            };
          } else {
            return {
              'status': 'error',
              'code': errorCode ?? 'ERR_900',
              'message': e.response?.data['message'] ?? 'Access denied.'
            };
          }
        } else if (e.response?.statusCode == 500) {
          // Handle server errors
          return {
            'status': 'error',
            'code': 'ERR_925',
            'message': 'Non-wallet transfer failed. Please try again later.'
          };
        }

        // If we have a response with error data, return it
        if (e.response?.data != null) {
          final errorCode = e.response?.data['errorCode'];
          final errorMessage = e.response?.data['message'];

          return {
            'status': 'error',
            'code': errorCode ?? 'ERR_900',
            'message':
                errorMessage ?? 'An error occurred during the transaction.'
          };
        }
      }

      // Default error response
      return {
        'status': 'error',
        'code': 'ERR_700',
        'message':
            'An unexpected error occurred during the non-wallet transaction.'
      };
    }
  }

  Future<Map<String, dynamic>> delayedNonWalletTransfer({
    required int walletTypeId,
    required double amount,
    required String currency,
    required String pin,
    required String recipientFullName,
    required String idDocumentType,
    required String idNumber,
    required String phoneNumber,
    String? email,
    required String country,
    String? state,
    String? city,
    String? relationship,
    String? description,
    String? externalTransactionId,
    required String idempotencyKey,
  }) async {
    print(
        'TransactionService: delayedNonWalletTransfer called with PIN length ${pin.length} and idempotencyKey $idempotencyKey');

    try {
      final token = await AuthStorage.getToken();
      print(
          'TransactionService: Token retrieved: ${token != null ? 'Yes' : 'No'}');

      if (token == null) {
        print('TransactionService: No token found, returning error');
        return {
          'status': 'error',
          'code': 'ERR_502',
          'message': 'Session expired. Please login again.'
        };
      }

      // Create the request data
      final Map<String, dynamic> requestData = {
        'senderWalletTypeId': walletTypeId,
        'amount': amount,
        'currency': currency,
        'pin': pin,
        'recipientFullName': recipientFullName,
        'idDocumentType': idDocumentType,
        'idNumber': idNumber,
        'phoneNumber': phoneNumber,
        'email': email,
        'country': country,
        'state': state,
        'city': city,
        'relationship': relationship,
        'description': description,
        'externalTransactionId': externalTransactionId,
        'idempotencyKey': idempotencyKey,
      };

      // Remove null values
      requestData.removeWhere((key, value) => value == null);

      print(
          'TransactionService: Delayed non-wallet transaction request data: $requestData');

      // Use Dio with JWT token
      print(
          'TransactionService: Sending API request to /api/v1/transfers/non-wallet/delayed');
      final response = await THttpHelper.dio.post(
        '/api/v1/transfers/non-wallet/delayed',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print(
          'TransactionService: API response received: ${response.statusCode}');
      print('TransactionService: Response data: ${response.data}');

      // Map the response to our expected format
      if (response.data['success'] == true) {
        return {
          'status': 'success',
          'data': response.data['data'] ?? {},
        };
      } else {
        return {
          'status': 'error',
          'code': response.data['errorCode'] ?? 'UNKNOWN_ERROR',
          'message': response.data['message'] ?? 'Transaction failed',
        };
      }
    } catch (e) {
      print(
          'TransactionService: Error during delayed non-wallet transaction: $e');

      // Handle specific error cases
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          // Handle authentication errors
          if (e.response?.data != null &&
              e.response?.data['errorCode'] == 'ERR_651') {
            // Invalid PIN
            return {
              'status': 'error',
              'code': 'ERR_651',
              'message': 'The provided PIN is incorrect.'
            };
          } else {
            // Other authentication errors
            return {
              'status': 'error',
              'code': 'ERR_502',
              'message': 'Authentication failed. Please try logging in again.'
            };
          }
        } else if (e.response?.statusCode == 400) {
          // Handle bad request errors
          final errorCode = e.response?.data['errorCode'];
          final errorMessage = e.response?.data['message'];

          // Return the specific error code and message
          return {
            'status': 'error',
            'code': errorCode ?? 'ERR_900',
            'message': errorMessage ?? 'Invalid request parameters.'
          };
        } else if (e.response?.statusCode == 404) {
          // Handle not found errors
          final errorCode = e.response?.data['errorCode'];

          if (errorCode == 'ERR_926') {
            return {
              'status': 'error',
              'code': 'ERR_926',
              'message': 'Recipient details not found.'
            };
          } else if (errorCode == 'ERR_904') {
            return {
              'status': 'error',
              'code': 'ERR_904',
              'message': 'Sender wallet not found.'
            };
          } else {
            return {
              'status': 'error',
              'code': errorCode ?? 'ERR_900',
              'message': e.response?.data['message'] ?? 'Resource not found.'
            };
          }
        } else if (e.response?.statusCode == 403) {
          // Handle forbidden errors
          final errorCode = e.response?.data['errorCode'];

          if (errorCode == 'ERR_905') {
            return {
              'status': 'error',
              'code': 'ERR_905',
              'message': 'You don\'t have access to the specified wallet.'
            };
          } else {
            return {
              'status': 'error',
              'code': errorCode ?? 'ERR_900',
              'message': e.response?.data['message'] ?? 'Access denied.'
            };
          }
        } else if (e.response?.statusCode == 500) {
          // Handle server errors
          return {
            'status': 'error',
            'code': 'ERR_925',
            'message':
                'Delayed non-wallet transfer failed. Please try again later.'
          };
        }

        // If we have a response with error data, return it
        if (e.response?.data != null) {
          final errorCode = e.response?.data['errorCode'];
          final errorMessage = e.response?.data['message'];

          return {
            'status': 'error',
            'code': errorCode ?? 'ERR_900',
            'message':
                errorMessage ?? 'An error occurred during the transaction.'
          };
        }
      }

      // Default error response
      return {
        'status': 'error',
        'code': 'ERR_700',
        'message':
            'An unexpected error occurred during the delayed non-wallet transaction.'
      };
    }
  }
}
