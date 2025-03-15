import 'dart:convert';
import 'dart:async'; // Add this import for TimeoutException
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'package:lul/utils/http/http_interceptor.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class THttpHelper {
  // Make baseUrl public and static for access by NetworkManager
  static const String baseUrl = 'http://192.168.100.79:8080'; // Your base URL
  static const String _username = 'admin'; // Backend username
  static const String _password = 'lul';

  // Configure Dio with base URL and interceptor
  static final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ))
    ..interceptors.add(AuthInterceptor());

  get context => null; // Backend password

  // Make getHeaders public and static for access by NetworkManager
  static Map<String, String> getHeaders() {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$_username:$_password'))}';
    return {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      print('GET Request to: $baseUrl$endpoint'); // Debug URL

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'), // Removed extra slash
        headers: getHeaders(), // Added await if getting token
      );

      print('Response status: ${response.statusCode}'); // Debug status
      print('Response body: ${response.body}'); // Debug response

      return _handleResponse(response);
    } catch (e) {
      print('HTTP GET Error: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
      String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: getHeaders(),
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // PUT request
  static Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: getHeaders(),
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: getHeaders(),
    );
    return _handleResponse(response);
  }

  // Response handler
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  static Future<void> testConnection() async {
    try {
      print('=== Network Test ===');
      print('Device type: Physical Android device');
      print('Testing backend at: $baseUrl');
      print('Network test started at: ${DateTime.now()}');

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/connectivity/ping'),
            headers: getHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      print('Response received: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Connection error type: ${e.runtimeType}');
      print('Error details: $e');

      // Additional network information
      print('\nDebug Info:');
      print('1. Check if backend is running on: $baseUrl');
      print('2. Ensure phone and backend are on same network');
      print('3. Verify backend is listening on all interfaces (0.0.0.0)');
    }
  }

  static Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> userData) async {
    try {
      print('THttpHelper: Sending registration data:');
      print('Username: ${userData['username']}');
      print('Email: ${userData['email']}');
      print('Device Info: ${userData['deviceInfo']}'); // Log device info

      final response = await dio.post(
        '/api/auth/register',
        data: userData, // Send the complete structured data
      );

      print('THttpHelper: Registration response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }

      return {'status': 'error', 'code': 'ERR_700'};
    } catch (e) {
      print('THttpHelper: Registration error: $e');
      return {'status': 'error', 'code': 'ERR_700'};
    }
  }

  // Create PIN (new endpoint)
  static Future<Map<String, dynamic>> createPin({required String pin}) async {
    try {
      final token = await AuthStorage.getToken();
      print('Token being used: $token');

      final response = await dio.post(
        '/api/user/pin/create', // New endpoint
        data: {'pin': pin},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      print('PIN creation response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error creating PIN: $e');
      if (e is DioException && e.response?.statusCode == 403) {
        return {
          'status': 'error',
          'message': 'Authentication failed. Please try logging in again.'
        };
      }
      return {'status': 'error', 'message': 'Failed to create PIN'};
    }
  }

  // Update PIN (new endpoint)
  static Future<Map<String, dynamic>> updatePin({required String pin}) async {
    try {
      final token = await AuthStorage.getToken();
      print('Token being used: $token');

      final response = await dio.post(
        '/api/user/pin/update', // New endpoint
        data: {'pin': pin},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      print('PIN update response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error updating PIN: $e');
      if (e is DioException && e.response?.statusCode == 403) {
        return {
          'status': 'error',
          'message': 'Authentication failed. Please try logging in again.'
        };
      }
      return {'status': 'error', 'message': 'Failed to update PIN'};
    }
  }
}
