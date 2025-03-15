import 'package:get/get.dart';
import 'package:lul/utils/helpers/pricing_calculator.dart';
import 'package:lul/services/transaction_service.dart';
import 'package:lul/utils/popups/full_screen_loader.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/features/wallet/send/transaction_success_screen.dart';

class TransferController extends GetxController {
  // Contact Details
  final RxString contactId = ''.obs;
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString country = ''.obs;

  // Transfer Details
  final RxDouble sendAmount = 0.0.obs;
  final RxString currency = ''.obs;
  final RxDouble fee = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;

  // Wallet Details
  final RxInt walletId = 0.obs;
  final RxInt walletTypeId = 0.obs;

  // Add new fields
  final RxString documentType = ''.obs;
  final RxString city = ''.obs;
  final RxString state = ''.obs;

  // Add description field
  final RxString description = ''.obs;

  // Add relationship field
  final RxString relationship = ''.obs;

  // Add idempotency key field
  final RxString idempotencyKey = ''.obs;

  // Transaction response data
  final Rx<Map<String, dynamic>> transactionData = Rx<Map<String, dynamic>>({});

  // Add transaction service
  late final TransactionService _transactionService;
  late final LanguageController _languageController;
  late final LulLoaders _loaders;

  @override
  void onInit() {
    super.onInit();
    _transactionService = Get.find<TransactionService>();
    _languageController = Get.find<LanguageController>();
    _loaders = Get.find<LulLoaders>();
  }

  void setRecipientDetails(
      String id, String name, String mail, String phoneNumber,
      [String? selectedCountry]) {
    contactId.value = id;
    fullName.value = name;
    email.value = mail;
    phone.value = phoneNumber;
    country.value = selectedCountry ?? '';
  }

  void setTransferDetails(double amount, String selectedCurrency,
      [int? sourceWalletId, int? sourceWalletTypeId]) {
    sendAmount.value = amount;
    currency.value = selectedCurrency;
    walletId.value = sourceWalletId ?? 0;
    walletTypeId.value = sourceWalletTypeId ?? 0;
    calculateFee();

    // Debug log
    print(
        'TransferController: Setting transfer details - Amount: $amount, Currency: $selectedCurrency, WalletID: ${walletId.value}, WalletTypeID: ${walletTypeId.value}');
  }

  void calculateFee() {
    fee.value = TPricingCalculator.calculateTransferFee(sendAmount.value);
    totalAmount.value =
        TPricingCalculator.calculateTotalTransferAmount(sendAmount.value);
  }

  void setNonLulRecipientDetails(
      String id,
      String name,
      String docType,
      String mail,
      String phoneNumber,
      String selectedCountry,
      String selectedState,
      String selectedCity,
      [String? relationshipValue]) {
    contactId.value = id;
    fullName.value = name;
    documentType.value = docType;
    email.value = mail;
    phone.value = phoneNumber;
    country.value = selectedCountry;
    state.value = selectedState;
    city.value = selectedCity;
    relationship.value = relationshipValue ?? '';
  }

  void clearTransferData() {
    documentType.value = '';
    city.value = '';
    state.value = '';
  }

  // Get error message based on error code
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'ERR_651':
        return _languageController.getText('err_651') ??
            'The provided PIN is incorrect';
      case 'ERR_652':
        return _languageController.getText('err_652') ??
            'User has not set a PIN';
      case 'ERR_902':
        return _languageController.getText('err_902') ??
            'Insufficient funds for this transaction';
      case 'ERR_903':
        return _languageController.getText('err_903') ??
            'The amount is invalid (negative or zero)';
      case 'ERR_904':
        return _languageController.getText('err_904') ??
            'Sender or receiver wallet not found';
      case 'ERR_905':
        return _languageController.getText('err_905') ??
            'You don\'t have access to the specified wallet';
      case 'ERR_906':
        return _languageController.getText('err_906') ??
            'Receiver doesn\'t have a wallet in your currency';
      case 'ERR_907':
        return _languageController.getText('err_907') ??
            'Transaction exceeds maximum allowed amount';
      case 'ERR_908':
        return _languageController.getText('err_908') ??
            'Amount is below minimum transaction limit';
      case 'ERR_909':
        return _languageController.getText('err_909') ??
            'Daily transaction limit exceeded';
      case 'ERR_910':
        return _languageController.getText('err_910') ??
            'Monthly transaction limit exceeded';
      case 'ERR_911':
        return _languageController.getText('err_911') ??
            'Annual transaction limit exceeded';
      case 'ERR_501':
        return _languageController.getText('err_501') ??
            'Receiver with specified worker ID not found';
      case 'ERR_901':
        return _languageController.getText('err_901') ??
            'Transaction failed. Please try again later';
      case 'ERR_502':
        return _languageController.getText('err_502') ??
            'Session expired. Please login again';
      // Add new error codes for non-wallet transfers
      case 'ERR_921':
        return _languageController.getText('err_921') ??
            'Recipient details are invalid';
      case 'ERR_922':
        return _languageController.getText('err_922') ??
            'Recipient ID is invalid';
      case 'ERR_923':
        return _languageController.getText('err_923') ??
            'Recipient phone number is invalid';
      case 'ERR_924':
        return _languageController.getText('err_924') ??
            'Disbursement stage not found';
      case 'ERR_925':
        return _languageController.getText('err_925') ??
            'Non-wallet transfer failed';
      case 'ERR_926':
        return _languageController.getText('err_926') ??
            'Recipient details not found';
      case 'ERR_927':
        return _languageController.getText('err_927') ?? 'Invalid relationship';
      default:
        return _languageController.getText('transfer_failed') ??
            'Transaction failed. Please try again later';
    }
  }

  // New method to initiate transaction
  Future<void> initiateTransaction(String idempotencyKey, String pin) async {
    print(
        'TransferController: initiateTransaction called with PIN length ${pin.length} and idempotencyKey $idempotencyKey');

    try {
      // Ensure we have a valid wallet type ID
      if (walletTypeId.value <= 0) {
        print(
            'TransferController: Invalid wallet type ID: ${walletTypeId.value}');
        TFullScreenLoader.stopLoading();
        _loaders.errorDialog(
          title: _languageController.getText('error') ?? 'Error',
          message: _languageController.getText('invalid_wallet') ??
              'Invalid wallet selected',
        );
        return;
      }

      // Create a default description if none is provided
      final String transactionDescription = description.value.isEmpty
          ? 'Transfer to ${fullName.value}'
          : description.value;

      print(
          'TransferController: Initiating transaction with PIN length ${pin.length}, idempotencyKey: $idempotencyKey');
      print(
          'TransferController: Transaction details - Amount: ${sendAmount.value}, Currency: ${currency.value}, WalletTypeID: ${walletTypeId.value}');

      final result = await _transactionService.walletToWalletTransfer(
        senderWalletTypeId: walletTypeId.value,
        receiverWorkerId: contactId.value,
        amount: sendAmount.value,
        pin: pin,
        description: transactionDescription,
        idempotencyKey: idempotencyKey,
      );

      print(
          'TransferController: Transaction API response received: ${result['status']}');

      // Close loading dialog
      TFullScreenLoader.stopLoading();

      if (result['status'] == 'success') {
        // Store transaction data for success screen
        transactionData.value = result['data'] ?? {};

        print(
            'TransferController: Transaction successful: ${transactionData.value}');

        // Navigate to success screen
        print('TransferController: Navigating to success screen');
        Get.off(() =>
            TransactionSuccessScreen(transactionData: transactionData.value));
      } else {
        // Get error code and message
        final errorCode = result['code'] ?? 'UNKNOWN_ERROR';
        final errorMessage = result['message'] ?? _getErrorMessage(errorCode);

        print(
            'TransferController: Transaction failed: $errorCode - $errorMessage');

        // Show error dialog
        _loaders.errorDialog(
          title:
              '${_languageController.getText('error') ?? 'Error'} [$errorCode]',
          message: errorMessage,
          onPressed: () {
            // Return to review screen (do nothing as we're already there)
            print('TransferController: Error dialog dismissed');
          },
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      TFullScreenLoader.stopLoading();

      print('TransferController: Transaction error: $e');

      _loaders.errorDialog(
        title: _languageController.getText('error') ?? 'Error',
        message: e.toString(),
      );
    }
  }

  // New method to initiate non-wallet transaction
  Future<void> initiateNonWalletTransaction(
      String idempotencyKey, String pin) async {
    print(
        'TransferController: initiateNonWalletTransaction called with PIN length ${pin.length} and idempotencyKey $idempotencyKey');

    // Store the idempotency key
    this.idempotencyKey.value = idempotencyKey;

    try {
      // Ensure we have a valid wallet type ID
      if (walletTypeId.value <= 0) {
        print(
            'TransferController: Invalid wallet type ID: ${walletTypeId.value}');
        TFullScreenLoader.stopLoading();
        _loaders.errorDialog(
          title: _languageController.getText('error') ?? 'Error',
          message: _languageController.getText('invalid_wallet') ??
              'Invalid wallet selected',
        );
        return;
      }

      // Create a default description if none is provided
      final String transactionDescription = description.value.isEmpty
          ? 'Non-wallet transfer to ${fullName.value}'
          : description.value;

      print(
          'TransferController: Initiating non-wallet transaction with PIN length ${pin.length}, idempotencyKey: $idempotencyKey');
      print(
          'TransferController: Transaction details - Amount: ${sendAmount.value}, Currency: ${currency.value}, WalletTypeID: ${walletTypeId.value}');
      print(
          'TransferController: Recipient details - Name: ${fullName.value}, ID: ${contactId.value}, Document Type: ${documentType.value}');

      final result = await _transactionService.nonWalletTransfer(
        senderWalletTypeId: walletTypeId.value,
        amount: sendAmount.value,
        pin: pin,
        recipientFullName: fullName.value,
        idDocumentType: documentType.value,
        idNumber: contactId.value,
        phoneNumber: phone.value,
        email: email.value,
        country: country.value,
        state: state.value,
        city: city.value,
        relationship: relationship.value,
        description: transactionDescription,
        idempotencyKey: idempotencyKey,
      );

      print(
          'TransferController: Non-wallet transaction API response received: ${result['status']}');

      // Close loading dialog
      TFullScreenLoader.stopLoading();

      if (result['status'] == 'success') {
        // Store transaction data for success screen
        transactionData.value = result['data'] ?? {};

        print(
            'TransferController: Non-wallet transaction successful: ${transactionData.value}');

        // Navigate to success screen
        print('TransferController: Navigating to success screen');
        Get.off(() =>
            TransactionSuccessScreen(transactionData: transactionData.value));
      } else {
        // Get error code and message
        final errorCode = result['code'] ?? 'UNKNOWN_ERROR';
        final errorMessage = result['message'] ?? _getErrorMessage(errorCode);

        print(
            'TransferController: Non-wallet transaction failed: $errorCode - $errorMessage');

        // Show error dialog
        _loaders.errorDialog(
          title:
              '${_languageController.getText('error') ?? 'Error'} [$errorCode]',
          message: errorMessage,
          onPressed: () {
            // Return to review screen (do nothing as we're already there)
            print('TransferController: Error dialog dismissed');
          },
        );
      }
    } catch (e) {
      // Close loading dialog and show error
      TFullScreenLoader.stopLoading();

      print('TransferController: Non-wallet transaction error: $e');

      _loaders.errorDialog(
        title: _languageController.getText('error') ?? 'Error',
        message: e.toString(),
      );
    }
  }
}
