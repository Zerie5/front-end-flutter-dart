import 'package:dio/dio.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await AuthStorage.getToken();
      print('ProfileService: Checking token');

      if (token == null) {
        print('ProfileService: No token found');
        return {'status': 'pending', 'message': 'No token'};
      }

      try {
        final response = await THttpHelper.dio.get(
          '/api/user/profile',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            validateStatus: (status) => true,
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        );

        print('ProfileService: Response status ${response.statusCode}');
        print('ProfileService: Raw response data: ${response.data}');

        if (response.statusCode == 200) {
          if (response.data['status'] == 'success' &&
              response.data['data'] != null) {
            return response.data;
          }
          if (response.data['userId'] != null) {
            return {'status': 'success', 'data': response.data};
          }
        }

        switch (response.statusCode) {
          case 401:
            print('ProfileService: Token expired or invalid');
            await AuthStorage.clearToken();
            Get.offAll(() => LoginScreen());
            return {'status': 'error', 'code': 'ERR_502'};
          default:
            return {'status': 'error', 'code': 'ERR_700'};
        }
      } catch (e) {
        print('ProfileService: Request error - $e');
        return {'status': 'error', 'code': 'ERR_700'};
      }
    } catch (e) {
      print('ProfileService: General error - $e');
      return {'status': 'error', 'code': 'ERR_700'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> profileData) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        return {'status': 'error', 'code': 'ERR_502'};
      }

      final response = await THttpHelper.dio.put(
        '/api/user/profile',
        data: profileData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true,
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      switch (response.statusCode) {
        case 200:
          return response.data;
        case 409:
          final errorData = response.data;
          return {
            'status': 'error',
            'code': errorData['code'] ?? 'ERR_700',
            'message': errorData['message']
          };
        case 400:
          final errorData = response.data;
          return {
            'status': 'error',
            'code': errorData['code'] ?? 'ERR_708',
            'message': errorData['message']
          };
        case 401:
          return {'status': 'error', 'code': 'ERR_502'};
        case 404:
          return {'status': 'error', 'code': 'ERR_501'};
        case 500:
          return {'status': 'error', 'code': 'ERR_700'};
        default:
          return {'status': 'error', 'code': 'ERR_700'};
      }
    } catch (e) {
      print('Error updating profile: $e');
      return {'status': 'error', 'code': 'ERR_700'};
    }
  }

  static Future<Map<String, dynamic>> updateFCMToken(String token) async {
    try {
      final deviceId = await _getDeviceId();
      final authToken = await AuthStorage.getToken();

      if (authToken == null) {
        return {'status': 'error', 'message': 'No auth token available'};
      }

      // Prepare request body
      final body = {
        'token': token,
        'deviceId': deviceId,
      };

      // Use the Dio instance from THttpHelper
      final response = await THttpHelper.dio.post(
        '/api/notifications/fcm-token',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'status': 'success'};
      } else {
        return {
          'status': 'error',
          'message':
              'Failed to update FCM token. Status: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    const deviceIdKey = 'device_id';
    String? deviceId = prefs.getString(deviceIdKey);

    return deviceId ?? '';
  }
}
