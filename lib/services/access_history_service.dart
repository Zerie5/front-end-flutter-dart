import 'package:dio/dio.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class AccessHistoryService {
  static Future<List<Map<String, dynamic>>> getAccessHistory() async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) return [];

      final response = await THttpHelper.dio.get(
        '/api/access/history',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('Access History Response: ${response.data}'); // Debug log

      if (response.data != null &&
          response.data['status'] == 'success' &&
          response.data['data'] is List) {
        return List<Map<String, dynamic>>.from(
            response.data['data'].map((item) => {
                  'os': item['os'] ?? 'Unknown',
                  'deviceName': item['deviceName'] ?? 'Unknown Device',
                  'city': item['city'] ?? 'Unknown',
                  'country': item['country'] ?? 'Unknown',
                  'ipAddress': item['ipAddress'] ?? 'Unknown',
                  'accessTime':
                      item['accessTime'] ?? DateTime.now().toIso8601String(),
                }));
      }
      return [];
    } catch (e) {
      print('Access history error: $e');
      return [];
    }
  }
}
