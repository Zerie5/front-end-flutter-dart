import 'package:get/get.dart';
import 'package:lul/services/currency_service.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/utils/popups/full_screen_loader.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'currency_model.dart';
import 'package:flutter/widgets.dart';

class CurrencyController extends GetxController with WidgetsBindingObserver {
  final RxList<Currency> currencies = <Currency>[].obs;
  final RxBool isRefreshing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Add a static flag to disable refreshes during PIN check
  static bool isPinCheckActive = false;

  // Get the currency service
  final CurrencyService _currencyService = Get.find<CurrencyService>();

  // Track if initial data has been loaded
  bool _initialDataLoaded = false;

  // Track last refresh time
  DateTime _lastRefreshTime = DateTime.now();

  @override
  void onInit() {
    super.onInit();

    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // We no longer automatically load data on initialization
    // This will be done after login instead
    print('CurrencyController: Initialized, waiting for login to load data');
  }

  @override
  void onClose() {
    // Unregister from lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // We no longer refresh on app resume
    // Currency data will only be refreshed when explicitly requested
    if (state == AppLifecycleState.resumed) {
      // Just log that we're resuming but don't refresh
      print(
          'CurrencyController: App resumed, but not refreshing currency data (will only refresh when screens are opened)');
    }
  }

  // Method to load initial data - now only called explicitly after login
  Future<void> loadInitialData() async {
    if (_initialDataLoaded) {
      print('CurrencyController: Initial data already loaded, skipping');
      return;
    }

    final token = await AuthStorage.getToken();
    if (token != null) {
      print('CurrencyController: Token found, loading initial currency data');
      await fetchWallets();
      _initialDataLoaded = true;
      _lastRefreshTime = DateTime.now(); // Update last refresh time
    } else {
      print(
          'CurrencyController: No token found, skipping initial currency load');
    }
  }

  // Public method to refresh currency data when needed
  // Call this when navigating to screens that display currency
  Future<void> refreshCurrencyData({bool showLoader = true}) async {
    // Check if PIN check is active - if so, skip refresh
    if (isPinCheckActive) {
      print('CurrencyController: PIN check is active, skipping refresh');
      return;
    }

    // Also check route as a fallback
    if (Get.currentRoute.contains('CheckPinScreen')) {
      print('CurrencyController: PIN screen is active, skipping refresh');
      return;
    }

    final token = await AuthStorage.getToken();
    if (token == null) {
      print('CurrencyController: No token available for refresh');
      hasError.value = true;
      errorMessage.value = 'Authentication required. Please log in.';
      return;
    }

    // Only show loader if requested (some screens may handle their own loading UI)
    if (showLoader) {
      final languageController = Get.find<LanguageController>();
      TFullScreenLoader.openLoadingDialog(
        languageController.getText('loading_currencies'),
        'assets/lottie/lottie.json',
      );
    }

    try {
      print(
          'CurrencyController: Refreshing currency data with token: ${token.substring(0, 10)}...');
      await fetchWallets();
      _lastRefreshTime = DateTime.now(); // Update last refresh time
    } finally {
      // Close loader if it was shown
      if (showLoader && Get.isDialogOpen == true) {
        TFullScreenLoader.stopLoading();
      }
    }
  }

  // Method to fetch wallets using the service
  Future<void> fetchWallets() async {
    // Don't start another refresh if one is already in progress
    if (isRefreshing.value) {
      print('CurrencyController: Refresh already in progress, skipping');
      return;
    }

    isRefreshing.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      print('CurrencyController: Fetching wallet data from API');

      // First check if we have a token
      final token = await AuthStorage.getToken();
      if (token == null) {
        print('CurrencyController: No auth token available');
        hasError.value = true;
        errorMessage.value = 'Authentication required. Please log in.';
        isRefreshing.value = false;
        return;
      }

      // Call the service to fetch wallet data
      final responseData = await _currencyService.fetchWallets();

      if (responseData != null) {
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> wallets = responseData['data'];

          if (wallets.isNotEmpty) {
            print(
                'CurrencyController: Fetched ${wallets.length} wallets from API');

            // Process the wallet data
            updateCurrenciesFromLogin(wallets);
          } else {
            print('CurrencyController: No wallets returned from API');
            // Empty wallet list is valid - just clear the currencies
            currencies.clear();
          }
        } else {
          // Handle error response
          print(
              'CurrencyController: Error response from API: ${responseData['code']}');
          hasError.value = true;

          // Use the error message from the service
          errorMessage.value =
              responseData['message'] ?? 'Failed to load currency data';

          // Handle specific error codes
          if (responseData['code'] == 'ERR_TIMEOUT') {
            errorMessage.value =
                'The server is taking too long to respond. This might be due to network issues or high server load. Please try again later.';
          } else if (responseData['code'] == 'ERR_CONNECTION') {
            errorMessage.value =
                'Connection error. Please check your internet connection and try again.';
          } else if (responseData['code'] == 'ERR_502') {
            errorMessage.value =
                'Your session has expired. Please log in again.';
            // TODO: Navigate to login screen or show login dialog
          }

          // If we have no data at all, try to use cached data if available
          if (currencies.isEmpty && !_initialDataLoaded) {
            // Load cached data if available (implement caching if needed)
          }
        }
      } else {
        print('CurrencyController: Failed to fetch wallet data');
        hasError.value = true;
        errorMessage.value =
            'Failed to load currency data. Please check your connection.';

        // If we have no data at all, try to use cached data if available
        if (currencies.isEmpty && !_initialDataLoaded) {
          // Load cached data if available (implement caching if needed)
        }
      }
    } catch (e) {
      print('CurrencyController: Error processing wallet data: $e');
      hasError.value = true;

      // Check if it's an authentication error
      if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage.value = 'Authentication error. Please log in again.';
      } else {
        errorMessage.value = 'Error loading currency data. Please try again.';
      }
    } finally {
      isRefreshing.value = false;
    }
  }

  // Method to update currencies from wallet data
  void updateCurrenciesFromLogin(List<dynamic> wallets) {
    if (wallets.isEmpty) {
      currencies.clear();
      return;
    }

    try {
      final List<Currency> fetchedCurrencies = wallets.map((wallet) {
        final double balance = (wallet['availableBalance'] ?? 0.0).toDouble();
        final int id = wallet['id'] ?? 0;
        final int walletTypeId = wallet['walletTypeId'] ?? 0;

        return Currency(
          id: id,
          walletTypeId: walletTypeId,
          countryCode: wallet['countryCode'] ?? '',
          name: wallet['name'] ?? '',
          description: wallet['description'] ?? '',
          availableBalance: balance,
          code: wallet['code'] ?? '',
        );
      }).toList();

      // Update the observable list
      currencies.assignAll(fetchedCurrencies);

      print(
          'CurrencyController: Updated ${fetchedCurrencies.length} currencies');

      // Debug print each currency with its ID and wallet type ID
      for (var currency in fetchedCurrencies) {
        print(
            'Currency: ${currency.code}, ID: ${currency.id}, WalletTypeID: ${currency.walletTypeId}, Balance: ${currency.availableBalance}');
      }

      // Save to cache if needed
      // _saveCurrenciesToCache(fetchedCurrencies);
    } catch (e) {
      print('CurrencyController: Error parsing wallet data: $e');
      hasError.value = true;
      errorMessage.value = 'Error processing currency data';
    }
  }

  // Keep the simulation method for fallback
  /* void simulateFetchCurrencies() {
    final fetchedCurrencies = [
      Currency(
        countryCode: 'us',
        name: 'dollartitle',
        description: 'dollaricon',
        availableBalance: 10030.35,
        code: 'USD',
      ),
      Currency(
        countryCode: 'ug',
        name: 'ugandanshillingtitle',
        description: 'ugandanshillingicon',
        availableBalance: 5000000.00,
        code: 'UGX',
      ),
      Currency(
        countryCode: 'et',
        name: 'ethiopianbirrtitle',
        description: 'ethiopianbirrcon',
        availableBalance: 5000000.00,
        code: 'ETB',
      ),
      Currency(
        countryCode: 'ke',
        name: 'kenyashillingtitle',
        description: 'kenyashillingicon',
        availableBalance: 5000000.00,
        code: 'KES',
      ),
      Currency(
        countryCode: 'ss',
        name: 'southsudanshillingtitle',
        description: 'southsudanshillingicon',
        availableBalance: 5000000.00,
        code: 'SSP',
      ),
    ];

    currencies.assignAll(fetchedCurrencies);
    print(
        'CurrencyController: Using simulated currency data with ${currencies.length} currencies');

    // Debug print each currency
    for (var currency in currencies) {
      print(
          'Simulated Currency: ${currency.code}, Balance: ${currency.availableBalance}');
    }
  }*/
}
