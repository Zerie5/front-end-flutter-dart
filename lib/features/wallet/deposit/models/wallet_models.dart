// Wallet Models for wallet selection functionality

class WalletOverviewResponse {
  final bool success;
  final String message;
  final WalletOverviewData data;

  WalletOverviewResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WalletOverviewResponse.fromJson(Map<String, dynamic> json) {
    return WalletOverviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: WalletOverviewData.fromJson(json['data']),
    );
  }
}

class WalletOverviewData {
  final int userId;
  final WalletSummary summary;
  final List<UserWallet> wallets;

  WalletOverviewData({
    required this.userId,
    required this.summary,
    required this.wallets,
  });

  factory WalletOverviewData.fromJson(Map<String, dynamic> json) {
    return WalletOverviewData(
      userId: json['userId'] ?? 0,
      summary: WalletSummary.fromJson(json['summary']),
      wallets: (json['wallets'] as List<dynamic>?)
              ?.map((wallet) => UserWallet.fromJson(wallet))
              .toList() ??
          [],
    );
  }
}

class WalletSummary {
  final int totalWallets;
  final int activeWallets;
  final String totalBalanceUSD;
  final List<String> activeCurrencies;
  final bool hasBlockchainWallets;
  final bool hasBackendWallets;

  WalletSummary({
    required this.totalWallets,
    required this.activeWallets,
    required this.totalBalanceUSD,
    required this.activeCurrencies,
    required this.hasBlockchainWallets,
    required this.hasBackendWallets,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      totalWallets: json['totalWallets'] ?? 0,
      activeWallets: json['totalActiveWallets'] ?? json['activeWallets'] ?? 0,
      totalBalanceUSD: (json['totalValueUSD'] is double)
          ? json['totalValueUSD'].toString()
          : (json['totalValueUSD'] ?? json['totalBalanceUSD'] ?? '0.00'),
      activeCurrencies: List<String>.from(json['activeCurrencies'] ?? []),
      hasBlockchainWallets: json['hasBlockchainWallets'] ?? false,
      hasBackendWallets: json['hasBackendWallets'] ?? false,
    );
  }
}

class UserWallet {
  final int userWalletId;
  final int walletId;
  final String currencyCode;
  final String currencyName;
  final String countryCode;
  final String balance;
  final String publicKey;
  final bool isActive;
  final String walletType;
  final String? network;
  final String createdAt;
  final String lastUpdatedAt;
  final bool requiresFunding;
  final String balanceInUSD;

  UserWallet({
    required this.userWalletId,
    required this.walletId,
    required this.currencyCode,
    required this.currencyName,
    required this.countryCode,
    required this.balance,
    required this.publicKey,
    required this.isActive,
    required this.walletType,
    this.network,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.requiresFunding,
    required this.balanceInUSD,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      userWalletId: json['userWalletId'] ?? 0,
      walletId: json['walletId'] ?? 0,
      currencyCode: json['currencyCode'] ?? '',
      currencyName: json['currencyName'] ?? '',
      countryCode: json['countryCode'] ?? '',
      balance: (json['balance'] is double)
          ? json['balance'].toString()
          : (json['balance'] ?? '0.00'),
      publicKey: json['publicKey'] ?? '',
      isActive: json['active'] ??
          json['isActive'] ??
          false, // Handle both 'active' and 'isActive'
      walletType: json['walletType'] ?? 'BACKEND',
      network: json['network'],
      createdAt: json['createdAt'] ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] ?? json['createdAt'] ?? '',
      requiresFunding: !(json['funded'] ??
          json['isFunded'] ??
          true), // Invert 'funded' to get 'requiresFunding'
      balanceInUSD: (json['balanceInUSD'] is double)
          ? json['balanceInUSD'].toString()
          : (json['balanceInUSD'] ?? '0.00'),
    );
  }

  // Get formatted balance for display
  String get formattedBalance {
    final amount = double.tryParse(balance) ?? 0.0;
    return '${getCurrencySymbol()} ${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  // Get formatted USD balance for display
  String get formattedBalanceUSD {
    final amount = double.tryParse(balanceInUSD) ?? 0.0;
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  // Get currency symbol based on currency code
  String getCurrencySymbol() {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
      case 'EURO':
        return '€';
      case 'UGX':
        return 'UGX';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return currencyCode;
    }
  }

  // Get wallet type display name
  String get walletTypeDisplay {
    switch (walletType.toUpperCase()) {
      case 'BLOCKCHAIN':
        return 'Blockchain Wallet';
      case 'BACKEND':
        return 'Standard Wallet';
      default:
        return walletType;
    }
  }

  // Check if wallet can be funded
  bool get canBeFunded {
    return isActive && !requiresFunding;
  }
}
