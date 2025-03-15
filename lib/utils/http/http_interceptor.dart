import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/navigation_menu.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Don't add token for registration
    if (!options.path.contains('/register')) {
      final token = await AuthStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('Network error: ${err.type}');

    // Handle authentication errors
    if (err.response?.statusCode == 401) {
      // Extract error details from response if available
      final Map<String, dynamic>? errorData = err.response?.data;
      final String errorCode = errorData?['code'] ?? 'ERR_401';
      final String errorMessage =
          errorData?['message'] ?? 'Authentication failed';

      // Handle different types of authentication errors
      if (errorMessage.contains('JWT token has expired')) {
        _handleTokenExpired();
      } else if (errorMessage.contains('Invalid JWT signature') ||
          errorMessage.contains('JWT token is malformed')) {
        _handleInvalidToken();
      } else if (errorCode == 'ERR_403' &&
          errorMessage.contains('Account is locked')) {
        _handleAccountLocked(errorMessage);
      } else {
        // Generic authentication error
        _handleAuthError(errorMessage);
      }
    }

    handler.next(err);
  }

  // Handle token expired error
  void _handleTokenExpired() {
    AuthStorage.clearAll(); // Clear stored tokens

    // Show error dialog and redirect to login
    LulLoaders.lulerrorDialog(
      title: 'Session Expired',
      message: 'Your session has expired. Please log in again.',
      onPressed: () {
        Get.offAll(() => const NavigationMenu());
      },
    );
  }

  // Handle invalid token error
  void _handleInvalidToken() {
    AuthStorage.clearAll(); // Clear stored tokens

    // Show error dialog and redirect to login
    LulLoaders.lulerrorDialog(
      title: 'Authentication Error',
      message: 'Your login session is invalid. Please log in again.',
      onPressed: () {
        Get.offAll(() => const NavigationMenu());
      },
    );
  }

  // Handle account locked error
  void _handleAccountLocked(String message) {
    AuthStorage.clearAll(); // Clear stored tokens

    // Show error dialog
    LulLoaders.lulerrorDialog(
      title: 'Account Locked',
      message:
          'Your account has been locked or disabled. Please contact support at support@lulpay.com for assistance.',
    );
  }

  // Handle generic authentication error
  void _handleAuthError(String message) {
    // Show error dialog
    LulLoaders.lulerrorDialog(
      title: 'Authentication Error',
      message: message,
    );
  }
}
