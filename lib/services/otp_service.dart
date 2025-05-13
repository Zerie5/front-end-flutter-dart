import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class OtpService {
  static Future<Map<String, dynamic>> verifyOtp(String otpCode) async {
    try {
      final token = await AuthStorage.getToken();

      final response = await THttpHelper.dio.post(
        '/api/v1/otp/verify',
        data: {'otpCode': otpCode},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.data;
    } catch (e) {
      print('OTP verification error: $e');
      if (e is DioException && e.response?.data != null) {
        return e.response!.data;
      }
      return {'status': 'error', 'code': 'ERR_806'};
    }
  }

  static Future<Map<String, dynamic>> resendOtp() async {
    try {
      final token = await AuthStorage.getToken();
      print('OtpService.resendOtp token: $token');

      if (token == null || token.isEmpty) {
        print('OtpService: No token available for OTP resend');
        return {'status': 'error', 'code': 'ERR_AUTH_REQUIRED'};
      }

      // Try using direct HTTP call instead of Dio to see if that resolves the issue
      try {
        print('OtpService: Attempting direct HTTP call to resend OTP');
        final httpClient = Dio(BaseOptions(
          baseUrl: THttpHelper.baseUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ));

        final httpResponse = await httpClient.post(
          '/api/v1/otp/resend',
        );

        print('OtpService: Direct HTTP response: ${httpResponse.data}');
        return httpResponse.data;
      } catch (directHttpError) {
        print('OtpService: Direct HTTP call failed: $directHttpError');

        // If direct HTTP call fails, attempt with Dio as a fallback
        print('OtpService: Falling back to Dio for OTP resend');
        final response = await THttpHelper.dio.post(
          '/api/v1/otp/resend',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            contentType: 'application/json',
          ),
        );

        print('OtpService: Dio fallback response: ${response.data}');
        return response.data;
      }
    } catch (e) {
      print('OTP resend error details: $e');
      if (e is DioException) {
        print('DioException type: ${e.type}');
        print('DioException message: ${e.message}');
        print('DioException response status: ${e.response?.statusCode}');
        print('DioException response data: ${e.response?.data}');

        if (e.response?.data != null) {
          return e.response!.data;
        }
      }

      // Return a user-friendly error response
      return {
        'status': 'error',
        'code': 'ERR_807',
        'message': 'Failed to resend OTP. Please try again.'
      };
    }
  }
}
