import 'package:lul/utils/http/http_client.dart';

class EmailService {
  static Future<bool> sendTestEmail() async {
    try {
      final response = await THttpHelper.dio.post(
        '/api/test/send-email',
        data: {'email': 'zerie8853@gmail.com'},
      );

      print('Email test response: ${response.data}'); // Debug log
      return response.data['status'] == 'success';
    } catch (e) {
      print('Email test error: $e');
      return false;
    }
  }
}
