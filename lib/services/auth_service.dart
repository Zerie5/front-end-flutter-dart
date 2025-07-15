import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/utils/device/device_info_helper.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_controller.dart';
import 'package:dio/dio.dart';
import 'package:lul/models/auth_models.dart';

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

      // Parse the enhanced login response
      final loginResponse = LoginResponse.fromJson(response.data);
      print('Login Response: $loginResponse');

      if (loginResponse.isSuccess) {
        print('Login Success - Processing dual token response');
        print(
            'Login Success - Has dual tokens: ${loginResponse.hasDualTokens}');
        print('Login Success - Has expiry: ${loginResponse.hasExpiry}');

        // Save enhanced authentication tokens using new method
        await AuthStorage.saveAuthTokens(
          accessToken: loginResponse.token,
          refreshToken: loginResponse.refreshToken,
          sessionId: loginResponse.sessionId,
          expiresAt: loginResponse.expiresAt,
        );

        // Save user data (backward compatibility)
        if (loginResponse.userId != null) {
          await AuthStorage.saveUserId(loginResponse.userId!);
        }

        if (loginResponse.userTableId != null) {
          await AuthStorage.saveUserTableId(loginResponse.userTableId!);
          print(
              'Login Success - UserTableId saved: ${loginResponse.userTableId}');
        }

        // Save user unique ID with enhanced logic
        String? userUniqueId = loginResponse.userUniqueId;
        if (userUniqueId == null && loginResponse.profile != null) {
          // Try to extract from profile
          userUniqueId = loginResponse.profile!['userId']?.toString();
        }

        if (userUniqueId != null && userUniqueId.isNotEmpty) {
          await AuthStorage.saveUserUniqueId(userUniqueId);
          print('Login Success - User unique ID saved: $userUniqueId');
        } else {
          print('Warning: No user unique ID found in login response');
        }

        // Save registration stage
        await AuthStorage.saveRegistrationStage(
            loginResponse.registerStatus ?? 4);

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
          'token': loginResponse.token,
          'userId': loginResponse.userId,
          'userTableId': loginResponse.userTableId,
          'userUniqueId': userUniqueId,
          'profile': loginResponse.profile,
          'registerStatus': loginResponse.registerStatus,
          // NEW: Additional dual token fields for backward compatibility
          'refreshToken': loginResponse.refreshToken,
          'sessionId': loginResponse.sessionId,
          'expiresAt': loginResponse.expiresAt?.toIso8601String(),
        };
      }

      // Handle specific error codes from the server
      print('Login Failed - Code: ${loginResponse.code}');
      print('Login Failed - Message: ${loginResponse.message}');

      return {
        'status': 'error',
        'code': loginResponse.code ?? 'ERR_UNKNOWN',
        'message': loginResponse.message ?? 'An unknown error occurred'
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
        if (response.data['userTableId'] != null) {
          await AuthStorage.saveUserTableId(response.data['userTableId']);
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
      // Get the current token before clearing storage
      final token = await AuthStorage.getToken();

      if (token != null) {
        // Call backend logout endpoint
        try {
          final response = await THttpHelper.dio.post(
            '/api/auth/logout',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          );

          print('Logout API Response: ${response.data}');

          if (response.data['status'] == 'success') {
            // Backend logout successful, now clear local storage
            await AuthStorage.clearAll();
            print('Logout: Backend session terminated and local data cleared');

            return {
              'status': 'success',
              'message': response.data['message'] ?? 'Successfully logged out'
            };
          } else {
            // Backend logout failed, but still clear local storage
            await AuthStorage.clearAll();
            print('Logout: Backend logout failed, but local data cleared');

            return {
              'status': 'warning',
              'message':
                  'Logged out locally, but server session may still be active'
            };
          }
        } catch (e) {
          print('Logout API Error: $e');
          // If backend call fails, still clear local storage
          await AuthStorage.clearAll();

          return {
            'status': 'warning',
            'message': 'Logged out locally, but could not reach server'
          };
        }
      } else {
        // No token found, just clear any remaining local data
        await AuthStorage.clearAll();
        print('Logout: No token found, cleared local data');

        return {'status': 'success', 'message': 'Successfully logged out'};
      }
    } catch (e) {
      print('Logout error: $e');
      // Fallback: clear local storage even if there's an error
      try {
        await AuthStorage.clearAll();
      } catch (storageError) {
        print('Error clearing storage: $storageError');
      }

      return {'status': 'error', 'message': 'Logout completed with errors'};
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

  // ============================================================================
  // ENHANCED DUAL TOKEN METHODS
  // ============================================================================

  /// NEW: Logout from all sessions (enhanced dual token method)
  static Future<Map<String, dynamic>> logoutAll() async {
    try {
      // Get the current token before clearing storage
      final token = await AuthStorage.getToken();

      if (token != null) {
        // Call backend logout-all endpoint
        try {
          final response = await THttpHelper.dio.post(
            '/api/auth/logout-all',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          );

          print('LogoutAll API Response: ${response.data}');

          final logoutResponse = LogoutAllResponse.fromJson(response.data);

          if (logoutResponse.isSuccess) {
            // Backend logout-all successful, now clear local storage
            await AuthStorage.clearAll();
            print('LogoutAll: All sessions terminated and local data cleared');

            return {'status': 'success', 'message': logoutResponse.message};
          } else {
            // Backend logout-all failed, but still clear local storage
            await AuthStorage.clearAll();
            print(
                'LogoutAll: Backend logout-all failed, but local data cleared');

            return {
              'status': 'warning',
              'message':
                  'Logged out locally, but some server sessions may still be active'
            };
          }
        } catch (e) {
          print('LogoutAll API Error: $e');
          // If backend call fails, still clear local storage
          await AuthStorage.clearAll();

          return {
            'status': 'warning',
            'message': 'Logged out locally, but could not reach server'
          };
        }
      } else {
        // No token found, just clear any remaining local data
        await AuthStorage.clearAll();
        print('LogoutAll: No token found, cleared local data');

        return {'status': 'success', 'message': 'Successfully logged out'};
      }
    } catch (e) {
      print('LogoutAll error: $e');
      // Fallback: clear local storage even if there's an error
      try {
        await AuthStorage.clearAll();
      } catch (storageError) {
        print('Error clearing storage: $storageError');
      }

      return {'status': 'error', 'message': 'Logout completed with errors'};
    }
  }

  /// NEW: Refresh access token using refresh token
  static Future<Map<String, dynamic>> refreshTokenMethod() async {
    try {
      // Get refresh token from storage
      final refreshToken = await AuthStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        print('RefreshToken: No refresh token available');
        return {
          'status': 'error',
          'code': 'ERR_NO_REFRESH_TOKEN',
          'message': 'No refresh token available'
        };
      }

      // Create refresh request
      final request = RefreshTokenRequest(refreshToken: refreshToken);

      // Call refresh API endpoint
      final response = await THttpHelper.dio.post(
        '/api/auth/refresh',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('RefreshToken API Response: ${response.data}');

      final refreshResponse = RefreshTokenResponse.fromJson(response.data);

      if (refreshResponse.isSuccess && refreshResponse.token != null) {
        // Save new access token and expiry
        await AuthStorage.saveAuthTokens(
          accessToken: refreshResponse.token!,
          expiresAt: refreshResponse.expiresAt,
        );

        print('RefreshToken: Token refreshed successfully');
        print(
            'RefreshToken: New token expires at: ${refreshResponse.expiresAt}');

        return {
          'status': 'success',
          'token': refreshResponse.token,
          'expiresAt': refreshResponse.expiresAt?.toIso8601String(),
          'message': 'Token refreshed successfully'
        };
      } else {
        print('RefreshToken: Token refresh failed: ${refreshResponse.message}');
        return {
          'status': 'error',
          'code': refreshResponse.code ?? 'ERR_REFRESH_FAILED',
          'message': refreshResponse.message ?? 'Token refresh failed'
        };
      }
    } catch (e) {
      print('RefreshToken error: $e');

      // Handle different error types
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          return {
            'status': 'error',
            'code': 'ERR_REFRESH_EXPIRED',
            'message': 'Refresh token expired. Please log in again.'
          };
        } else if (e.response?.statusCode == 400) {
          return {
            'status': 'error',
            'code': 'ERR_INVALID_REFRESH_TOKEN',
            'message': 'Invalid refresh token. Please log in again.'
          };
        }
      }

      return {
        'status': 'error',
        'code': 'ERR_REFRESH_UNKNOWN',
        'message': 'An unexpected error occurred during token refresh'
      };
    }
  }
}
