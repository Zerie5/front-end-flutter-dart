class TransactionModel {
  final String transactionId;
  final double amount;
  final String currency;
  final double fee;
  final double totalAmount;
  final String transactionType;
  final String transactionStatus;
  final RecipientModel recipient;
  final String description;
  final String createdAt;
  final String? completedAt;
  final bool isReversal;

  TransactionModel({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.fee,
    required this.totalAmount,
    required this.transactionType,
    required this.transactionStatus,
    required this.recipient,
    required this.description,
    required this.createdAt,
    this.completedAt,
    required this.isReversal,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      fee: (json['fee'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      transactionType: json['transactionType'] ?? '',
      transactionStatus: json['transactionStatus'] ?? '',
      recipient: RecipientModel.fromJson(json['recipient'] ?? {}),
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
      completedAt: json['completedAt'],
      isReversal: json['isReversal'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'fee': fee,
      'totalAmount': totalAmount,
      'transactionType': transactionType,
      'transactionStatus': transactionStatus,
      'recipient': recipient.toJson(),
      'description': description,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'isReversal': isReversal,
    };
  }
}

class RecipientModel {
  final String fullName;
  final String? workerId;
  final String? phoneNumber;
  final String? email;
  final String recipientType;
  final String? country;

  RecipientModel({
    required this.fullName,
    this.workerId,
    this.phoneNumber,
    this.email,
    required this.recipientType,
    this.country,
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      fullName: json['fullName'] ?? '',
      workerId: json['workerId'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      recipientType: json['recipientType'] ?? '',
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'workerId': workerId,
      'phoneNumber': phoneNumber,
      'email': email,
      'recipientType': recipientType,
      'country': country,
    };
  }
}

class PaginationModel {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final bool isFirst;
  final bool isLast;

  PaginationModel({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.isFirst,
    required this.isLast,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
      isFirst: json['isFirst'] ?? true,
      isLast: json['isLast'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'pageSize': pageSize,
      'totalItems': totalItems,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
      'isFirst': isFirst,
      'isLast': isLast,
    };
  }
}

class TransactionResponse {
  final bool success;
  final String message;
  final List<TransactionModel> transactions;
  final PaginationModel pagination;

  TransactionResponse({
    required this.success,
    required this.message,
    required this.transactions,
    required this.pagination,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}
