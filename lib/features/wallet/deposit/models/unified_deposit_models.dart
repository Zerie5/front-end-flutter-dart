// Updated Unified Deposit Models to match new API specification

class UnifiedDepositResponse {
  final bool success;
  final String message;
  final UnifiedDepositData data;

  UnifiedDepositResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UnifiedDepositResponse.fromJson(Map<String, dynamic> json) {
    return UnifiedDepositResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: UnifiedDepositData.fromJson(json['data']),
    );
  }

  // Check if this is a blockchain wallet response
  bool get isBlockchainWallet => data.routedTo == 'BLOCKCHAIN';

  // Check if this is a backend wallet response
  bool get isBackendWallet => data.routedTo == 'BACKEND';
}

class UnifiedDepositData {
  final bool success;
  final String message;
  final String routedTo; // 'BACKEND' or 'BLOCKCHAIN'
  final String service; // e.g., 'BACKEND_WALLET', 'STELLAR_FRIENDBOT'
  final String? fundingSource; // For blockchain wallets
  final DepositResponseData? depositResponse; // For backend wallets
  final UnifiedTransactionData transaction;
  final UnifiedWalletData wallet;

  UnifiedDepositData({
    required this.success,
    required this.message,
    required this.routedTo,
    required this.service,
    this.fundingSource,
    this.depositResponse,
    required this.transaction,
    required this.wallet,
  });

  factory UnifiedDepositData.fromJson(Map<String, dynamic> json) {
    try {
      print('UnifiedDepositData.fromJson: Starting to parse data');
      print('JSON keys: ${json.keys.toList()}');

      // Create simplified transaction data from the flat response
      final transaction = UnifiedTransactionData(
        transactionId: json['transactionId'] ?? '',
        amount:
            (json['transactionAmount'] ?? json['amount'])?.toString() ?? '0.00',
        currency: json['transactionCurrency'] ?? json['currency'] ?? '',
        txHash: json['transactionHash'] ?? json['txHash'],
        timestamp: json['transactionTimestamp'] ??
            json['timestamp'] ??
            json['createdAt'] ??
            '',
      );
      print('UnifiedDepositData.fromJson: Transaction parsed successfully');

      // Create simplified wallet data from the flat response
      final wallet = UnifiedWalletData(
        previousBalance: json['previousBalance']?.toString(),
        newBalance: json['newBalance']?.toString() ?? '0.00',
        publicKey: json['publicKey'],
        walletId: json['walletId'],
        currency: json['walletCurrency'] ?? json['currency'],
      );
      print('UnifiedDepositData.fromJson: Wallet parsed successfully');

      return UnifiedDepositData(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        routedTo: json['routedTo'] ?? 'BACKEND',
        service: json['service'] ?? '',
        fundingSource: json['fundingSource'],
        depositResponse: null, // This is not present in the flat response
        transaction: transaction,
        wallet: wallet,
      );
    } catch (e) {
      print('UnifiedDepositData.fromJson: Error parsing - $e');
      rethrow;
    }
  }
}

class DepositResponseData {
  final bool success;
  final String message;
  final TransactionDetails transaction;
  final DepositDetails deposit;

  DepositResponseData({
    required this.success,
    required this.message,
    required this.transaction,
    required this.deposit,
  });

  factory DepositResponseData.fromJson(Map<String, dynamic> json) {
    return DepositResponseData(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transaction: TransactionDetails.fromJson(json['transaction']),
      deposit: DepositDetails.fromJson(json['deposit']),
    );
  }
}

class TransactionDetails {
  final String transactionId;
  final String amount;
  final String currency;
  final String fee;
  final String totalAmount;
  final String status;
  final String description;
  final String createdAt;
  final String? completedAt;
  final WalletDetails wallet;

  TransactionDetails({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.fee,
    required this.totalAmount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.completedAt,
    required this.wallet,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      transactionId: json['transactionId'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      currency: json['currency'] ?? '',
      fee: json['fee']?.toString() ?? '0.00',
      totalAmount: json['totalAmount']?.toString() ?? '0.00',
      status: json['status'] ?? 'PENDING',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
      completedAt: json['completedAt'],
      wallet: WalletDetails.fromJson(json['wallet']),
    );
  }

  String get formattedAmount {
    final amount = double.tryParse(this.amount) ?? 0.0;
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String get formattedFee {
    final fee = double.tryParse(this.fee) ?? 0.0;
    return fee.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String get formattedTotalAmount {
    final total = double.tryParse(totalAmount) ?? 0.0;
    return total.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class WalletDetails {
  final int walletId;
  final String currency;
  final String newBalance;

  WalletDetails({
    required this.walletId,
    required this.currency,
    required this.newBalance,
  });

  factory WalletDetails.fromJson(Map<String, dynamic> json) {
    return WalletDetails(
      walletId: json['walletId'] ?? 0,
      currency: json['currency'] ?? '',
      newBalance: json['newBalance']?.toString() ?? '0.00',
    );
  }

  String get formattedNewBalance {
    final balance = double.tryParse(newBalance) ?? 0.0;
    return balance.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class DepositDetails {
  final String paymentMethodType;
  final String paymentProcessor;
  final String? externalTransactionId;
  final String? confirmationCode;
  final String processingStatus;
  final CardInfo? cardInfo;
  final BankInfo? bankInfo;

  DepositDetails({
    required this.paymentMethodType,
    required this.paymentProcessor,
    this.externalTransactionId,
    this.confirmationCode,
    required this.processingStatus,
    this.cardInfo,
    this.bankInfo,
  });

  factory DepositDetails.fromJson(Map<String, dynamic> json) {
    return DepositDetails(
      paymentMethodType: json['paymentMethodType'] ?? '',
      paymentProcessor: json['paymentProcessor'] ?? '',
      externalTransactionId: json['externalTransactionId'],
      confirmationCode: json['confirmationCode'],
      processingStatus: json['processingStatus'] ?? 'PENDING',
      cardInfo:
          json['cardInfo'] != null ? CardInfo.fromJson(json['cardInfo']) : null,
      bankInfo:
          json['bankInfo'] != null ? BankInfo.fromJson(json['bankInfo']) : null,
    );
  }
}

class CardInfo {
  final String lastFour;
  final String brand;
  final String type;

  CardInfo({
    required this.lastFour,
    required this.brand,
    required this.type,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      lastFour: json['lastFour'] ?? '',
      brand: json['brand'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class BankInfo {
  final String bankName;
  final String accountType;
  final String routingNumber;
  final String accountNumber;

  BankInfo({
    required this.bankName,
    required this.accountType,
    required this.routingNumber,
    required this.accountNumber,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      bankName: json['bankName'] ?? '',
      accountType: json['accountType'] ?? '',
      routingNumber: json['routingNumber'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
    );
  }
}

class UnifiedTransactionData {
  final String transactionId;
  final String amount;
  final String currency;
  final String? txHash; // For blockchain transactions
  final String timestamp;

  UnifiedTransactionData({
    required this.transactionId,
    required this.amount,
    required this.currency,
    this.txHash,
    required this.timestamp,
  });

  factory UnifiedTransactionData.fromJson(Map<String, dynamic> json) {
    return UnifiedTransactionData(
      transactionId: json['transactionId'] ?? '',
      amount:
          (json['transactionAmount'] ?? json['amount'])?.toString() ?? '0.00',
      currency: json['transactionCurrency'] ?? json['currency'] ?? '',
      txHash: json['transactionHash'] ?? json['txHash'],
      timestamp: json['transactionTimestamp'] ??
          json['timestamp'] ??
          json['createdAt'] ??
          '',
    );
  }

  String get formattedAmount {
    final amount = double.tryParse(this.amount) ?? 0.0;
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  bool get isBlockchainTransaction => txHash != null && txHash!.isNotEmpty;
}

class UnifiedWalletData {
  final String? previousBalance; // For blockchain wallets
  final String newBalance;
  final String? publicKey; // For blockchain wallets
  final int? walletId; // For backend wallets
  final String? currency; // For backend wallets

  UnifiedWalletData({
    this.previousBalance,
    required this.newBalance,
    this.publicKey,
    this.walletId,
    this.currency,
  });

  factory UnifiedWalletData.fromJson(Map<String, dynamic> json) {
    return UnifiedWalletData(
      previousBalance: json['previousBalance']?.toString(),
      newBalance: json['newBalance']?.toString() ?? '0.00',
      publicKey: json['publicKey'],
      walletId: json['walletId'],
      currency: json['walletCurrency'] ?? json['currency'],
    );
  }

  String get formattedNewBalance {
    final balance = double.tryParse(newBalance) ?? 0.0;
    return balance.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String get formattedPreviousBalance {
    if (previousBalance == null) return '0.00';
    final balance = double.tryParse(previousBalance!) ?? 0.0;
    return balance.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  bool get isBlockchainWallet => publicKey != null && publicKey!.isNotEmpty;
}
