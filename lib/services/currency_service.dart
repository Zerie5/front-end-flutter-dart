import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class CurrencyService extends GetxService {
  // Initialize the service
  Future<CurrencyService> init() async {
    return this;
  }

  // Method to fetch wallets from API with retry mechanism
  Future<Map<String, dynamic>?> fetchWallets(
      {int retryCount = 0, int maxRetries = 2}) async {
    try {
      // Get the token directly to verify it exists
      final token = await AuthStorage.getToken();
      if (token == null) {
        print('CurrencyService: No auth token available');
        return {
          'status': 'error',
          'code': 'ERR_AUTH',
          'message': 'Authentication token not available',
        };
      }

      print('CurrencyService: Using token: ${token.substring(0, 10)}...');
      print('CurrencyService: Attempt ${retryCount + 1} of ${maxRetries + 1}');

      // Use Dio with the interceptor that adds the token, but with a longer timeout
      final options = Options(
        receiveTimeout: const Duration(
            seconds: 60), // Longer timeout for this specific endpoint
      );

      // Use Dio with the interceptor that adds the token
      final response =
          await THttpHelper.dio.get('/api/user/wallets', options: options);

      print(
          'CurrencyService: Wallet API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return responseData;
        } else {
          print('CurrencyService: Invalid response format or error status');
          print('Response data: $responseData');
          return {
            'status': 'error',
            'code': 'ERR_INVALID_RESPONSE',
            'message': 'Invalid response format from server',
          };
        }
      } else {
        print(
            'CurrencyService: API request failed with status ${response.statusCode}');
        return {
          'status': 'error',
          'code': 'ERR_HTTP_${response.statusCode}',
          'message': 'Server returned status ${response.statusCode}',
        };
      }
    } catch (e) {
      print('CurrencyService: Error fetching wallets: $e');

      // Handle specific error types
      if (e is DioException) {
        // For timeout errors, retry if we haven't reached max retries
        if ((e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.receiveTimeout) &&
            retryCount < maxRetries) {
          print(
              'CurrencyService: Timeout error, retrying (${retryCount + 1}/$maxRetries)...');

          // Wait before retrying (exponential backoff)
          final waitTime = Duration(seconds: 2 * (retryCount + 1));
          await Future.delayed(waitTime);

          // Retry the request
          return fetchWallets(
              retryCount: retryCount + 1, maxRetries: maxRetries);
        }

        // Check for 401/403 errors which indicate invalid token
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return {
            'status': 'error',
            'code': 'ERR_502',
            'message': 'Invalid token',
          };
        }

        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            return {
              'status': 'error',
              'code': 'ERR_TIMEOUT',
              'message':
                  'Connection timed out after multiple attempts. The server might be experiencing high load.',
            };
          case DioExceptionType.badCertificate:
          case DioExceptionType.connectionError:
            return {
              'status': 'error',
              'code': 'ERR_CONNECTION',
              'message':
                  'Connection error. Please check your internet connection and try again.',
            };
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;

            // Special handling for 401/403 (should be caught above, but just in case)
            if (statusCode == 401 || statusCode == 403) {
              return {
                'status': 'error',
                'code': 'ERR_502',
                'message': 'Invalid token',
              };
            }

            return {
              'status': 'error',
              'code': 'ERR_HTTP_${statusCode ?? "UNKNOWN"}',
              'message':
                  'Server returned an error (${statusCode ?? "unknown status"}).',
            };
          default:
            return {
              'status': 'error',
              'code': 'ERR_NETWORK',
              'message': 'Network error: ${e.message}',
            };
        }
      }

      return {
        'status': 'error',
        'code': 'ERR_UNKNOWN',
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Method to fetch wallets with a provided token
  Future<Map<String, dynamic>?> fetchWalletsWithToken(String token,
      {int retryCount = 0, int maxRetries = 2}) async {
    try {
      if (token.isEmpty) {
        print('CurrencyService: Empty token provided');
        return {
          'status': 'error',
          'code': 'ERR_AUTH',
          'message': 'Empty authentication token provided',
        };
      }

      print(
          'CurrencyService: Fetching wallets with provided token: ${token.substring(0, 10)}...');
      print('CurrencyService: Attempt ${retryCount + 1} of ${maxRetries + 1}');

      // Use the provided token directly with a longer timeout
      final options = Options(
        receiveTimeout: const Duration(
            seconds: 60), // Longer timeout for this specific endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Make API call using THttpHelper.dio
      final response = await THttpHelper.dio.get(
        '/api/user/wallets',
        options: options,
      );

      print(
          'CurrencyService: Wallet API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return responseData;
        } else {
          print('CurrencyService: Invalid response format or error status');
          print('Response data: $responseData');
          return {
            'status': 'error',
            'code': 'ERR_INVALID_RESPONSE',
            'message': 'Invalid response format from server',
          };
        }
      } else {
        print(
            'CurrencyService: API request failed with status ${response.statusCode}');
        return {
          'status': 'error',
          'code': 'ERR_HTTP_${response.statusCode}',
          'message': 'Server returned status ${response.statusCode}',
        };
      }
    } catch (e) {
      print('CurrencyService: Error fetching wallets with token: $e');

      // Handle specific error types
      if (e is DioException) {
        // For timeout errors, retry if we haven't reached max retries
        if ((e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.receiveTimeout) &&
            retryCount < maxRetries) {
          print(
              'CurrencyService: Timeout error, retrying (${retryCount + 1}/$maxRetries)...');

          // Wait before retrying (exponential backoff)
          final waitTime = Duration(seconds: 2 * (retryCount + 1));
          await Future.delayed(waitTime);

          // Retry the request
          return fetchWalletsWithToken(token,
              retryCount: retryCount + 1, maxRetries: maxRetries);
        }

        // Check for 401/403 errors which indicate invalid token
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return {
            'status': 'error',
            'code': 'ERR_502',
            'message': 'Invalid token',
          };
        }

        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            return {
              'status': 'error',
              'code': 'ERR_TIMEOUT',
              'message':
                  'Connection timed out after multiple attempts. The server might be experiencing high load.',
            };
          case DioExceptionType.badCertificate:
          case DioExceptionType.connectionError:
            return {
              'status': 'error',
              'code': 'ERR_CONNECTION',
              'message':
                  'Connection error. Please check your internet connection and try again.',
            };
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;

            // Special handling for 401/403 (should be caught above, but just in case)
            if (statusCode == 401 || statusCode == 403) {
              return {
                'status': 'error',
                'code': 'ERR_502',
                'message': 'Invalid token',
              };
            }

            return {
              'status': 'error',
              'code': 'ERR_HTTP_${statusCode ?? "UNKNOWN"}',
              'message':
                  'Server returned an error (${statusCode ?? "unknown status"}).',
            };
          default:
            return {
              'status': 'error',
              'code': 'ERR_NETWORK',
              'message': 'Network error: ${e.message}',
            };
        }
      }

      return {
        'status': 'error',
        'code': 'ERR_UNKNOWN',
        'message': 'An unexpected error occurred',
      };
    }
  }
}
