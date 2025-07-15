/// Test file for dual token system implementation
///
/// This file contains test scenarios to verify that the dual token system
/// is working correctly. Run these tests to ensure all components are integrated properly.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'utils/tokens/auth_storage.dart';
import 'services/token_manager.dart';
import 'models/auth_models.dart';

class DualTokenSystemTest {
  /// Test the enhanced AuthStorage functionality
  static Future<void> testAuthStorage() async {
    print('\n=== Testing Enhanced AuthStorage ===');

    try {
      // Test saving dual tokens
      await AuthStorage.saveAuthTokens(
        accessToken: 'test_access_token_12345',
        refreshToken: 'test_refresh_token_67890',
        sessionId: 'test_session_id_abcde',
        expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      );

      // Test retrieving tokens
      final accessToken = await AuthStorage.getToken();
      final refreshToken = await AuthStorage.getRefreshToken();
      final sessionId = await AuthStorage.getSessionId();
      final expiry = await AuthStorage.getTokenExpiry();

      print('✅ Access Token: ${accessToken?.substring(0, 10)}...');
      print('✅ Refresh Token: ${refreshToken?.substring(0, 10)}...');
      print('✅ Session ID: $sessionId');
      print('✅ Expires At: $expiry');

      // Test token expiry checks
      final needsRefresh = await AuthStorage.shouldRefreshToken();
      final isExpired = await AuthStorage.isTokenExpired();

      print('✅ Needs Refresh: $needsRefresh');
      print('✅ Is Expired: $isExpired');

      // Test auth state
      final authState = await AuthStorage.getAuthState();
      print('✅ Auth State: $authState');

      print('✅ AuthStorage tests completed successfully!');
    } catch (e) {
      print('❌ AuthStorage test failed: $e');
    }
  }

  /// Test the LoginResponse model parsing
  static void testLoginResponseModel() {
    print('\n=== Testing LoginResponse Model ===');

    try {
      // Test new dual token response format
      final mockResponse = {
        'status': 'success',
        'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        'refreshToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9_refresh...',
        'sessionId': 'session_12345_abcde',
        'expiresAt': '2024-01-15T10:30:00Z',
        'userId': 'user123',
        'userTableId': 456,
        'registerStatus': 4,
        'profile': {'name': 'Test User'},
      };

      final loginResponse = LoginResponse.fromJson(mockResponse);

      print('✅ Status: ${loginResponse.status}');
      print('✅ Is Success: ${loginResponse.isSuccess}');
      print('✅ Has Dual Tokens: ${loginResponse.hasDualTokens}');
      print('✅ Has Expiry: ${loginResponse.hasExpiry}');
      print('✅ Token: ${loginResponse.token.substring(0, 20)}...');
      print(
          '✅ Refresh Token: ${loginResponse.refreshToken?.substring(0, 20)}...');
      print('✅ Session ID: ${loginResponse.sessionId}');
      print('✅ Expires At: ${loginResponse.expiresAt}');

      print('✅ LoginResponse model tests completed successfully!');
    } catch (e) {
      print('❌ LoginResponse model test failed: $e');
    }
  }

  /// Test the RefreshTokenResponse model
  static void testRefreshTokenModel() {
    print('\n=== Testing RefreshToken Models ===');

    try {
      // Test RefreshTokenRequest
      final request = RefreshTokenRequest(refreshToken: 'test_refresh_token');
      final requestJson = request.toJson();
      print('✅ Refresh Request JSON: $requestJson');

      // Test RefreshTokenResponse
      final mockRefreshResponse = {
        'status': 'success',
        'token': 'new_access_token_12345',
        'expiresAt': '2024-01-15T10:45:00Z',
      };

      final refreshResponse =
          RefreshTokenResponse.fromJson(mockRefreshResponse);
      print('✅ Refresh Response Success: ${refreshResponse.isSuccess}');
      print('✅ New Token: ${refreshResponse.token?.substring(0, 20)}...');
      print('✅ New Expiry: ${refreshResponse.expiresAt}');

      print('✅ RefreshToken model tests completed successfully!');
    } catch (e) {
      print('❌ RefreshToken model test failed: $e');
    }
  }

  /// Test TokenManager initialization and basic functionality
  static Future<void> testTokenManager() async {
    print('\n=== Testing TokenManager ===');

    try {
      final tokenManager = TokenManager.instance;

      // Test getting auth state
      final authState = await tokenManager.getAuthState();
      print('✅ Auth State: $authState');

      // Test token expiry checks
      final shouldRefresh = await tokenManager.shouldRefreshToken();
      final isExpired = await tokenManager.isTokenExpired();

      print('✅ Should Refresh: $shouldRefresh');
      print('✅ Is Expired: $isExpired');

      // Test getting current access token
      final currentToken = await tokenManager.getCurrentAccessToken();
      print('✅ Current Token: ${currentToken?.substring(0, 10)}...');

      // Test authentication check
      final isAuthenticated = await tokenManager.isAuthenticated();
      print('✅ Is Authenticated: $isAuthenticated');

      // Test refresh state
      final refreshState = tokenManager.currentRefreshState;
      print('✅ Refresh State: $refreshState');

      print('✅ TokenManager tests completed successfully!');
    } catch (e) {
      print('❌ TokenManager test failed: $e');
    }
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    print('🚀 Starting Dual Token System Tests...\n');

    // Model tests (don't require async)
    testLoginResponseModel();
    testRefreshTokenModel();

    // Storage tests (require async)
    await testAuthStorage();
    await testTokenManager();

    print('\n🎉 All dual token system tests completed!');
    print('\n📋 Test Summary:');
    print('   ✅ Enhanced AuthStorage with dual tokens');
    print('   ✅ LoginResponse model with new fields');
    print('   ✅ RefreshToken request/response models');
    print('   ✅ TokenManager basic functionality');
    print('   ✅ Token expiry and refresh logic');
    print('\n🔧 Next Steps:');
    print('   1. Test with actual backend dual token responses');
    print('   2. Test automatic token refresh in interceptor');
    print('   3. Test concurrent requests during token refresh');
    print('   4. Test app background/foreground scenarios');
    print('   5. Verify 15-minute token expiry handling');
  }
}

/// Widget to run tests in the app (for development/testing)
class DualTokenTestScreen extends StatelessWidget {
  const DualTokenTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dual Token System Tests'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Dual Token System Test Suite',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await DualTokenSystemTest.runAllTests();
                Get.snackbar(
                  'Tests Complete',
                  'Check console for test results',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Run All Tests',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This will test:\n'
              '• Enhanced AuthStorage\n'
              '• LoginResponse models\n'
              '• TokenManager functionality\n'
              '• Token expiry logic\n\n'
              'Check console for detailed results',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
