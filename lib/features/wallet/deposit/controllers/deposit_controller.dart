import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/deposit_service.dart';
import '../../../../utils/popups/loaders.dart';
import '../models/deposit_models.dart';

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
}
