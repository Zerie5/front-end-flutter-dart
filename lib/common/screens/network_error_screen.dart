import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/network_manager.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_check.dart';
import 'package:lul/navigation_menu.dart';

class NetworkErrorScreen extends StatefulWidget {
  final VoidCallback onRetry;
  final Widget? previousScreen;

  const NetworkErrorScreen({
    super.key,
    required this.onRetry,
    this.previousScreen,
  });

  @override
  State<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen> {
  @override
  void initState() {
    super.initState();
    // Set up a listener to automatically navigate back when connectivity is restored
    final NetworkManager networkManager = Get.find<NetworkManager>();

    // Listen for changes in connectivity
    ever(networkManager.hasInternetConnection, (bool hasInternet) async {
      if (hasInternet && networkManager.hasServerConnection.value) {
        await _navigateToAppropriateScreen();
      }
    });

    ever(networkManager.hasServerConnection, (bool hasServer) async {
      if (hasServer && networkManager.hasInternetConnection.value) {
        await _navigateToAppropriateScreen();
      }
    });
  }

  Future<void> _navigateToAppropriateScreen() async {
    // If we have a previous screen, return to it
    if (widget.previousScreen != null) {
      Get.off(() => widget.previousScreen!);
      return;
    }

    // Otherwise, check authentication status and navigate accordingly
    final token = await AuthStorage.getToken();
    if (token != null) {
      // User is logged in, show PIN check then NavigationMenu
      Get.off(() => LulCheckPinScreen(
            maxAttempts: 3,
            onSuccess: () => Get.offAll(() => const NavigationMenu()),
          ));
    } else {
      // User is not logged in, show login screen
      Get.off(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final NetworkManager networkManager = Get.find<NetworkManager>();
    final LanguageController languageController =
        Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: TColors.primary,
      body: SafeArea(
        child: Obx(() {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildConnectionStatusIcon(networkManager),
                const SizedBox(height: 24),
                Text(
                  networkManager.isCheckingConnection.value
                      ? languageController.getText('checking_connection') ??
                          'Checking Connection...'
                      : !networkManager.hasInternetConnection.value
                          ? languageController.getText('no_internet') ??
                              'No Internet Connection'
                          : !networkManager.hasServerConnection.value
                              ? languageController.getText('no_server') ??
                                  'Server Unavailable'
                              : languageController
                                      .getText('connection_restored') ??
                                  'Connection Restored',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _getDescriptionText(networkManager, languageController),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: widget.onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.secondary,
                    foregroundColor: TColors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    languageController.getText('retry') ?? 'Retry',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                // Only show "Continue Anyway" button if we have internet but no server connection
                if (networkManager.hasInternetConnection.value &&
                    !networkManager.hasServerConnection.value)
                  TextButton(
                    onPressed: () {
                      // Bypass connectivity checks and continue to the app
                      networkManager.setBypassConnectivityChecks(true);
                      _navigateToAppropriateScreen();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: TColors.white,
                    ),
                    child: Text(
                      languageController.getText('continue_anyway') ??
                          'Continue Anyway',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConnectionStatusIcon(NetworkManager networkManager) {
    if (networkManager.isCheckingConnection.value) {
      return const Icon(
        Icons.wifi_find,
        size: 100,
        color: Colors.amber,
      );
    } else if (!networkManager.hasInternetConnection.value) {
      return const Icon(
        Icons.wifi_off,
        size: 100,
        color: Colors.red,
      );
    } else if (!networkManager.hasServerConnection.value) {
      // Different icons based on the specific server connectivity issue
      final message = networkManager.connectionMessage.value;

      if (message.contains('Server not reachable')) {
        return const Icon(
          Icons.cloud_off,
          size: 100,
          color: Colors.red,
        );
      } else {
        return const Icon(
          Icons.cloud_off,
          size: 100,
          color: Colors.orange,
        );
      }
    } else {
      return const Icon(
        Icons.cloud_done,
        size: 100,
        color: Colors.green,
      );
    }
  }

  String _getDescriptionText(
      NetworkManager networkManager, LanguageController languageController) {
    if (networkManager.isCheckingConnection.value) {
      return languageController.getText('checking_connection_desc') ??
          'Please wait while we check your connection...';
    } else if (!networkManager.hasInternetConnection.value) {
      return languageController.getText('no_internet_desc') ??
          'Please check your internet connection and try again.';
    } else if (!networkManager.hasServerConnection.value) {
      // Get the detailed connection message
      final message = networkManager.connectionMessage.value;

      if (message.contains('Server not reachable')) {
        return languageController.getText('server_unreachable') ??
            'We can\'t reach the server. Please check your network configuration or try again later.';
      } else {
        return languageController.getText('no_server_desc') ??
            'We can\'t connect to our servers right now. Please try again later.';
      }
    } else {
      return languageController.getText('connection_restored_desc') ??
          'Your connection has been restored! You can continue using the app.';
    }
  }
}
