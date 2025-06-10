// Deposit Models for the deposit functionality

class DepositModel {
  final String? depositId;
  final double amount;
  final String currency;
  final PaymentMethodType paymentMethod;
  final CardModel? cardDetails;
  final BankModel? bankDetails;
  final DepositStatus status;
  final String? transactionId;
  final DateTime? createdAt;
  final String? errorMessage;
  final double? fee;

  DepositModel({
    this.depositId,
    required this.amount,
    this.currency = 'USD',
    required this.paymentMethod,
    this.cardDetails,
    this.bankDetails,
    this.status = DepositStatus.pending,
    this.transactionId,
    this.createdAt,
    this.errorMessage,
    this.fee = 0.0,
  });

  DepositModel copyWith({
    String? depositId,
    double? amount,
    String? currency,
    PaymentMethodType? paymentMethod,
    CardModel? cardDetails,
    BankModel? bankDetails,
    DepositStatus? status,
    String? transactionId,
    DateTime? createdAt,
    String? errorMessage,
    double? fee,
  }) {
    return DepositModel(
      depositId: depositId ?? this.depositId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardDetails: cardDetails ?? this.cardDetails,
      bankDetails: bankDetails ?? this.bankDetails,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
      fee: fee ?? this.fee,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depositId': depositId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod.name,
      'cardDetails': cardDetails?.toJson(),
      'bankDetails': bankDetails?.toJson(),
      'status': status.name,
      'transactionId': transactionId,
      'createdAt': createdAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'fee': fee,
    };
  }

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      depositId: json['depositId'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      paymentMethod: PaymentMethodType.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethodType.card,
      ),
      cardDetails: json['cardDetails'] != null
          ? CardModel.fromJson(json['cardDetails'])
          : null,
      bankDetails: json['bankDetails'] != null
          ? BankModel.fromJson(json['bankDetails'])
          : null,
      status: DepositStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DepositStatus.pending,
      ),
      transactionId: json['transactionId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      errorMessage: json['errorMessage'],
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CardModel {
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String cardholderName;

  CardModel({
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.cardholderName,
  });

  CardModel copyWith({
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cvv,
    String? cardholderName,
  }) {
    return CardModel(
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      cardholderName: cardholderName ?? this.cardholderName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardNumber': cardNumber,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
      'cardholderName': cardholderName,
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cardNumber: json['cardNumber'] ?? '',
      expiryMonth: json['expiryMonth'] ?? '',
      expiryYear: json['expiryYear'] ?? '',
      cvv: json['cvv'] ?? '',
      cardholderName: json['cardholderName'] ?? '',
    );
  }

  // Get masked card number for display (e.g., "**** **** **** 1234")
  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }

  // Format card number with dashes
  String get formattedCardNumber {
    final cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }
}

class BankModel {
  final String bankName;
  final String accountNumber;
  final String routingNumber;
  final BankAccountType accountType;
  final String accountHolderName;

  BankModel({
    required this.bankName,
    required this.accountNumber,
    required this.routingNumber,
    required this.accountType,
    required this.accountHolderName,
  });

  BankModel copyWith({
    String? bankName,
    String? accountNumber,
    String? routingNumber,
    BankAccountType? accountType,
    String? accountHolderName,
  }) {
    return BankModel(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      routingNumber: routingNumber ?? this.routingNumber,
      accountType: accountType ?? this.accountType,
      accountHolderName: accountHolderName ?? this.accountHolderName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
      'accountType': accountType.name,
      'accountHolderName': accountHolderName,
    };
  }

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      routingNumber: json['routingNumber'] ?? '',
      accountType: BankAccountType.values.firstWhere(
        (e) => e.name == json['accountType'],
        orElse: () => BankAccountType.checking,
      ),
      accountHolderName: json['accountHolderName'] ?? '',
    );
  }

  // Get masked account number for display
  String get maskedAccountNumber {
    if (accountNumber.length < 4) return accountNumber;
    return '**** ${accountNumber.substring(accountNumber.length - 4)}';
  }
}

// Payment method types
enum PaymentMethodType {
  card,
  bank,
}

// Deposit status
enum DepositStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

// Bank account types
enum BankAccountType {
  checking,
  savings,
}

// Mock bank data for selection
class MockBankData {
  static List<String> get bankNames => [
        'JPMorgan Chase Bank',
        'Bank of America',
        'Wells Fargo Bank',
        'Citibank',
        'U.S. Bank',
        'Truist Bank',
        'PNC Bank',
        'Goldman Sachs Bank',
        'TD Bank',
        'Capital One Bank',
        'HSBC Bank USA',
        'BMO Harris Bank',
        'MUFG Union Bank',
        'Fifth Third Bank',
        'KeyBank',
      ];
}
