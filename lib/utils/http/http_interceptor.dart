import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/navigation_menu.dart';
import 'package:lul/services/token_manager.dart';

/// Enhanced authentication interceptor for dual token system
///
/// This interceptor handles:
/// - Automatic token validation and refresh before requests
/// - 401 error handling with automatic retry after token refresh
/// - Concurrent request handling during token refresh
/// - Improved error messaging and user experience
class AuthInterceptor extends Interceptor {
  // Track if we're currently showing an auth error to prevent multiple dialogs
  static bool _isShowingAuthError = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('AuthInterceptor: Processing request to ${options.path}');

    // Skip token handling for registration and refresh endpoints
    if (_shouldSkipTokenHandling(options.path)) {
      print('AuthInterceptor: Skipping token handling for ${options.path}');
      return handler.next(options);
    }

    try {
      // Get TokenManager instance
      final tokenManager = TokenManager.instance;

      // Ensure we have a valid token before making the request
      final hasValidToken = await tokenManager.ensureValidToken();

      if (!hasValidToken) {
        print('AuthInterceptor: No valid token available');
        // Let the request proceed without token - the server will return 401
        // which will be handled in onError
        return handler.next(options);
      }

      // Get current access token and add to headers
      final token = await tokenManager.getCurrentAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        print('AuthInterceptor: Added token to request headers');
      }
    } catch (e) {
      print('AuthInterceptor: Error in onRequest: $e');
      // Continue with request even if token handling fails
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    print(
        'AuthInterceptor: Network error: ${err.type}, Status: ${err.response?.statusCode}');

    // Handle authentication errors (401)
    if (err.response?.statusCode == 401) {
      print('AuthInterceptor: Handling 401 authentication error');

      // Skip token refresh for refresh endpoint to prevent infinite loop
      if (err.requestOptions.path.contains('/api/auth/refresh')) {
        print(
            'AuthInterceptor: 401 on refresh endpoint - redirecting to login');
        await _handleAuthenticationFailure(err);
        return handler.next(err);
      }

      // Try to refresh token and retry the original request
      final retrySuccess = await _handleTokenRefreshAndRetry(err, handler);
      if (retrySuccess) {
        return; // Request was retried successfully
      }
    }

    // Handle other authentication-related errors
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      await _handleAuthenticationError(err);
    }

    handler.next(err);
  }

  /// Check if token handling should be skipped for this endpoint
  bool _shouldSkipTokenHandling(String path) {
    final skipPaths = [
      '/register',
      '/api/auth/register',
      '/api/auth/login',
      '/api/auth/refresh', // Skip for refresh to prevent loops
    ];

    return skipPaths.any((skipPath) => path.contains(skipPath));
  }

  /// Handle token refresh and retry original request
  Future<bool> _handleTokenRefreshAndRetry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      print('AuthInterceptor: Attempting token refresh and retry...');

      final tokenManager = TokenManager.instance;

      // Attempt to refresh the token
      final refreshSuccess = await tokenManager.refreshToken();

      if (refreshSuccess) {
        print(
            'AuthInterceptor: Token refresh successful, retrying original request');

        // Get the new token and retry the original request
        final newToken = await tokenManager.getCurrentAccessToken();
        if (newToken != null && newToken.isNotEmpty) {
          // Update the request headers with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          // Retry the original request
          try {
            final dio = Dio();
            final response = await dio.fetch(err.requestOptions);
            handler.resolve(response);
            return true;
          } catch (retryError) {
            print('AuthInterceptor: Retry failed: $retryError');
            return false;
          }
        }
      } else {
        print('AuthInterceptor: Token refresh failed');
        await _handleAuthenticationFailure(err);
        return false;
      }
    } catch (e) {
      print('AuthInterceptor: Error during token refresh and retry: $e');
      await _handleAuthenticationFailure(err);
      return false;
    }

    return false;
  }

  /// Handle authentication failure (redirect to login)
  Future<void> _handleAuthenticationFailure(DioException err) async {
    if (_isShowingAuthError) {
      print('AuthInterceptor: Auth error dialog already showing, skipping');
      return;
    }

    try {
      print('AuthInterceptor: Handling authentication failure');

      // Clear all authentication data
      final tokenManager = TokenManager.instance;
      await tokenManager.clearTokens();
      await AuthStorage.clearAll();

      // Extract error details
      final Map<String, dynamic>? errorData = err.response?.data;
      final String errorMessage = errorData?['message'] ??
          'Your session has expired. Please log in again.';

      _isShowingAuthError = true;

      // Show error dialog and redirect to login
      LulLoaders.lulerrorDialog(
        title: 'Session Expired',
        message: errorMessage,
        onPressed: () {
          _isShowingAuthError = false;
          Get.offAll(() => const NavigationMenu());
        },
      );
    } catch (e) {
      print('AuthInterceptor: Error handling authentication failure: $e');
      _isShowingAuthError = false;
    }
  }

  /// Handle various authentication errors
  Future<void> _handleAuthenticationError(DioException err) async {
    if (_isShowingAuthError) {
      return;
    }

    // Extract error details from response if available
    final Map<String, dynamic>? errorData = err.response?.data;
    final String errorCode = errorData?['code'] ?? 'ERR_401';
    final String errorMessage =
        errorData?['message'] ?? 'Authentication failed';

    print(
        'AuthInterceptor: Handling auth error - Code: $errorCode, Message: $errorMessage');

    // Handle different types of authentication errors
    if (errorMessage.contains('JWT token has expired')) {
      await _handleTokenExpired();
    } else if (errorMessage.contains('Invalid JWT signature') ||
        errorMessage.contains('JWT token is malformed')) {
      await _handleInvalidToken();
    } else if (errorCode == 'ERR_403' &&
        errorMessage.contains('Account is locked')) {
      await _handleAccountLocked(errorMessage);
    } else {
      // Generic authentication error
      await _handleGenericAuthError(errorMessage);
    }
  }

  /// Handle token expired error
  Future<void> _handleTokenExpired() async {
    if (_isShowingAuthError) return;

    print('AuthInterceptor: Handling token expired');

    try {
      final tokenManager = TokenManager.instance;
      await tokenManager.clearTokens();
      await AuthStorage.clearAll();

      _isShowingAuthError = true;

      // Show error dialog and redirect to login
      LulLoaders.lulerrorDialog(
        title: 'Session Expired',
        message: 'Your session has expired. Please log in again.',
        onPressed: () {
          _isShowingAuthError = false;
          Get.offAll(() => const NavigationMenu());
        },
      );
    } catch (e) {
      print('AuthInterceptor: Error handling token expired: $e');
      _isShowingAuthError = false;
    }
  }

  /// Handle invalid token error
  Future<void> _handleInvalidToken() async {
    if (_isShowingAuthError) return;

    print('AuthInterceptor: Handling invalid token');

    try {
      final tokenManager = TokenManager.instance;
      await tokenManager.clearTokens();
      await AuthStorage.clearAll();

      _isShowingAuthError = true;

      // Show error dialog and redirect to login
      LulLoaders.lulerrorDialog(
        title: 'Authentication Error',
        message: 'Your login session is invalid. Please log in again.',
        onPressed: () {
          _isShowingAuthError = false;
          Get.offAll(() => const NavigationMenu());
        },
      );
    } catch (e) {
      print('AuthInterceptor: Error handling invalid token: $e');
      _isShowingAuthError = false;
    }
  }

  /// Handle account locked error
  Future<void> _handleAccountLocked(String message) async {
    if (_isShowingAuthError) return;

    print('AuthInterceptor: Handling account locked');

    try {
      final tokenManager = TokenManager.instance;
      await tokenManager.clearTokens();
      await AuthStorage.clearAll();

      _isShowingAuthError = true;

      // Show error dialog
      LulLoaders.lulerrorDialog(
        title: 'Account Locked',
        message:
            'Your account has been locked or disabled. Please contact support at support@lulpay.com for assistance.',
        onPressed: () {
          _isShowingAuthError = false;
        },
      );
    } catch (e) {
      print('AuthInterceptor: Error handling account locked: $e');
      _isShowingAuthError = false;
    }
  }

  /// Handle generic authentication error
  Future<void> _handleGenericAuthError(String message) async {
    if (_isShowingAuthError) return;

    print('AuthInterceptor: Handling generic auth error: $message');

    _isShowingAuthError = true;

    // Show error dialog
    LulLoaders.lulerrorDialog(
      title: 'Authentication Error',
      message: message,
      onPressed: () {
        _isShowingAuthError = false;
      },
    );
  }
}
