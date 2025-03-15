import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:dio/dio.dart';

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
}
