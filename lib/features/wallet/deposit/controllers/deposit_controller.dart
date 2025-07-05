import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/deposit_service.dart';
import '../models/deposit_models.dart';
import '../models/wallet_models.dart';
import '../services/wallet_api_service.dart';

class DepositController extends GetxController {
  static DepositController get instance => Get.find();

  // Text controllers
  final TextEditingController amountController = TextEditingController();

  // Card form controllers
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardholderNameController =
      TextEditingController();
  final TextEditingController expiryMonthController = TextEditingController();
  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  // Bank form controllers
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController routingNumberController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();

  // Form keys
  final GlobalKey<FormState> cardFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> bankFormKey = GlobalKey<FormState>();

  // Observable states
  final RxDouble depositAmount = 0.0.obs;
  final Rx<PaymentMethodType?> selectedPaymentMethod =
      Rx<PaymentMethodType?>(null);
  final RxBool isProcessing = false.obs;
  final Rx<BankModel?> selectedBank = Rx<BankModel?>(null);

  // Wallet selection states
  final RxList<UserWallet> userWallets = <UserWallet>[].obs;
  final Rx<UserWallet?> selectedWallet = Rx<UserWallet?>(null);
  final RxBool isLoadingWallets = false.obs;
  final RxBool hasWalletError = false.obs;
  final RxString walletErrorMessage = ''.obs;

  // Deposit limits
  late final DepositLimits depositLimits;

  // Quick amount buttons
  final List<double> quickAmounts = [25.0, 50.0, 100.0, 250.0, 500.0];

  @override
  void onInit() {
    super.onInit();
    print('DepositController: Initializing');
    depositLimits = MockDepositService.getDepositLimits();
    print(
        'DepositController: Initialized with limits - Min: \$${depositLimits.minAmount}, Max: \$${depositLimits.maxAmount}');
  }

  @override
  void onClose() {
    amountController.dispose();
    cardNumberController.dispose();
    cardholderNameController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    cvvController.dispose();
    accountNumberController.dispose();
    routingNumberController.dispose();
    accountHolderNameController.dispose();
    super.onClose();
  }

  /// Set deposit amount
  void setDepositAmount(double amount) {
    print('DepositController: Setting deposit amount to \$$amount');
    depositAmount.value = amount;
    amountController.text = amount.toStringAsFixed(2);
  }

  /// Set payment method
  void setPaymentMethod(PaymentMethodType method) {
    print('DepositController: Setting payment method to ${method.name}');
    selectedPaymentMethod.value = method;
  }

  /// Get formatted amount for display
  String getFormattedAmount(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// Set selected bank
  void setSelectedBank(BankModel bank) {
    selectedBank.value = bank;
  }

  /// Check if card form is valid
  bool get isCardFormValid =>
      cardNumberController.text.isNotEmpty &&
      cardholderNameController.text.isNotEmpty &&
      expiryMonthController.text.isNotEmpty &&
      expiryYearController.text.isNotEmpty &&
      cvvController.text.isNotEmpty;

  /// Load user wallets from API
  Future<void> loadUserWallets() async {
    try {
      print('DepositController: Loading user wallets');
      isLoadingWallets.value = true;
      hasWalletError.value = false;
      walletErrorMessage.value = '';

      final response = await WalletApiService.getUserWallets();

      if (response.success) {
        userWallets.value = response.data.wallets
            .where((wallet) => wallet.canBeFunded)
            .toList();
        print(
            'DepositController: Loaded ${userWallets.length} fundable wallets');

        if (userWallets.isEmpty) {
          hasWalletError.value = true;
          walletErrorMessage.value = 'No wallets available for funding';
        }
      } else {
        hasWalletError.value = true;
        walletErrorMessage.value = response.message;
      }
    } catch (e) {
      print('DepositController: Error loading wallets: $e');
      hasWalletError.value = true;
      walletErrorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoadingWallets.value = false;
    }
  }

  /// Set selected wallet
  void setSelectedWallet(UserWallet wallet) {
    print(
        'DepositController: Setting selected wallet to ${wallet.currencyCode}');
    selectedWallet.value = wallet;
  }

  /// Check if wallet is selected
  bool get hasSelectedWallet => selectedWallet.value != null;

  /// Get selected wallet currency symbol
  String get selectedWalletCurrencySymbol {
    return selectedWallet.value?.getCurrencySymbol() ?? '\$';
  }

  /// Get selected wallet currency code
  String get selectedWalletCurrencyCode {
    return selectedWallet.value?.currencyCode ?? 'USD';
  }

  /// Get selected wallet user wallet ID
  int get selectedWalletId {
    return selectedWallet.value?.userWalletId ?? 0;
  }

  /// Get payment processor based on currency and wallet type (Mock)
  String getPaymentProcessor() {
    final walletType = selectedWallet.value?.walletType ?? 'BACKEND';
    final currency = selectedWalletCurrencyCode;

    if (walletType.toUpperCase() == 'BLOCKCHAIN') {
      switch (currency.toUpperCase()) {
        case 'USD':
          return 'STRIPE';
        case 'EURO':
          return 'PLAID';
        default:
          return 'STRIPE';
      }
    } else {
      switch (currency.toUpperCase()) {
        case 'UGX':
          return 'FLUTTERWAVE';
        case 'USD':
          return 'STRIPE';
        default:
          return 'PAYSTACK';
      }
    }
  }

  /// Get card brand and type from card number (Mock)
  Map<String, String> getCardInfo() {
    final cardNumber = cardNumberController.text.replaceAll('-', '');

    if (cardNumber.startsWith('4')) {
      return {'brand': 'VISA', 'type': 'DEBIT'};
    } else if (cardNumber.startsWith('5') || cardNumber.startsWith('2')) {
      return {'brand': 'MASTERCARD', 'type': 'CREDIT'};
    } else if (cardNumber.startsWith('3')) {
      return {'brand': 'AMEX', 'type': 'CREDIT'};
    } else if (cardNumber.startsWith('6')) {
      return {'brand': 'DISCOVER', 'type': 'DEBIT'};
    }

    return {'brand': 'VISA', 'type': 'DEBIT'}; // Default mock
  }

  /// Get additional data based on wallet type and payment method (Mock)
  Map<String, dynamic> getAdditionalData() {
    final walletType = selectedWallet.value?.walletType ?? 'BACKEND';
    final currency = selectedWalletCurrencyCode;
    final paymentMethod = selectedPaymentMethod.value;

    if (walletType.toUpperCase() == 'BLOCKCHAIN') {
      Map<String, dynamic> data = {
        'stellar_memo': 'funding-deposit',
        'priority': 'standard'
      };

      if (currency.toUpperCase() == 'EURO') {
        data['stellar_conversion'] = 'immediate';
      }

      if (paymentMethod == PaymentMethodType.bank) {
        data['sepa_reference'] = 'EUR${DateTime.now().millisecondsSinceEpoch}';
      }

      return data;
    } else {
      Map<String, dynamic> data = {
        'currency_conversion': 'auto',
        'notification_preference': 'email'
      };

      if (paymentMethod == PaymentMethodType.bank) {
        data['transfer_reference'] =
            '${currency.toUpperCase()}${DateTime.now().millisecondsSinceEpoch}';
      }

      return data;
    }
  }
}
