import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/utils/device/device_info_helper.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_controller.dart';
import 'package:dio/dio.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      // Get device information
      final deviceInfo = await DeviceInfoHelper.getLoginDeviceInfo();

      // Get FCM token
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      final fcmToken = await firebaseMessaging.getToken();

      final loginData = {
        'email': email,
        'password': password,
        'deviceInfo': {
          'deviceId': deviceInfo['deviceId'],
          'deviceName': deviceInfo['deviceName'],
          'os': deviceInfo['os']
        },
        'fcmToken': fcmToken // Include FCM token in login request
      };

      print('Login data being sent: ${loginData.toString()}');

      final response = await THttpHelper.dio.post(
        '/api/auth/login',
        data: loginData,
      );

      print('Raw Response: ${response.data}');
      print('Response Type: ${response.data.runtimeType}');

      if (response.data is Map) {
        (response.data as Map).forEach((key, value) {
          print('Key: $key, Value: $value (${value?.runtimeType})');
        });
      }

      if (response.data['status'] == 'success') {
        final String token = response.data['token'];

        print('Login Success - Token: $token');
        print('Login Success - UserId: ${response.data['userId']}');
        print(
            'Login Success - Register Status: ${response.data['registerStatus']}');
        print('Login Success - Profile: ${response.data['profile']}');

        // Save token to storage
        await AuthStorage.saveToken(token);
        await AuthStorage.saveUserId(response.data['userId']);

        // Save user unique ID if available in the response
        String? userUniqueId;
        if (response.data['profile'] != null &&
            response.data['profile']['userId'] != null) {
          userUniqueId = response.data['profile']['userId'];
          print('Login Success - Saving user unique ID: $userUniqueId');
          await AuthStorage.saveUserUniqueId(userUniqueId!);
        } else if (response.data['uniqueId'] != null) {
          // Alternative field name that might be used
          userUniqueId = response.data['uniqueId'];
          print(
              'Login Success - Saving user unique ID (from uniqueId field): $userUniqueId');
          await AuthStorage.saveUserUniqueId(userUniqueId!);
        } else {
          print('Warning: No user unique ID found in login response');
        }

        await AuthStorage.saveRegistrationStage(
            response.data['registerStatus'] ?? 4);

        // Load currency data after successful login
        try {
          if (Get.isRegistered<CurrencyController>()) {
            print('Loading currency data after successful login');
            final currencyController = Get.find<CurrencyController>();

            // Use the new method to load currency data
            currencyController.loadInitialData().then((_) {
              print('Currency data loaded after login');
            }).catchError((error) {
              print('Error loading currency data: $error');
            });
          } else {
            print(
                'CurrencyController not registered yet, cannot load currency data');
          }
        } catch (e) {
          print('Error initiating currency data load: $e');
        }

        return {
          'status': 'success',
          'token': token,
          'userId': response.data['userId'],
          'userUniqueId': userUniqueId,
          'profile': response.data['profile'],
          'registerStatus': response.data['registerStatus']
        };
      }

      // Handle specific error codes from the server
      print('Login Failed - Code: ${response.data['code']}');
      print('Login Failed - Message: ${response.data['message']}');

      return {
        'status': 'error',
        'code': response.data['code'] ?? 'ERR_UNKNOWN',
        'message': response.data['message'] ?? 'An unknown error occurred'
      };
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Stack trace: $stackTrace');

      // Check if this is a DioException with a response
      if (e is DioException && e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        print('DioException with status code: $statusCode');
        print('Response data: $responseData');

        // Handle 400 Bad Request - typically for invalid credentials
        if (statusCode == 400) {
          // Try to extract error code and message from response
          String errorCode = 'ERR_401'; // Default to authentication error
          String errorMessage = 'Invalid email or password';

          if (responseData is Map) {
            errorCode = responseData['code'] ?? errorCode;
            errorMessage = responseData['message'] ?? errorMessage;

            // If the message is LOGIN_FAILED, provide a more user-friendly message
            if (errorMessage == 'LOGIN_FAILED') {
              errorMessage = 'Invalid email or password';
            }
          }

          return {
            'status': 'error',
            'code': errorCode,
            'message': errorMessage
          };
        }

        // Handle other status codes if needed
        if (statusCode == 401) {
          return {
            'status': 'error',
            'code': 'ERR_401',
            'message': 'Authentication failed. Please log in again.'
          };
        }

        if (statusCode == 403) {
          return {
            'status': 'error',
            'code': 'ERR_403',
            'message':
                'Your account has been locked or disabled. Please contact support.'
          };
        }
      }

      // Check for connection errors
      if (e.toString().contains('No Internet') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        return {
          'status': 'error',
          'code': 'ERR_CONNECTION',
          'message':
              'Unable to connect to the server. Please check your internet connection.'
        };
      }

      return {
        'status': 'error',
        'code': 'ERR_UNKNOWN',
        'message': 'An unexpected error occurred. Please try again later.'
      };
    }
  }

  static Future<Map<String, dynamic>> signup(
      Map<String, dynamic> userData) async {
    try {
      // Add device info to userData
      final deviceInfo = await DeviceInfoHelper.getLoginDeviceInfo();
      userData['deviceId'] = deviceInfo['deviceId'];
      userData['deviceName'] = deviceInfo['deviceName'];
      userData['os'] = deviceInfo['os'];

      final response = await THttpHelper.dio.post(
        '/api/auth/register',
        data: userData,
      );

      if (response.data['status'] == 'success') {
        // Save token if provided in registration
        if (response.data['token'] != null) {
          await AuthStorage.saveToken(response.data['token']);
        }
        if (response.data['userId'] != null) {
          await AuthStorage.saveUserId(response.data['userId']);
        }
        // Set initial registration stage
        await AuthStorage.saveRegistrationStage(1);
      }

      return response.data;
    } catch (e) {
      print('Signup error: $e');
      return {'status': 'error', 'code': 'ERR_700'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      // Clear all authentication data
      await AuthStorage.clearAll();
      print('Logout: All auth data cleared');

      return {'status': 'success'};
    } catch (e) {
      print('Logout error: $e');
      return {'status': 'error', 'code': 'ERR_700'};
    }
  }

  // Added method to handle user registration with proper error handling
  static Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> userData) async {
    try {
      print('AuthService: Registering user: ${userData['username']}');

      // Make the API call
      final response = await THttpHelper.dio.post(
        '/api/auth/register',
        data: userData,
      );

      print('AuthService: Registration response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If registration successful and contains a token, save it
        if (response.data['token'] != null) {
          await AuthStorage.saveToken(response.data['token']);
        }

        // Save registration stage if provided, otherwise use default (2 for OTP verification needed)
        if (response.data['registerStatus'] != null) {
          final registerStatus =
              int.parse(response.data['registerStatus'].toString());
          print('AuthService: Registration stage set to $registerStatus');
          await AuthStorage.saveRegistrationStage(registerStatus);
        } else {
          print(
              'AuthService: No registration stage in response, using default (2)');
          await AuthStorage.saveRegistrationStage(2);
        }

        return response.data;
      }

      return {'status': 'error', 'code': 'ERR_700'};
    } catch (e) {
      print('AuthService: Registration error: $e');

      // Extract error details from DioException
      if (e is DioException && e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        // If we have a proper error response from the server
        if (responseData != null && responseData is Map) {
          final errorCode = responseData['code'] ?? 'ERR_700';
          final errorMessage = responseData['message'] ?? 'Registration failed';

          print(
              'AuthService: Server returned error: $errorCode - $errorMessage');
          return {
            'status': 'error',
            'code': errorCode,
            'message': errorMessage
          };
        }

        print('AuthService: HTTP error with status code: $statusCode');
        return {
          'status': 'error',
          'code': 'ERR_700',
          'message': 'Registration failed'
        };
      }

      return {
        'status': 'error',
        'code': 'ERR_700',
        'message': 'Registration failed'
      };
    }
  }
}
