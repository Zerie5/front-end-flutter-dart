import 'dart:math';
import '../features/wallet/deposit/models/deposit_models.dart';

class MockDepositService {
  // Simulate processing delays
  static const Duration _processingDelay = Duration(seconds: 3);

  // Mock deposit limits
  static const double minDepositAmount = 10.0;
  static const double maxDepositAmount = 5000.0;
  static const double dailyDepositLimit = 10000.0;

  /// Process a mock card deposit
  static Future<DepositResult> processCardDeposit(DepositModel deposit) async {
    print(
        'MockDepositService: Processing card deposit for \$${deposit.amount}');

    // Validate deposit amount
    if (deposit.amount < minDepositAmount) {
      return DepositResult(
        success: false,
        message:
            'Minimum deposit amount is \$${minDepositAmount.toStringAsFixed(2)}',
        deposit: deposit.copyWith(
          status: DepositStatus.failed,
          errorMessage: 'Amount too low',
        ),
      );
    }

    if (deposit.amount > maxDepositAmount) {
      return DepositResult(
        success: false,
        message:
            'Maximum deposit amount is \$${maxDepositAmount.toStringAsFixed(2)}',
        deposit: deposit.copyWith(
          status: DepositStatus.failed,
          errorMessage: 'Amount too high',
        ),
      );
    }

    // Simulate processing delay
    await Future.delayed(_processingDelay);

    // Mock card validation based on card number patterns
    final cardNumber = deposit.cardDetails?.cardNumber ?? '';
    final mockResult = _getMockCardResult(cardNumber);

    if (mockResult.success) {
      final successDeposit = deposit.copyWith(
        depositId: _generateDepositId(),
        transactionId: _generateTransactionId(),
        status: DepositStatus.completed,
        createdAt: DateTime.now(),
        fee: _calculateFee(deposit.amount, PaymentMethodType.card),
      );

      print(
          'MockDepositService: Card deposit successful - ID: ${successDeposit.depositId}');

      return DepositResult(
        success: true,
        message: 'Deposit successful',
        deposit: successDeposit,
      );
    } else {
      final failedDeposit = deposit.copyWith(
        status: DepositStatus.failed,
        errorMessage: mockResult.message,
        createdAt: DateTime.now(),
      );

      return DepositResult(
        success: false,
        message: mockResult.message,
        deposit: failedDeposit,
      );
    }
  }

  /// Process a mock bank deposit
  static Future<DepositResult> processBankDeposit(DepositModel deposit) async {
    print(
        'MockDepositService: Processing bank deposit for \$${deposit.amount}');

    // Validate deposit amount
    if (deposit.amount < minDepositAmount) {
      return DepositResult(
        success: false,
        message:
            'Minimum deposit amount is \$${minDepositAmount.toStringAsFixed(2)}',
        deposit: deposit.copyWith(
          status: DepositStatus.failed,
          errorMessage: 'Amount too low',
        ),
      );
    }

    if (deposit.amount > maxDepositAmount) {
      return DepositResult(
        success: false,
        message:
            'Maximum deposit amount is \$${maxDepositAmount.toStringAsFixed(2)}',
        deposit: deposit.copyWith(
          status: DepositStatus.failed,
          errorMessage: 'Amount too high',
        ),
      );
    }

    // Simulate processing delay
    await Future.delayed(_processingDelay);

    // Mock bank validation - most succeed, some fail randomly
    final random = Random();
    final shouldSucceed = random.nextDouble() > 0.1; // 90% success rate

    if (shouldSucceed) {
      final successDeposit = deposit.copyWith(
        depositId: _generateDepositId(),
        transactionId: _generateTransactionId(),
        status: DepositStatus.completed,
        createdAt: DateTime.now(),
        fee: _calculateFee(deposit.amount, PaymentMethodType.bank),
      );

      print(
          'MockDepositService: Bank deposit successful - ID: ${successDeposit.depositId}');

      return DepositResult(
        success: true,
        message: 'Deposit successful',
        deposit: successDeposit,
      );
    } else {
      final failedDeposit = deposit.copyWith(
        status: DepositStatus.failed,
        errorMessage: 'Bank transfer failed',
        createdAt: DateTime.now(),
      );

      return DepositResult(
        success: false,
        message: 'Bank transfer failed. Please verify your account details.',
        deposit: failedDeposit,
      );
    }
  }

  /// Get deposit limits
  static DepositLimits getDepositLimits() {
    return DepositLimits(
      minAmount: minDepositAmount,
      maxAmount: maxDepositAmount,
      dailyLimit: dailyDepositLimit,
    );
  }

  /// Calculate processing fee based on payment method
  static double _calculateFee(double amount, PaymentMethodType paymentMethod) {
    switch (paymentMethod) {
      case PaymentMethodType.card:
        // Card fees: 2.9% + $0.30
        return (amount * 0.029) + 0.30;
      case PaymentMethodType.bank:
        // Bank transfer fees: $1.50 flat fee
        return 1.50;
    }
  }

  /// Generate mock deposit ID
  static String _generateDepositId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'DEP_${timestamp}_$random';
  }

  /// Generate mock transaction ID
  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return 'TXN_${timestamp}_$random';
  }

  /// Mock card validation logic based on card number patterns
  static MockResult _getMockCardResult(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');

    // For mock implementation: ALL test card numbers work
    switch (cleaned) {
      case '4111111111111111': // Visa success
      case '4000000000000002': // Visa success
      case '5555555555554444': // Mastercard success
      case '5200000000000007': // Mastercard success
      case '4000000000000127': // Previously declined - now works in mock
      case '4000000000000135': // Previously declined - now works in mock
      case '4000000000000119': // Previously error - now works in mock
      case '4000000000000101': // Previously insufficient funds - now works in mock
        return MockResult(success: true, message: 'Card approved');

      default:
        // For mock implementation: ALL cards work to ensure testing is smooth
        return MockResult(success: true, message: 'Card approved');
    }
  }

  /// Validate card number format (Mock - very lenient for testing)
  static bool isValidCardNumber(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    // For mock: accept any card number with at least 4 digits
    return cleaned.length >= 4;
  }

  /// Validate expiry date
  static bool isValidExpiryDate(String month, String year) {
    if (month.isEmpty || year.isEmpty) return false;

    final monthInt = int.tryParse(month);
    final yearInt = int.tryParse(year);

    if (monthInt == null || yearInt == null) return false;
    if (monthInt < 1 || monthInt > 12) return false;

    final now = DateTime.now();
    final currentYear = now.year % 100; // Get last 2 digits
    final currentMonth = now.month;

    // Check if the card is expired
    if (yearInt < currentYear) return false;
    if (yearInt == currentYear && monthInt < currentMonth) return false;

    return true;
  }

  /// Validate CVV
  static bool isValidCVV(String cvv) {
    final cleaned = cvv.replaceAll(RegExp(r'\D'), '');
    return cleaned.length >= 3 && cleaned.length <= 4;
  }

  /// Validate routing number (9 digits)
  static bool isValidRoutingNumber(String routingNumber) {
    final cleaned = routingNumber.replaceAll(RegExp(r'\D'), '');
    return cleaned.length == 9;
  }

  /// Validate account number (6-17 digits)
  static bool isValidAccountNumber(String accountNumber) {
    final cleaned = accountNumber.replaceAll(RegExp(r'\D'), '');
    return cleaned.length >= 6 && cleaned.length <= 17;
  }
}

/// Result class for deposit operations
class DepositResult {
  final bool success;
  final String message;
  final DepositModel deposit;

  DepositResult({
    required this.success,
    required this.message,
    required this.deposit,
  });
}

/// Mock validation result
class MockResult {
  final bool success;
  final String message;

  MockResult({
    required this.success,
    required this.message,
  });
}

/// Deposit limits configuration
class DepositLimits {
  final double minAmount;
  final double maxAmount;
  final double dailyLimit;

  DepositLimits({
    required this.minAmount,
    required this.maxAmount,
    required this.dailyLimit,
  });
}
