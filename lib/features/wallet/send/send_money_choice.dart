import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/wallet/send/send_money_review.dart';
import 'package:lul/features/wallet/send/widgets/numeric_keypad.dart';
import 'package:lul/features/wallet/send/widgets/transfer_controller.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_controller.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_model.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/pricing_calculator.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/popups/full_screen_loader.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class LulSendMoneyChoiceScreen extends StatefulWidget {
  const LulSendMoneyChoiceScreen({super.key});

  @override
  State<LulSendMoneyChoiceScreen> createState() =>
      _LulSendMoneyChoiceScreenState();
}

class _LulSendMoneyChoiceScreenState extends State<LulSendMoneyChoiceScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController; // Make nullable
  final CurrencyController _currencyController = Get.find<CurrencyController>();
  final LanguageController _languageController = Get.find<LanguageController>();
  final RxMap<String, String> _amounts =
      RxMap<String, String>(); // Map for values

  // Add loading state
  final RxBool _isLoading = true.obs;

  final TransferController _transferController = Get.find();

  @override
  void initState() {
    super.initState();

    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Refresh currency data and initialize TabController safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading.value = true;
      _checkLoginAndRefreshData().then((_) {
        // Initialize amounts with '0' for all currencies
        for (var currency in _currencyController.currencies) {
          _amounts[currency.name] = '0';
        }

        // Only initialize TabController if we have currencies
        if (_currencyController.currencies.isNotEmpty) {
          _tabController = TabController(
            length: _currencyController.currencies.length,
            vsync: this,
          );
        }

        _isLoading.value = false;
        setState(() {}); // Only call after initialization is complete
      });
    });
  }

  Future<void> _checkLoginAndRefreshData() async {
    final token = await AuthStorage.getToken();
    if (token != null) {
      print('SendMoneyScreen: User is logged in, refreshing currency data');
      await _refreshCurrencyData();
    } else {
      print(
          'SendMoneyScreen: User is not logged in, skipping currency refresh');
      // Show error in the UI
      _currencyController.hasError.value = true;
      _currencyController.errorMessage.value =
          'Authentication required. Please log in.';
    }
  }

  String _formatAmount(String value) {
    return value.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  void _updateAmount(String value) {
    String currentCurrency = _currencyController
        .currencies[_tabController!.index].name; // Get current tab currency
    String currentValue = _amounts[currentCurrency] ?? '0';

    if (currentValue == '0') {
      _amounts[currentCurrency] = value;
    } else {
      _amounts[currentCurrency] = currentValue + value;
    }
  }

  void _removeLastDigit() {
    String currentCurrency = _currencyController
        .currencies[_tabController!.index].name; // Get current tab currency
    String currentValue = _amounts[currentCurrency] ?? '0';

    if (currentValue.length > 1) {
      _amounts[currentCurrency] =
          currentValue.substring(0, currentValue.length - 1);
    } else {
      _amounts[currentCurrency] = '0';
    }
  }

  bool _validateSingleCurrencySelection() {
    int selectedCurrencies =
        0; // Counter for number of currencies with values > 0
    bool hasAnyValue =
        false; // Flag to check if at least one currency has a value

    // Iterate through all available currencies and check their values in _amounts map
    // _amounts map stores user input for each currency tab (key: currency name, value: entered amount)
    for (var currency in _currencyController.currencies) {
      String amount =
          _amounts[currency.name] ?? '0'; // Get user input for current currency
      double value = double.parse(amount);
      if (value > 0) {
        selectedCurrencies++; // Increment counter if this currency has a value
        hasAnyValue = true; // Set flag indicating we found a value
      }
    }

    // Case 1: No amount entered in any currency tab
    if (!hasAnyValue) {
      LulLoaders.lulerrorSnackBar(
        title: _languageController.getText('error'),
        message: _languageController.getText('selectamount_snack'),
      );
      return false;
    }

    // Case 2: Amounts entered in multiple currency tabs
    if (selectedCurrencies > 1) {
      LulLoaders.lulerrorSnackBar(
        title: _languageController.getText('error'),
        message: _languageController.getText('onecurrencyonly_snack'),
      );
      return false;
    }

    return true; // Valid case: exactly one currency has a value
  }

  bool _validateSufficientBalance(double sendAmount, Currency currency) {
    double totalAmount =
        TPricingCalculator.calculateTotalTransferAmount(sendAmount);
    return totalAmount <= currency.availableBalance;
  }

  void _handleTransfer() {
    // First validate currency selection
    if (!_validateSingleCurrencySelection()) {
      return; // Stop if validation fails
    }

    // Get currently selected currency and its entered amount
    Currency selectedCurrency =
        _currencyController.currencies[_tabController!.index];
    double sendAmount = double.parse(_amounts[selectedCurrency.name] ?? '0');

    // Validate if user has sufficient balance
    if (!_validateSufficientBalance(sendAmount, selectedCurrency)) {
      LulLoaders.lulerrorSnackBar(
        title: _languageController.getText('error'),
        message: _languageController.getText('insufficientbalance_snack'),
      );
      return;
    }

    // All validations passed, proceed with transfer
    _transferController.setTransferDetails(
      sendAmount,
      selectedCurrency.code,
      selectedCurrency.id, // Pass the wallet ID
      selectedCurrency.walletTypeId, // Pass the wallet type ID
    );
    Get.to(() => const LulSendMoneyReviewScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Obx(() => Text(
              _languageController.getText('send_money'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshCurrencyData,
          ),
        ],
      ),
      body: Obx(() {
        // Handle error state with dialog
        if (_currencyController.hasError.value) {
          // Show error dialog after build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LulLoaders.lulerrorDialog(
              title: _languageController.getText('error'),
              message: _currencyController.errorMessage.value,
              onPressed: _refreshCurrencyData,
            );
          });
        }

        // Show message if no currencies are available
        if (_currencyController.currencies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _languageController.getText('no_currencies'),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshCurrencyData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: TColors.primary,
                  ),
                  child: Text(_languageController.getText('refresh')),
                ),
              ],
            ),
          );
        }

        // TabController must be initialized by this point
        if (_tabController == null) {
          return const Center(
            child: Text(
              "Error initializing currency tabs",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Continue with the regular UI if everything is loaded
        return Column(
          children: [
            // Add TabBar back
            PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                indicatorColor: TColors.secondary,
                labelColor: TColors.white,
                unselectedLabelColor: TColors.white.withOpacity(0.7),
                tabs: _currencyController.currencies
                    .map((currency) => Tab(
                          text: _languageController
                              .getText(currency.code)
                              .toUpperCase(),
                        ))
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _currencyController.currencies.map((currency) {
                  return buildCurrencyTab(currency);
                }).toList(),
              ),
            ),
            // Keypad
            NumericKeypad(
              onNumberTap: _updateAmount,
              onBackspace: _removeLastDigit,
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: SizedBox(
                width: double.infinity,
                child: LulButton(
                  onPressed: _handleTransfer,
                  text: _languageController.getText('continue'),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose(); // Use safe call
    // Unregister from lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // We no longer refresh on app resume
    // Currency data will only be refreshed when the screen is first opened
    if (state == AppLifecycleState.resumed) {
      print(
          'SendMoneyScreen: App resumed, but not refreshing currency data (will only refresh when screen is opened)');
    }
  }

  // Track last refresh time
  DateTime _lastRefreshTime = DateTime.now();

  Future<void> _refreshCurrencyData() async {
    // Show full-screen loader
    TFullScreenLoader.openLoadingDialog(
      _languageController.getText('loading_currencies'),
      'assets/lottie/lottie.json',
    );

    _isLoading.value = true;
    _lastRefreshTime = DateTime.now(); // Update last refresh time

    try {
      // Use the controller's refresh method with showLoader=false since we're handling it here
      await _currencyController.refreshCurrencyData(showLoader: false);

      // Reinitialize the TabController if needed
      if (_currencyController.currencies.isNotEmpty &&
          (_tabController == null ||
              _tabController!.length !=
                  _currencyController.currencies.length)) {
        _tabController?.dispose(); // Dispose old controller if it exists
        _tabController = TabController(
          length: _currencyController.currencies.length,
          vsync: this,
        );
      }
    } catch (e) {
      print('Error refreshing currency data: $e');
      // Error will be handled in the build method
    } finally {
      _isLoading.value = false;
      // Close the loader
      TFullScreenLoader.stopLoading();
    }
  }

  // Add decimal point to the amount
  void _addDecimalPoint() {
    String currentCurrency =
        _currencyController.currencies[_tabController!.index].name;
    String currentValue = _amounts[currentCurrency] ?? '0';

    // Only add decimal if it doesn't already have one
    if (!currentValue.contains('.')) {
      _amounts[currentCurrency] = '$currentValue.';
    }
  }

  // Build the UI for each currency tab
  Widget buildCurrencyTab(Currency currency) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Obx(() => Text(
              _formatAmount(_amounts[currency.name] ?? '0'),
              style: const TextStyle(
                color: TColors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            )),
        const SizedBox(height: TSizes.spaceBtwItems),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: TColors.white.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              '${_languageController.getText('available_balance')}: ${_formatAmount(currency.availableBalance.toString())}',
              style: TextStyle(
                color: TColors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
