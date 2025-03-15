import 'package:dio/dio.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class PinService {
  static Future<Map<String, dynamic>> createPin(String pin) async {
    try {
      print('PinService: Starting PIN creation');
      final token = await AuthStorage.getToken();

      if (token == null) {
        print('PinService: No token found');
        return {'status': 'error', 'code': 'ERR_502'};
      }

      return await THttpHelper.createPin(pin: pin);
    } catch (e) {
      print('PinService: Creation error - $e');
      return {'status': 'error', 'code': 'ERR_700'};
    }
  }

  static Future<Map<String, dynamic>> updatePin(String pin) async {
    try {
      print('PinService: Starting PIN update');
      final token = await AuthStorage.getToken();

      if (token == null) {
        print('PinService: No token found');
        return {'status': 'error', 'code': 'ERR_502'};
      }

      return await THttpHelper.updatePin(pin: pin);
    } catch (e) {
      print('PinService: Update error - $e');
      return {'status': 'error', 'code': 'ERR_700'};
    }
  }

  static Future<Map<String, dynamic>> verifyPin(String pin) async {
    try {
      print('PinService: Starting PIN verification');
      final token = await AuthStorage.getToken();

      if (token == null) {
        print('PinService: No token found');
        return {'status': 'error', 'code': 'ERR_502'};
      }

      final response = await THttpHelper.dio.post(
        '/api/user/pin/verify',
        data: {'pin': pin},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true,
        ),
      );

      print('PinService: Verification response status ${response.statusCode}');
      print('PinService: Response data ${response.data}');

      // Success case
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return {
          'status': 'success',
          'data': {'isValid': response.data['data']['isValid'] ?? false}
        };
      }

      // Handle specific error codes from the backend
      if (response.statusCode == 401) {
        // Token is invalid or expired
        if (response.data['code'] == 'ERR_502') {
          await AuthStorage.clearToken();
          return {
            'status': 'error',
            'code': 'ERR_502',
            'message': 'Session expired. Please login again.'
          };
        }
      }

      // Handle specific error codes regardless of HTTP status
      final errorCode = response.data['code'];
      if (errorCode != null) {
        switch (errorCode) {
          case 'ERR_651':
            return {
              'status': 'error',
              'code': 'ERR_651',
              'message': 'Incorrect PIN. Please try again.'
            };
          case 'ERR_652':
            return {
              'status': 'error',
              'code': 'ERR_652',
              'message': 'PIN not set. Please set up your PIN first.'
            };
          case 'ERR_655':
            return {
              'status': 'error',
              'code': 'ERR_655',
              'message': 'Connection issue. Please try again later.'
            };
        }
      }

      // Default error case
      return {
        'status': 'error',
        'code': response.data['code'] ?? 'ERR_700',
        'message': response.data['message'] ??
            'An error occurred during PIN verification.'
      };
    } catch (e) {
      print('PinService: Verification error - $e');
      // Handle network errors
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          return {
            'status': 'error',
            'code': 'ERR_655',
            'message':
                'Connection issue. Please check your internet and try again.'
          };
        }
      }
      return {
        'status': 'error',
        'code': 'ERR_700',
        'message': 'An unexpected error occurred.'
      };
    }
  }
}
