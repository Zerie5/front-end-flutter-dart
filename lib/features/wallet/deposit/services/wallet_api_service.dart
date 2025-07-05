import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../utils/tokens/auth_storage.dart';
import '../../../../utils/http/http_client.dart';
import '../models/wallet_models.dart';

class WalletApiService {
  static const String _walletOverviewEndpoint = '/api/v1/wallets/user';

  /// Fetch user wallets overview from API
  static Future<WalletOverviewResponse> getUserWallets() async {
    try {
      // Get user table ID and auth token from storage
      final userTableId = await AuthStorage.getUserTableId();
      final token = await AuthStorage.getToken();

      if (userTableId == null) {
        throw Exception('User table ID not found. Please log in again.');
      }

      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in again.');
      }

      print(
          'WalletApiService: Fetching wallets for user table ID: $userTableId');

      // Make API request
      final response = await http.get(
        Uri.parse(
            '${THttpHelper.baseUrl}$_walletOverviewEndpoint/$userTableId/overview'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('WalletApiService: Response status: ${response.statusCode}');
      print('WalletApiService: Response body: ${response.body}');

      // Parse response
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success response
        return WalletOverviewResponse.fromJson(responseData);
      } else {
        // Error response
        final errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Failed to fetch wallets';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('WalletApiService: Error fetching wallets: $e');

      // Handle specific error types
      if (e.toString().contains('No Internet') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
            'Unable to connect to the server. Please check your internet connection.');
      }

      rethrow;
    }
  }

  /// Get active wallets only (filtered)
  static Future<List<UserWallet>> getActiveWallets() async {
    try {
      final response = await getUserWallets();
      return response.data.wallets.where((wallet) => wallet.isActive).toList();
    } catch (e) {
      print('WalletApiService: Error fetching active wallets: $e');
      rethrow;
    }
  }

  /// Get wallets that can be funded
  static Future<List<UserWallet>> getFundableWallets() async {
    try {
      final response = await getUserWallets();
      return response.data.wallets
          .where((wallet) => wallet.canBeFunded)
          .toList();
    } catch (e) {
      print('WalletApiService: Error fetching fundable wallets: $e');
      rethrow;
    }
  }
}
