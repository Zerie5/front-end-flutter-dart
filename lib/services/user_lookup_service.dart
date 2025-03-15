import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/features/wallet/contacts/models/contact_model.dart';

class UserLookupService extends GetxService {
  // Initialize the service
  Future<UserLookupService> init() async {
    return this;
  }

  // Method to lookup a user by workId
  Future<Map<String, dynamic>> lookupUser(String workId) async {
    try {
      // Get the token directly
      final String? token = await AuthStorage.getToken();

      if (token == null) {
        print('UserLookupService: No auth token available');
        return {
          'status': 'error',
          'code': 'ERR_AUTH',
          'message': 'Authentication token not available',
        };
      }

      print(
          'UserLookupService: Using token for lookup: ${token.substring(0, 10)}...');

      // Use Dio directly with the token
      final response = await THttpHelper.dio.get(
        '/api/user/lookup/$workId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print(
          'UserLookupService: User lookup response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          // Create a ContactModel from the response data
          final userData = responseData['data'];
          final fullName = '${userData['firstName']} ${userData['lastName']}';

          final contact = ContactModel(
            id: userData['workId'],
            fullName: fullName.trim(),
            telephone: userData['phoneNumber'] ?? '',
            email: userData['email'] ?? '',
          );

          return {
            'status': 'success',
            'contact': contact,
          };
        } else {
          // Return the error information from the API
          return {
            'status': 'error',
            'code': responseData['code'] ?? 'ERR_UNKNOWN',
            'message': responseData['message'] ?? 'Unknown error occurred',
          };
        }
      } else {
        print(
            'UserLookupService: API request failed with status ${response.statusCode}');
        print('UserLookupService: Response data: ${response.data}');

        return {
          'status': 'error',
          'code': 'ERR_${response.statusCode}',
          'message': 'Server returned status ${response.statusCode}',
        };
      }
    } catch (e) {
      // Handle Dio exceptions specifically
      if (e is DioException) {
        // Handle 404 Not Found as a user not found error
        if (e.response?.statusCode == 404) {
          print('UserLookupService: User not found (404) for ID: $workId');
          return {
            'status': 'error',
            'code':
                'ERR_501', // Using your existing error code for user not found
            'message': 'User with ID $workId was not found',
          };
        }

        // Handle 500 Internal Server Error
        if (e.response?.statusCode == 500) {
          print('UserLookupService: Server error (500) for ID: $workId');
          return {
            'status': 'error',
            'code': 'ERR_500',
            'message':
                'The server encountered an error processing your request',
          };
        }

        // Handle other status codes
        if (e.response?.statusCode != null) {
          print(
              'UserLookupService: Error ${e.response?.statusCode} for ID: $workId');
          return {
            'status': 'error',
            'code': 'ERR_${e.response?.statusCode}',
            'message': 'Error ${e.response?.statusCode}: ${e.message}',
          };
        }
      }

      print('UserLookupService: Error looking up user: $e');
      return {
        'status': 'error',
        'code': 'ERR_UNKNOWN',
        'message': 'An unexpected error occurred',
      };
    }
  }
}
