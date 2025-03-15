import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _pinKey = 'user_pin';
  static const String _userIdKey = 'user_id';
  static const String _userUniqueIdKey = 'user_unique_id';
  static const String _registrationStageKey = 'registration_stage';

  // Save token
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

  // Get token
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

  // Method to clear all auth data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userUniqueIdKey);
    await prefs.remove(_registrationStageKey);
  }
}
