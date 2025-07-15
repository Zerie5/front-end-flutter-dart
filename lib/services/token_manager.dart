import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../utils/tokens/auth_storage.dart';
import '../utils/http/http_client.dart';
import '../models/auth_models.dart';

/// Centralized token management service for dual token system
///
/// This service handles:
/// - Token expiry checking and automatic refresh
/// - Concurrent request handling during token refresh
/// - Token state management and notifications
/// - Background token refresh scheduling
class TokenManager extends GetxService {
  // Singleton pattern for token manager
  static TokenManager? _instance;
  static TokenManager get instance => _instance ??= TokenManager._();
  TokenManager._();

  // Token refresh state management
  final Rx<TokenRefreshState> refreshState = TokenRefreshState(
    status: TokenRefreshStatus.idle,
  ).obs;

  // Concurrent request handling
  Completer<bool>? _refreshCompleter;
  bool _isRefreshing = false;

  // Background refresh timer
  Timer? _backgroundRefreshTimer;

  // Token refresh lock to prevent multiple simultaneous refreshes
  bool _refreshLock = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    print('TokenManager: Initializing...');

    // Start background token monitoring
    _startBackgroundRefreshTimer();

    print('TokenManager: Initialized successfully');
  }

  @override
  void onClose() {
    _backgroundRefreshTimer?.cancel();
    super.onClose();
  }

  /// Initialize the token manager service
  Future<TokenManager> init() async {
    return this;
  }

  // ============================================================================
  // TOKEN EXPIRY & REFRESH CHECKING
  // ============================================================================

  /// Check if current token needs refresh (expires in < 2 minutes)
  Future<bool> shouldRefreshToken() async {
    try {
      return await AuthStorage.shouldRefreshToken();
    } catch (e) {
      print('TokenManager: Error checking token refresh need: $e');
      return true; // Default to refresh on error
    }
  }

  /// Check if current token is expired
  Future<bool> isTokenExpired() async {
    try {
      return await AuthStorage.isTokenExpired();
    } catch (e) {
      print('TokenManager: Error checking token expiry: $e');
      return true; // Default to expired on error
    }
  }

  /// Get current authentication state
  Future<AuthState> getAuthState() async {
    try {
      final stateMap = await AuthStorage.getAuthState();
      return AuthState.fromMap(stateMap);
    } catch (e) {
      print('TokenManager: Error getting auth state: $e');
      return AuthState(
        hasAccessToken: false,
        hasRefreshToken: false,
        hasSessionId: false,
        hasExpiry: false,
        needsRefresh: true,
        isExpired: true,
      );
    }
  }

  // ============================================================================
  // TOKEN REFRESH LOGIC
  // ============================================================================

  /// Refresh the access token using refresh token
  /// This method handles concurrent requests and prevents multiple simultaneous refreshes
  Future<bool> refreshToken() async {
    // If already refreshing, wait for existing refresh to complete
    if (_isRefreshing && _refreshCompleter != null) {
      print('TokenManager: Token refresh already in progress, waiting...');
      return await _refreshCompleter!.future;
    }

    // Acquire refresh lock
    if (_refreshLock) {
      print('TokenManager: Refresh locked, skipping');
      return false;
    }

    _refreshLock = true;
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      print('TokenManager: Starting token refresh...');
      refreshState.value = TokenRefreshState(
        status: TokenRefreshStatus.refreshing,
        message: 'Refreshing authentication token...',
      );

      // Get refresh token
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('TokenManager: No refresh token available');
        _setRefreshState(
            TokenRefreshStatus.needsLogin, 'No refresh token available');
        _refreshCompleter!.complete(false);
        return false;
      }

      // Make refresh API call
      final response = await _callRefreshAPI(refreshToken);

      if (response.isSuccess && response.token != null) {
        // Save new access token and expiry
        await AuthStorage.saveAuthTokens(
          accessToken: response.token!,
          expiresAt: response.expiresAt,
        );

        print('TokenManager: Token refresh successful');
        print(
            'TokenManager: New access token: ${response.token!.substring(0, 20)}...');
        print('TokenManager: New token expires at: ${response.expiresAt}');

        _setRefreshState(
            TokenRefreshStatus.success, 'Token refreshed successfully');
        _refreshCompleter!.complete(true);
        return true;
      } else {
        print('TokenManager: Token refresh failed');
        print('TokenManager: Response status: ${response.status}');
        print('TokenManager: Response message: ${response.message}');
        print('TokenManager: Response has token: ${response.token != null}');
        print('TokenManager: Response isSuccess: ${response.isSuccess}');

        _setRefreshState(TokenRefreshStatus.failed,
            response.message ?? 'Token refresh failed');

        // If refresh fails, user needs to login again
        if (response.status == 'error') {
          await _handleRefreshFailure();
        }

        _refreshCompleter!.complete(false);
        return false;
      }
    } catch (e) {
      print('TokenManager: Token refresh error: $e');
      _setRefreshState(TokenRefreshStatus.failed, 'Token refresh error: $e');

      // Handle different error types
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          await _handleRefreshFailure();
        }
      }

      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshLock = false;
      _refreshCompleter = null;
    }
  }

  /// Make the actual refresh API call
  Future<RefreshTokenResponse> _callRefreshAPI(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);

      final response = await THttpHelper.dio.post(
        '/api/auth/refresh',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('TokenManager: Refresh API response: ${response.statusCode}');
      print('TokenManager: Raw response data: ${response.data}');

      final refreshResponse = RefreshTokenResponse.fromJson(response.data);
      print('TokenManager: Parsed response: ${refreshResponse.toString()}');
      print('TokenManager: Response isSuccess: ${refreshResponse.isSuccess}');

      return refreshResponse;
    } catch (e) {
      print('TokenManager: Refresh API error: $e');
      return RefreshTokenResponse(
        status: 'error',
        message: 'Network error during token refresh',
      );
    }
  }

  /// Handle refresh failure by clearing tokens and redirecting to login
  Future<void> _handleRefreshFailure() async {
    print('TokenManager: Handling refresh failure - clearing all tokens');

    try {
      await AuthStorage.clearAuthTokens();
      _setRefreshState(TokenRefreshStatus.needsLogin, 'Please log in again');

      // Notify the app that user needs to login
      // The interceptor will handle the actual navigation
    } catch (e) {
      print('TokenManager: Error clearing tokens: $e');
    }
  }

  /// Set refresh state and notify observers
  void _setRefreshState(TokenRefreshStatus status, String? message) {
    refreshState.value = TokenRefreshState(
      status: status,
      message: message,
      lastRefresh: status == TokenRefreshStatus.success ? DateTime.now() : null,
    );
  }

  // ============================================================================
  // TOKEN VALIDATION FOR REQUESTS
  // ============================================================================

  /// Ensure token is valid before making a request
  /// This method is called by the interceptor before each API request
  Future<bool> ensureValidToken() async {
    try {
      print('TokenManager: Ensuring valid token...');

      // Check if we have an access token
      final hasToken = await AuthStorage.hasToken();
      if (!hasToken) {
        print('TokenManager: No access token found');
        return false;
      }

      // Check if token is expired
      final isExpired = await isTokenExpired();
      if (isExpired) {
        print('TokenManager: Token is expired, attempting refresh...');
        return await refreshToken();
      }

      // Check if token needs refresh (within 2 minutes of expiry)
      final needsRefresh = await shouldRefreshToken();
      if (needsRefresh) {
        print('TokenManager: Token needs refresh, refreshing proactively...');
        // Don't wait for refresh to complete, let the current request proceed
        // The refresh will happen in the background
        refreshToken();
      }

      return true;
    } catch (e) {
      print('TokenManager: Error ensuring valid token: $e');
      return false;
    }
  }

  // ============================================================================
  // BACKGROUND TOKEN MANAGEMENT
  // ============================================================================

  /// Start background timer to periodically check and refresh tokens
  void _startBackgroundRefreshTimer() {
    print(
        'TokenManager: Starting background refresh timer (10 minute intervals)');

    _backgroundRefreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (timer) => _performBackgroundRefresh(),
    );
  }

  /// Perform background token refresh check
  Future<void> _performBackgroundRefresh() async {
    try {
      print('TokenManager: Performing background token check...');

      final authState = await getAuthState();

      if (!authState.hasAccessToken) {
        print('TokenManager: No access token in background check');
        return;
      }

      if (authState.needsRefresh || authState.isExpired) {
        print('TokenManager: Background refresh needed');
        await refreshToken();
      } else {
        print('TokenManager: Token still valid in background check');
      }
    } catch (e) {
      print('TokenManager: Error in background refresh: $e');
    }
  }

  /// Handle app resume - check and refresh token if needed
  Future<void> onAppResume() async {
    try {
      print('TokenManager: App resumed, checking token status...');

      final authState = await getAuthState();

      if (authState.isAuthenticated) {
        if (authState.needsRefresh || authState.isExpired) {
          print('TokenManager: App resume - token needs refresh');
          await refreshToken();
        } else {
          print('TokenManager: App resume - token still valid');
        }
      } else {
        print('TokenManager: App resume - user not authenticated');
      }
    } catch (e) {
      print('TokenManager: Error handling app resume: $e');
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Clear all tokens and reset state
  Future<void> clearTokens() async {
    try {
      await AuthStorage.clearAuthTokens();
      refreshState.value = TokenRefreshState(status: TokenRefreshStatus.idle);
      print('TokenManager: All tokens cleared');
    } catch (e) {
      print('TokenManager: Error clearing tokens: $e');
    }
  }

  /// Get current access token (for use by interceptor)
  Future<String?> getCurrentAccessToken() async {
    try {
      return await AuthStorage.getToken();
    } catch (e) {
      print('TokenManager: Error getting current access token: $e');
      return null;
    }
  }

  /// Check if user is properly authenticated
  Future<bool> isAuthenticated() async {
    try {
      final authState = await getAuthState();
      return authState.isAuthenticated;
    } catch (e) {
      print('TokenManager: Error checking authentication: $e');
      return false;
    }
  }

  /// Get token refresh status for UI
  TokenRefreshState get currentRefreshState => refreshState.value;

  /// Check if currently refreshing token
  bool get isCurrentlyRefreshing => _isRefreshing;
}
