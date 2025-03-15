import 'package:lul/utils/http/http_client.dart';

class SmsService {
  static Future<bool> sendTestSms() async {
    try {
      final response = await THttpHelper.dio.post(
        '/api/test/send-sms',
        data: {'phoneNumber': '+256703241464'},
      );

      print('SMS test response: ${response.data}'); // Debug log
      return response.data['status'] == 'success';
    } catch (e) {
      print('SMS test error: $e');
      return false;
    }
  }
}
