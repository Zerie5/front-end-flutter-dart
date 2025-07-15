import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token'; // NEW
  static const String _sessionIdKey = 'session_id'; // NEW
  static const String _tokenExpiryKey = 'token_expiry'; // NEW
  static const String _pinKey = 'user_pin';
  static const String _userIdKey = 'user_id';
  static const String _userTableIdKey = 'user_table_id';
  static const String _userUniqueIdKey = 'user_unique_id';
  static const String _registrationStageKey = 'registration_stage';

  // ============================================================================
  // ENHANCED TOKEN MANAGEMENT (Dual Token System)
  // ============================================================================

  /// Save complete authentication tokens (enhanced for dual token system)
  static Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
    String? sessionId,
    DateTime? expiresAt,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save access token (existing field name for backward compatibility)
      await prefs.setString(_tokenKey, accessToken);

      // Save new dual token fields
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }

      if (sessionId != null) {
        await prefs.setString(_sessionIdKey, sessionId);
      }

      if (expiresAt != null) {
        await prefs.setString(_tokenExpiryKey, expiresAt.toIso8601String());
      }

      print('AuthStorage: Enhanced auth tokens saved successfully');
      print('AuthStorage: Access token: ${accessToken.substring(0, 10)}...');
      print(
          'AuthStorage: Refresh token: ${refreshToken != null ? "saved" : "not provided"}');
      print('AuthStorage: Session ID: ${sessionId ?? "not provided"}');
      print('AuthStorage: Expires at: ${expiresAt ?? "not provided"}');
    } catch (e) {
      print('AuthStorage: Error saving auth tokens: $e');
      throw Exception('Failed to save authentication tokens');
    }
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
      print('AuthStorage: Refresh token saved successfully');
    } catch (e) {
      print('AuthStorage: Error saving refresh token: $e');
      throw Exception('Failed to save refresh token');
    }
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      print(
          'AuthStorage: Refresh token check - ${refreshToken != null ? "exists" : "not found"}');
      return refreshToken;
    } catch (e) {
      print('AuthStorage: Error getting refresh token: $e');
      return null;
    }
  }

  /// Save session ID
  static Future<void> saveSessionId(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionIdKey, sessionId);
      print('AuthStorage: Session ID saved successfully');
    } catch (e) {
      print('AuthStorage: Error saving session ID: $e');
      throw Exception('Failed to save session ID');
    }
  }

  /// Get session ID
  static Future<String?> getSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString(_sessionIdKey);
      print(
          'AuthStorage: Session ID check - ${sessionId != null ? "exists" : "not found"}');
      return sessionId;
    } catch (e) {
      print('AuthStorage: Error getting session ID: $e');
      return null;
    }
  }

  /// Save token expiry time
  static Future<void> saveTokenExpiry(DateTime expiresAt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenExpiryKey, expiresAt.toIso8601String());
      print('AuthStorage: Token expiry saved: $expiresAt');
    } catch (e) {
      print('AuthStorage: Error saving token expiry: $e');
      throw Exception('Failed to save token expiry');
    }
  }

  /// Get token expiry time
  static Future<DateTime?> getTokenExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_tokenExpiryKey);
      if (expiryString != null) {
        final expiry = DateTime.parse(expiryString);
        print('AuthStorage: Token expires at: $expiry');
        return expiry;
      }
      print('AuthStorage: No token expiry found');
      return null;
    } catch (e) {
      print('AuthStorage: Error getting token expiry: $e');
      return null;
    }
  }

  /// Check if token needs refresh (expires in less than 2 minutes)
  static Future<bool> shouldRefreshToken() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) {
        print('AuthStorage: No expiry time - assuming token needs refresh');
        return true;
      }

      final now = DateTime.now();
      final timeUntilExpiry = expiry.difference(now);
      final shouldRefresh = timeUntilExpiry.inMinutes <= 2;

      print(
          'AuthStorage: Token expires in ${timeUntilExpiry.inMinutes} minutes - should refresh: $shouldRefresh');
      return shouldRefresh;
    } catch (e) {
      print('AuthStorage: Error checking token refresh need: $e');
      return true; // Default to refreshing on error
    }
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) {
        print('AuthStorage: No expiry time - assuming token is expired');
        return true;
      }

      final now = DateTime.now();
      final isExpired = now.isAfter(expiry);

      print('AuthStorage: Token expired: $isExpired');
      return isExpired;
    } catch (e) {
      print('AuthStorage: Error checking token expiry: $e');
      return true; // Default to expired on error
    }
  }

  /// Get complete authentication state
  static Future<Map<String, dynamic>> getAuthState() async {
    try {
      final accessToken = await getToken();
      final refreshToken = await getRefreshToken();
      final sessionId = await getSessionId();
      final expiry = await getTokenExpiry();
      final needsRefresh = await shouldRefreshToken();
      final isExpired = await isTokenExpired();

      return {
        'hasAccessToken': accessToken != null,
        'hasRefreshToken': refreshToken != null,
        'hasSessionId': sessionId != null,
        'hasExpiry': expiry != null,
        'needsRefresh': needsRefresh,
        'isExpired': isExpired,
        'expiresAt': expiry?.toIso8601String(),
      };
    } catch (e) {
      print('AuthStorage: Error getting auth state: $e');
      return {
        'hasAccessToken': false,
        'hasRefreshToken': false,
        'hasSessionId': false,
        'hasExpiry': false,
        'needsRefresh': true,
        'isExpired': true,
      };
    }
  }

  // ============================================================================
  // EXISTING TOKEN METHODS (Backward Compatibility)
  // ============================================================================

  // Save token (maintained for backward compatibility)
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('AuthStorage: Token saved successfully');
    } catch (e) {
      print('AuthStorage: Error saving token: $e');
      throw Exception('Failed to save token');
    }
  }

  // Get token (maintained for backward compatibility)
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print(
          'AuthStorage: Token check - ${token != null ? "exists" : "not found"}');
      return token;
    } catch (e) {
      print('AuthStorage: Error getting token: $e');
      return null;
    }
  }

  // Save PIN
  static Future<void> savePin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pinKey, pin);
      print('AuthStorage: PIN saved successfully');
    } catch (e) {
      print('AuthStorage: Error saving PIN: $e');
      throw Exception('Failed to save PIN');
    }
  }

  // Get PIN
  static Future<String?> getPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_pinKey);
    } catch (e) {
      print('AuthStorage: Error retrieving PIN: $e');
      return null;
    }
  }

  // Save userId
  static Future<void> saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      print('AuthStorage: UserId saved successfully');
    } catch (e) {
      print('AuthStorage: Error saving userId: $e');
      throw Exception('Failed to save userId');
    }
  }

  // Save user unique ID from backend
  static Future<void> saveUserUniqueId(String uniqueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userUniqueIdKey, uniqueId);
      print('AuthStorage: User unique ID saved successfully: $uniqueId');
    } catch (e) {
      print('AuthStorage: Error saving user unique ID: $e');
      throw Exception('Failed to save user unique ID');
    }
  }

  // Get user unique ID
  static Future<String?> getUserUniqueId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uniqueId = prefs.getString(_userUniqueIdKey);
      print('AuthStorage: User unique ID retrieved: $uniqueId');
      return uniqueId;
    } catch (e) {
      print('AuthStorage: Error retrieving user unique ID: $e');
      return null;
    }
  }

  // Get userId
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('AuthStorage: Error retrieving userId: $e');
      return null;
    }
  }

  // Save userTableId
  static Future<void> saveUserTableId(int userTableId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userTableIdKey, userTableId);
      print('AuthStorage: UserTableId saved successfully: $userTableId');
    } catch (e) {
      print('AuthStorage: Error saving userTableId: $e');
      throw Exception('Failed to save userTableId');
    }
  }

  // Get userTableId
  static Future<int?> getUserTableId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userTableId = prefs.getInt(_userTableIdKey);
      print('AuthStorage: UserTableId retrieved: $userTableId');
      return userTableId;
    } catch (e) {
      print('AuthStorage: Error retrieving userTableId: $e');
      return null;
    }
  }

  // ============================================================================
  // ENHANCED CLEAR METHODS
  // ============================================================================

  // Clear specific token
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      print('AuthStorage: Token cleared successfully');
    } catch (e) {
      print('AuthStorage: Error clearing token: $e');
      throw Exception('Failed to clear token');
    }
  }

  /// Clear all authentication tokens (enhanced for dual token system)
  static Future<void> clearAuthTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_sessionIdKey);
      await prefs.remove(_tokenExpiryKey);
      print('AuthStorage: All authentication tokens cleared successfully');
    } catch (e) {
      print('AuthStorage: Error clearing authentication tokens: $e');
      throw Exception('Failed to clear authentication tokens');
    }
  }

  // Clear ALL storage
  static Future<void> clearAllStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('AuthStorage: All storage cleared successfully');
    } catch (e) {
      print('AuthStorage: Error clearing all storage: $e');
      throw Exception('Failed to clear all storage');
    }
  }

  // Check if token exists
  static Future<bool> hasToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_tokenKey);
    } catch (e) {
      print('AuthStorage: Error checking token: $e');
      return false;
    }
  }

  /// Check if refresh token exists
  static Future<bool> hasRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_refreshTokenKey);
    } catch (e) {
      print('AuthStorage: Error checking refresh token: $e');
      return false;
    }
  }

  // Check if user unique ID exists
  static Future<bool> hasUserUniqueId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userUniqueIdKey);
    } catch (e) {
      print('AuthStorage: Error checking user unique ID: $e');
      return false;
    }
  }

  static Future<void> saveRegistrationStage(int stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_registrationStageKey, stage);
  }

  static Future<int> getRegistrationStage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_registrationStageKey) ?? 0;
  }

  static Future<void> clearRegistrationStage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registrationStageKey);
  }

  // Method to clear all auth data (enhanced for dual token system)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear all token-related data
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_tokenExpiryKey);
    // Clear user data
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTableIdKey);
    await prefs.remove(_userUniqueIdKey);
    await prefs.remove(_registrationStageKey);
    print('AuthStorage: All auth data cleared (enhanced)');
  }
}
