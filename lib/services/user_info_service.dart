import 'package:dio/dio.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class UserInfoService {
  /// Retrieves the user's unique ID from SharedPreferences
  /// Returns null if not found
  static Future<String?> getUserUniqueIdFromStorage() async {
    try {
      final uniqueId = await AuthStorage.getUserUniqueId();
      print('UserInfoService: Retrieved unique ID from storage: $uniqueId');
      return uniqueId;
    } catch (e) {
      print('UserInfoService: Error retrieving unique ID from storage: $e');
      return null;
    }
  }

  /// Fetches the full user profile from the backend API
  /// Returns the user profile data if successful, null otherwise
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      // Get the JWT token
      final token = await AuthStorage.getToken();
      if (token == null) {
        print('UserInfoService: No token found for API request');
        return null;
      }

      print('UserInfoService: Making API request to /api/user-info/current');

      // Make the API call using Dio with proper headers
      final response = await THttpHelper.dio.get(
        '/api/user-info/current',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      print('UserInfoService: API response status: ${response.statusCode}');
      print('UserInfoService: API response data: ${response.data}');

      // Check if the response has the expected format
      if (response.data['status'] == 'SUCCESS' &&
          response.data['userInfo'] != null) {
        final userInfo = response.data['userInfo'];
        print('UserInfoService: Successfully retrieved user profile');

        // If the response contains a workerId, save it for future use
        if (userInfo['workerId'] != null) {
          final workerId = userInfo['workerId'];
          print('UserInfoService: Found workerId in profile: $workerId');
          await AuthStorage.saveUserUniqueId(workerId);
        }

        return userInfo;
      }

      print('UserInfoService: Could not find userInfo in response');
      return null;
    } catch (e) {
      print('UserInfoService: Error fetching user profile from API: $e');
      if (e is DioException) {
        print('UserInfoService: DioError type: ${e.type}');
        print('UserInfoService: DioError message: ${e.message}');
        if (e.response != null) {
          print('UserInfoService: Response status: ${e.response?.statusCode}');
          print('UserInfoService: Response data: ${e.response?.data}');
        }
      }
      return null;
    }
  }

  /// Fetches the worker ID from the dedicated endpoint
  /// Returns the worker ID if successful, null otherwise
  static Future<String?> getWorkerIdFromApi() async {
    try {
      // Get the JWT token
      final token = await AuthStorage.getToken();
      if (token == null) {
        print('UserInfoService: No token found for API request');
        return null;
      }

      print('UserInfoService: Making API request to /api/user-info/worker-id');

      // Make the API call using Dio with proper headers
      final response = await THttpHelper.dio.get(
        '/api/user-info/worker-id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      print('UserInfoService: API response status: ${response.statusCode}');
      print('UserInfoService: API response data: ${response.data}');

      // Check if the response has the expected format
      if (response.data['status'] == 'SUCCESS' &&
          response.data['workerId'] != null) {
        final workerId = response.data['workerId'];
        print('UserInfoService: Found workerId in response: $workerId');

        // Save the worker ID to storage for future use
        await AuthStorage.saveUserUniqueId(workerId);

        return workerId;
      }

      print('UserInfoService: Could not find workerId in response');
      return null;
    } catch (e) {
      print('UserInfoService: Error fetching worker ID from API: $e');
      if (e is DioException) {
        print('UserInfoService: DioError type: ${e.type}');
        print('UserInfoService: DioError message: ${e.message}');
        if (e.response != null) {
          print('UserInfoService: Response status: ${e.response?.statusCode}');
          print('UserInfoService: Response data: ${e.response?.data}');
        }
      }
      return null;
    }
  }

  /// Gets the user's unique ID, first trying from storage, then from API if needed
  /// Returns null if both methods fail
  static Future<String?> getUserUniqueId() async {
    // First try to get from storage
    final storageId = await getUserUniqueIdFromStorage();
    if (storageId != null && storageId.isNotEmpty) {
      return storageId;
    }

    // If not in storage, try to get from the worker ID API
    print(
        'UserInfoService: Unique ID not found in storage, trying worker ID API...');
    return await getWorkerIdFromApi();
  }

  /// Alias for getWorkerIdFromApi for backward compatibility
  static Future<String?> getUserUniqueIdFromApi() async {
    return await getWorkerIdFromApi();
  }
}
