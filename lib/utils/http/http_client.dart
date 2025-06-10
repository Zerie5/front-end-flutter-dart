import 'dart:convert';
import 'dart:async'; // Add this import for TimeoutException
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import 'package:lul/utils/http/http_interceptor.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/services/auth_service.dart';

class THttpHelper {
  // Make baseUrl public and static for access by NetworkManager
  static const String baseUrl =
      'https://lul-backend.onrender.com'; // Your base URL
  //static const String _username = 'admin'; // Backend username
  // static const String _password = 'lul';

  // Connection state
  static bool _isServerReachable = false;
  static int _connectionRetries = 0;
  static const int _maxConnectionRetries = 3;

  // Configure Dio with base URL and interceptor
  static final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15), // Reduced timeout
    receiveTimeout: const Duration(seconds: 15), // Reduced timeout
    sendTimeout: const Duration(seconds: 15), // Reduced timeout
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ))
    ..interceptors.add(AuthInterceptor());

  // Initialize connectivity - call this at app startup
  static Future<void> initConnectivity() async {
    // Try to connect at startup with multiple retries
    for (int i = 0; i < 3; i++) {
      final isReachable = await _checkServerReachable();
      if (isReachable) {
        _isServerReachable = true;
        print('Server connection established on attempt ${i + 1}');
        return;
      }
      await Future.delayed(const Duration(seconds: 2)); // Wait before retrying
    }
    print('Failed to establish initial server connection after 3 attempts');
  }

  // Check if server is reachable
  static Future<bool> _checkServerReachable() async {
    try {
      print('Checking server connectivity at: $baseUrl/api/connectivity/ping');

      // Try with Socket first for quick connectivity check
      try {
        final socket = await Socket.connect('192.168.100.79', 8080,
            timeout: const Duration(seconds: 3));
        await socket.close();
        print('Socket connection successful');
      } catch (e) {
        print('Socket connection failed: $e');
        return false;
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/connectivity/ping'),
            headers: getHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      print('Server response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Server connectivity check error: $e');
      return false;
    }
  }

  get context => null; // Backend password

  // Make getHeaders public and static for access by NetworkManager
  static Map<String, String> getHeaders() {
    //final String basicAuth =
//'Basic ${base64Encode(utf8.encode('$_username:$_password'))}';
    return {
      // 'Authorization': basicAuth,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // GET request with automatic retry
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      print('GET Request to: $baseUrl$endpoint'); // Debug URL

      // Ensure server is reachable before making request
      if (!_isServerReachable) {
        _isServerReachable = await _checkServerReachable();
        if (!_isServerReachable && _connectionRetries < _maxConnectionRetries) {
          _connectionRetries++;
          await Future.delayed(const Duration(seconds: 1));
          return get(endpoint); // Retry the request
        }
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Reset retry counter on success
      _connectionRetries = 0;
      _isServerReachable = true;

      return _handleResponse(response);
    } catch (e) {
      print('HTTP GET Error: $e');
      _isServerReachable = false;
      throw Exception('Failed to fetch data: $e');
    }
  }

  // POST request with automatic retry
  static Future<Map<String, dynamic>> post(
      String endpoint, dynamic data) async {
    try {
      print('POST Request to: $baseUrl/$endpoint');

      // Ensure server is reachable before making request
      if (!_isServerReachable) {
        _isServerReachable = await _checkServerReachable();
        if (!_isServerReachable && _connectionRetries < _maxConnectionRetries) {
          _connectionRetries++;
          await Future.delayed(const Duration(seconds: 1));
          return post(endpoint, data); // Retry the request
        }
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: getHeaders(),
            body: data != null ? json.encode(data) : null,
          )
          .timeout(const Duration(seconds: 10));

      // Reset retry counter on success
      _connectionRetries = 0;
      _isServerReachable = true;

      return _handleResponse(response);
    } catch (e) {
      print('HTTP POST Error: $e');
      _isServerReachable = false;
      throw Exception('Failed to post data: $e');
    }
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
      //print('Device type: Physical Android device');
      print('Testing backend at: $baseUrl');
      print('Network test started at: ${DateTime.now()}');

      // Try with Socket first for quick connectivity check
      try {
        final socket = await Socket.connect('192.168.100.79', 8080,
            timeout: const Duration(seconds: 3));
        await socket.close();
        print('Socket connection successful');
        _isServerReachable = true;
      } catch (e) {
        print('Socket connection failed: $e');
        _isServerReachable = false;
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/connectivity/ping'),
            headers: getHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      print('Response received: ${response.statusCode}');
      print('Response body: ${response.body}');
      _isServerReachable = true;
    } catch (e) {
      print('Connection error type: ${e.runtimeType}');
      print('Error details: $e');
      _isServerReachable = false;

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

      // Delegate to AuthService which handles business logic
      return await AuthService.registerUser(userData);
    } catch (e) {
      print('THttpHelper: Unexpected error: $e');
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
