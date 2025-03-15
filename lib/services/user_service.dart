import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:dio/dio.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      // Get the JWT token
      final token = await AuthStorage.getToken();
      if (token == null) {
        print('No token found');
        return {'status': 'error', 'code': 'ERR_501'};
      }

      // Make the API call using Dio with proper headers
      final response = await THttpHelper.dio.get(
        '/api/user/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Profile Response: ${response.data}'); // Debug print

      if (response.data['status'] == 'success') {
        return {
          'status': 'success',
          'data': {
            'userId': response.data['data']['userId'],
            'username': response.data['data']['username'],
            'email': response.data['data']['email'],
            'firstName': response.data['data']['firstName'],
            'lastName': response.data['data']['lastName'],
          }
        };
      }

      return {'status': 'error', 'code': response.data['code'] ?? 'ERR_501'};
    } catch (e) {
      print('Error fetching profile: $e');
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          return {'status': 'error', 'code': 'ERR_501'};
        }
      }
      return {'status': 'error', 'code': 'ERR_503'};
    }
  }
}
