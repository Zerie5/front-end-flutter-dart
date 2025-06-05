import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/screens/network_error_screen.dart';
import 'package:lul/common/widgets/pin/create_new_pin.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/features/authentication/screens/otp/otp_verify.dart';
import 'package:lul/features/wallet/settings/profile/controller/user_controller.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_controller.dart';
import 'package:lul/navigation_menu.dart';
import 'package:lul/utils/constants/text_strings.dart';
import 'package:lul/utils/helpers/network_manager.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/theme/theme.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_controller.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/services/currency_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lul/services/fcm_service.dart';
import 'package:lul/services/notification_service.dart';
import 'package:lul/services/user_lookup_service.dart';
import 'package:lul/services/transaction_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  static bool _dependenciesInitialized = false;

  static Future<void> initDependencies() async {
    // Avoid initializing dependencies multiple times
    if (_dependenciesInitialized) return;
    _dependenciesInitialized = true;

    print('App: Initializing dependencies');

    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize notification service
    await NotificationService.initialize();

    // Initialize FCM Service
    await Get.putAsync(() => FCMService().init());

    // Initialize Currency Service
    await Get.putAsync(() => CurrencyService().init());

    // Initialize Transaction Service
    await Get.putAsync(() => TransactionService().init());

    Get.put(LulLoaders());
    Get.put(LanguageController());
    // Initialize PINController with proper lifecycle binding.
    final pinController = PINController();
    Get.put(pinController);
    WidgetsBinding.instance.addObserver(pinController);
    Get.put(UserController());

    // Initialize CurrencyController after CurrencyService
    final currencyController = CurrencyController();
    Get.put(currencyController);

    // Initialize UserLookupService
    await Get.putAsync(() => UserLookupService().init());

    // Add other dependencies as needed.
  }

  Widget _getInitialScreen() {
    // First check for network connectivity
    final NetworkManager networkManager = Get.find<NetworkManager>();

    return Obx(() {
      // If bypassing connectivity checks, proceed with normal app flow
      if (networkManager.bypassConnectivityChecks.value) {
        return _getAuthenticatedScreen();
      }

      // If there's no internet connection, show the network error screen
      if (!networkManager.hasInternetConnection.value) {
        return NetworkErrorScreen(
          onRetry: () => networkManager.checkConnectivity(),
          // No previousScreen here since we're just starting the app
        );
      }

      // If there's internet but no server connection, show the network error screen
      if (!networkManager.hasServerConnection.value) {
        return NetworkErrorScreen(
          onRetry: () => networkManager.checkConnectivity(),
          // No previousScreen here since we're just starting the app
        );
      }

      // If we have connectivity, proceed with normal app flow
      return _getAuthenticatedScreen();
    });
  }

  // Helper method to get the authenticated screen based on token and registration stage
  Widget _getAuthenticatedScreen() {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        AuthStorage.getToken().then((token) => {'token': token}),
        AuthStorage.getRegistrationStage().then((stage) => {'stage': stage}),
      ]).then((results) => {...results[0], ...results[1]}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final token = snapshot.data?['token'] as String?;
        final stage = snapshot.data?['stage'] as int?;

        if (token == null) {
          print('App: No token found, showing login screen');
          return LoginScreen();
        }

        print('App: Token found, checking registration stage: $stage');

        // Check registration stage
        switch (stage) {
          case 2: // Basic registration done
            return const LulOtpVerifyScreen();
          case 3: // OTP verified
            return const CreatePinScreen();
          case 4: // Fully activated
            print('App: User fully activated, proceeding to main app');
            // Don't trigger PIN check here - let PINController handle it
            // This avoids duplicate PIN checks
            return const NavigationMenu();
          default:
            print('App: Invalid registration stage, showing login screen');
            return LoginScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Don't call initDependencies here since it's already called in main.dart

    return GetMaterialApp(
      title: TTexts.appName,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
      locale: Locale(
          Get.find<LanguageController>().selectedLanguage.value.toString()),
      home: _getInitialScreen(),
      onDispose: () {
        final pinController = Get.find<PINController>();
        WidgetsBinding.instance.removeObserver(pinController);
        Get.delete<PINController>();
      },
    );
  }
}
