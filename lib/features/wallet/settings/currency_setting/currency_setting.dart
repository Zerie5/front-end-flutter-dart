import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_controller.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/setting_currency_tile.dart';
// The widget for individual tiles
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class YourCurrencyScreen extends StatefulWidget {
  const YourCurrencyScreen({super.key});

  @override
  State<YourCurrencyScreen> createState() => _YourCurrencyScreenState();
}

class _YourCurrencyScreenState extends State<YourCurrencyScreen>
    with WidgetsBindingObserver {
  final CurrencyController _currencyController = Get.find<CurrencyController>();
  final LanguageController _languageController = Get.find<LanguageController>();

  // Track last refresh time
  DateTime _lastRefreshTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Check if user is logged in before refreshing currency data
    _checkLoginAndRefreshData();
  }

  @override
  void dispose() {
    // Unregister from lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkLoginAndRefreshData() async {
    final token = await AuthStorage.getToken();
    if (token != null) {
      print('CurrencyScreen: User is logged in, refreshing currency data');
      _refreshCurrencyData();
    } else {
      print('CurrencyScreen: User is not logged in, skipping currency refresh');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // We no longer refresh on app resume
    // Currency data will only be refreshed when the screen is first opened
    if (state == AppLifecycleState.resumed) {
      print(
          'CurrencyScreen: App resumed, but not refreshing currency data (will only refresh when screen is opened)');
    }
  }

  Future<void> _refreshCurrencyData() async {
    // Use the controller's refresh method with the built-in loader
    await _currencyController.refreshCurrencyData(showLoader: true);
    _lastRefreshTime = DateTime.now(); // Update last refresh time

    // Print debug info
    print(
        "Currency screen refreshed with ${_currencyController.currencies.length} currencies");
    for (var currency in _currencyController.currencies) {
      print(
          "Currency: ${currency.code}, Balance: ${currency.availableBalance}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          _languageController.getText('myasset'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshCurrencyData,
          ),
        ],
      ),
      backgroundColor: dark ? TColors.primaryDark : TColors.primary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Obx(() {
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

          final currencies = _currencyController.currencies;
          print("Building currency list with ${currencies.length} currencies");

          if (currencies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No currencies available",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshCurrencyData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: TColors.primary,
                    ),
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              print(
                  "Building tile for ${currency.code} with balance ${currency.availableBalance}");

              return SettingCurrencyTile(
                context: context,
                countryCode: currency.countryCode,
                nameKey: currency.name,
                descriptionKey: currency.description,
                balance:
                    currency.availableBalance, // Explicitly pass the balance
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${currency.name} selected")),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}
