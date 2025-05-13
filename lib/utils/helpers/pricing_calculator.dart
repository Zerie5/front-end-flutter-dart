import 'package:lul/utils/http/http_client.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:dio/dio.dart';

class TPricingCalculator {
  /// -- Calculate Price based on tax and shipping
  static double calculateTotalPrice(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;

    double shippingCost = getShippingCost(location);

    double totalPrice = productPrice + taxAmount + shippingCost;
    return totalPrice;
  }

  /// -- Calculate shipping cost
  static String calculateShippingCost(double productPrice, String location) {
    double shippingCost = getShippingCost(location);
    return shippingCost.toStringAsFixed(2);
  }

  /// -- Calculate tax
  static String calculateTax(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  static double getTaxRateForLocation(String location) {
    // Lookup the tax rate for the given location from a tax rate database or API.
    // Return the appropriate tax rate.
    return 0.10; // Example tax rate of 10%
  }

  static double getShippingCost(String location) {
    // Lookup the shipping cost for the given location using a shipping rate API.
    // Calculate the shipping cost based on various factors like distance, weight, etc.
    return 5.00; // Example shipping cost of $5
  }

  /// -- Calculate transfer fee (2% of send amount)
  static double calculateTransferFee(double sendAmount) {
    return sendAmount * 0.02;
  }

  /// -- Calculate total transfer amount including fee
  static double calculateTotalTransferAmount(double sendAmount) {
    double fee = calculateTransferFee(sendAmount);
    return sendAmount + fee;
  }

  /// -- Calculate non-wallet remittance fee using API configuration
  /// This method fetches the fee configuration from the API and calculates the fee
  /// based on percentage and fixed amount
  static Future<double> calculateNonWalletRemittanceFee(
      double sendAmount, int walletTypeId,
      {bool isDelayed = false}) async {
    try {
      // Get the fee configuration from the API
      final feeConfig = await _getFeeConfiguration(walletTypeId);

      // The API returns percentage as a decimal value (e.g., 1.00 for 1%)
      // so we divide by 100 to get the actual multiplier
      double percentageMultiplier = feeConfig['percentage'] / 100;

      // For delayed transfers, use a fixed 2.8% rate without the fixed fee
      if (isDelayed) {
        percentageMultiplier = 0.028; // 2.8%
      }

      double percentageFee = sendAmount * percentageMultiplier;
      double fixedFee = isDelayed ? 0.0 : feeConfig['fixedAmount'];
      double minimumFee = isDelayed ? 0.0 : feeConfig['minimumFee'];

      print('TPricingCalculator: Fee calculation details:');
      print(' - Base amount: $sendAmount');
      print(' - Is delayed transfer: $isDelayed');
      print(
          ' - Percentage: ${isDelayed ? "2.8%" : feeConfig['percentage'] + "%"}');
      print(' - Percentage multiplier: $percentageMultiplier');
      print(' - Percentage fee: $percentageFee');
      if (!isDelayed) {
        print(' - Fixed fee: $fixedFee');
        print(' - Minimum fee: $minimumFee');
      }

      // Total fee is the sum of percentage fee and fixed fee
      double totalFee = percentageFee + fixedFee;

      // Ensure the fee is at least the minimum fee
      if (!isDelayed && totalFee < minimumFee) {
        totalFee = minimumFee;
        print(' - Applied minimum fee: $totalFee');
      } else {
        print(' - Total fee: $totalFee');
      }

      return totalFee;
    } catch (e) {
      print('Error calculating non-wallet remittance fee: $e');
      // Fallback to default calculation in case of error
      // For delayed transfers, use 2.8%
      if (isDelayed) {
        return sendAmount * 0.028;
      }
      // Otherwise use the standard 2% fee
      return calculateTransferFee(sendAmount);
    }
  }

  /// -- Calculate total amount for non-wallet transfer including the fee
  static Future<double> calculateTotalNonWalletTransferAmount(
      double sendAmount, int walletTypeId,
      {bool isDelayed = false}) async {
    final fee = await calculateNonWalletRemittanceFee(sendAmount, walletTypeId,
        isDelayed: isDelayed);
    return sendAmount + fee;
  }

  /// -- Private method to fetch fee configuration from API
  static Future<Map<String, dynamic>> _getFeeConfiguration(
      int walletTypeId) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      // Create the request data
      final Map<String, dynamic> requestData = {
        'feeTypeId': 4, // 4 is for REMITTANCE_FEE
        'walletTypeId': walletTypeId,
      };

      // Make the API request
      final response = await THttpHelper.dio.post(
        '/api/v1/fees/configuration',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Process the response
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get fee configuration');
      }
    } catch (e) {
      print('Error fetching fee configuration: $e');
      // Return default values if the API call fails
      return {'percentage': 1.00, 'fixedAmount': 500.00, 'minimumFee': 500.00};
    }
  }

  // /// -- Sum all cart values and return total amount
  // static double calculateCartTotal(CartModel cart) {
  //   return cart.items.map((e) => e.price).fold(0, (previousPrice, currentPrice) => previousPrice + (currentPrice ?? 0));
  // }
}
