import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lul/common/screens/network_error_screen.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/features/wallet/contacts/contacts.dart';
import 'package:lul/features/wallet/home/home.dart';
import 'package:lul/features/wallet/settings/profile/controller/user_controller.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_check.dart';
import 'package:lul/features/wallet/settings/settings.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_controller.dart';
import 'package:lul/features/wallet/transactions/screens/transaction_history_screen.dart';
import 'package:lul/features/crowdfunding/screens/crowdfunding_hub_screen.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/helpers/network_manager.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/services/auth_service.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late final NavigationController _navigationController;
  late final UserController _userController;
  final LanguageController _languageController = Get.put(LanguageController());
  final PINController _pinController = Get.put(PINController());
  final NetworkManager _networkManager = Get.find<NetworkManager>();
  Widget? _lastScreen; // Store the actual widget
  final RxBool _showNetworkError = false.obs;

  @override
  void initState() {
    super.initState();
    print('NavigationMenu: initState');

    _navigationController = Get.put(NavigationController(), permanent: true);
    _userController = Get.find<UserController>();

    // Observe app lifecycle for PIN check
    ever(_pinController.isPinCheckRequired, (bool required) {
      if (required) {
        // Store current screen before showing PIN
        _lastScreen = _navigationController
            .screens[_navigationController.selectedIndex.value];

        Get.dialog(
          PopScope(
            canPop: false,
            child: LulCheckPinScreen(
              onSuccess: () {
                _pinController.isPinCheckRequired.value = false;
                Get.back(); // Close PIN dialog

                // Restore the exact screen
                if (_lastScreen != null) {
                  _navigationController
                          .screens[_navigationController.selectedIndex.value] =
                      _lastScreen!;
                }
              },
            ),
          ),
          barrierDismissible: false,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadUserIfAuthenticated();
    });
  }

  @override
  void dispose() {
    print('NavigationMenu: dispose');
    super.dispose();
  }

  Future<void> _loadUserIfAuthenticated() async {
    try {
      print('NavigationMenu: Checking for token');
      final token = await AuthStorage.getToken();

      if (token != null && mounted) {
        print('NavigationMenu: Token found, loading user profile');
        await _userController.loadUserProfile();
      } else if (mounted) {
        print('NavigationMenu: No token found, redirecting to login');

        /// Get.offAll(() => LoginScreen());
      }
    } catch (e) {
      print('NavigationMenu: Error loading profile - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    // Monitor network connectivity
    ever(_networkManager.hasInternetConnection, (bool hasInternet) {
      if (!hasInternet) {
        _showNetworkError.value = true;
        // Show a snackbar notification
        LulLoaders.lulcustomToast(message: 'No Internet Connection');
      } else if (_showNetworkError.value) {
        // Internet is restored
        _showNetworkError.value = false;
        LulLoaders.lulcustomToast(message: 'Internet Connection Restored');
      }
    });

    // Get the current screen for passing to NetworkErrorScreen
    final Widget currentScreen = _navigationController
        .screens[_navigationController.selectedIndex.value];

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Obx(() {
        // Show network error screen if there's no connectivity
        if (_showNetworkError.value) {
          return NetworkErrorScreen(
            onRetry: () => _networkManager.checkConnectivity(),
            previousScreen: const NavigationMenu(), // Return to NavigationMenu
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent, // Transparent AppBar
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  FontAwesomeIcons.bars,
                  color: Colors.white,
                ),
                onPressed: () {
                  FocusScope.of(context)
                      .unfocus(); // Unfocus any form and close keyboard
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
          drawer: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Drawer(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  // Custom Drawer Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                const CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person,
                                      size: 32, color: TColors.primary),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Silver",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.settings,
                                  color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Settings pressed!"),
                                ));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Obx(() => ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("User details clicked!"),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(209, 137, 202, 214)
                                        .withOpacity(0.3),
                                shadowColor: TColors.primary.withOpacity(0.3),
                                elevation: 4,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${_userController.firstName.value} ${_userController.lastName.value}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "@${_userController.username.value}",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.chevron_right,
                                        color: Colors.white),
                                  ],
                                ),
                              ),
                            )),
                        const SizedBox(height: 16),
                        /*Obx(() => Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("Withdraw pressed!"),
                                        ),
                                      );
                                    },
                                    label: Text(_languageController
                                        .getText('withdraw')),
                                    icon: const Icon(
                                        FontAwesomeIcons.circleArrowUp),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 7, 126, 102),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("Deposit pressed!"),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                        FontAwesomeIcons.circleArrowDown),
                                    label: Text(
                                        _languageController.getText('deposit')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 4, 220, 101),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )),*/
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      return ListView(
                        children: [
                          _buildDrawerItem(context,
                              index: 0,
                              icon: FontAwesomeIcons.wallet,
                              label: _languageController.getText('wallet'),
                              controller: _navigationController,
                              darkmode: dark),
                          _buildDrawerItem(context,
                              index: 1,
                              icon: FontAwesomeIcons.circleNodes,
                              label:
                                  _languageController.getText('savingcircles'),
                              controller: _navigationController,
                              darkmode: dark),
                          _buildDrawerItem(context,
                              index: 2,
                              icon: FontAwesomeIcons.handHoldingHeart,
                              label: 'Crowd Funding',
                              controller: _navigationController,
                              darkmode: dark),
                          _buildDrawerItem(context,
                              index: 3,
                              icon: FontAwesomeIcons.rightLeft,
                              label: _languageController.getText('swap'),
                              controller: _navigationController,
                              darkmode: dark),
                          _buildDrawerItem(context,
                              index: 4,
                              icon: FontAwesomeIcons.creditCard,
                              label: _languageController.getText('paymentcard'),
                              controller: _navigationController,
                              darkmode: dark),
                          _buildDrawerItem(context,
                              index: 5,
                              icon: FontAwesomeIcons.rectangleList,
                              label:
                                  _languageController.getText('transactions'),
                              controller: _navigationController,
                              darkmode: dark),
                          _buildDrawerItem(context,
                              index: 6,
                              icon: FontAwesomeIcons.userGroup,
                              label: _languageController.getText('contacts'),
                              controller: _navigationController,
                              darkmode: dark),
                          _buildDrawerItem(context,
                              index: 7,
                              icon: FontAwesomeIcons.gears,
                              label: _languageController.getText('setting'),
                              controller: _navigationController,
                              darkmode: dark),
                          _buildDrawerItem(context,
                              index: 8,
                              icon: FontAwesomeIcons.rightFromBracket,
                              label: _languageController.getText('logout'),
                              controller: _navigationController,
                              darkmode: dark),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          body: Obx(() => _navigationController
              .screens[_navigationController.selectedIndex.value]),
        );
      }),
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Show confirmation dialog
      final confirmed = await LulLoaders.alertDialog(
        title: _languageController.getText('logout'),
        message: _languageController.getText('logout_confirmation'),
      );

      if (!confirmed) return;

      // Show loading dialog
      LulLoaders.showLoadingDialog();

      // Call the enhanced logout method
      final result = await AuthService.logout();

      // Hide loading dialog
      Get.back();

      if (result['status'] == 'success') {
        // Show success dialog
        Get.find<LulLoaders>().successDialog(
          title: _languageController.getText('logout_success') ?? 'Success',
          message: result['message'] ?? 'Successfully logged out',
          onPressed: () {
            // Navigate to login screen after success dialog
            Get.offAll(() => LoginScreen());
          },
        );
      } else if (result['status'] == 'warning') {
        // Show warning dialog for partial logout
        Get.find<LulLoaders>().warningDialog(
          title: _languageController.getText('logout_warning') ?? 'Warning',
          message: result['message'] ?? 'Logout completed with warnings',
          onPressed: () {
            // Navigate to login screen even with warnings
            Get.offAll(() => LoginScreen());
          },
        );
      } else {
        // Show error dialog but still navigate to login
        Get.find<LulLoaders>().errorDialog(
          title: _languageController.getText('logout_error') ?? 'Error',
          message: result['message'] ?? 'Logout completed with errors',
          onPressed: () {
            // Navigate to login screen even with errors
            Get.offAll(() => LoginScreen());
          },
        );
      }
    } catch (e) {
      // Hide loading dialog if it's still showing
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('Logout handler error: $e');

      // Show error dialog
      Get.find<LulLoaders>().errorDialog(
        title: _languageController.getText('error') ?? 'Error',
        message: 'An unexpected error occurred during logout',
        onPressed: () {
          // Navigate to login screen as fallback
          Get.offAll(() => LoginScreen());
        },
      );
    }
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required NavigationController controller,
    required bool darkmode,
  }) {
    return Obx(() {
      final bool isSelected = controller.selectedIndex.value == index;
      return ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? TColors.primary
              : (darkmode ? Colors.white : Colors.grey),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? TColors.primary
                : (darkmode ? Colors.white : TColors.primary),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor:
            isSelected ? TColors.primary.withOpacity(0.1) : Colors.transparent,
        onTap: () async {
          if (index == 8) {
            // Logout case
            await _handleLogout();
          } else if (index == 2) {
            // Crowd Funding case - navigate directly to crowdfunding hub
            Navigator.pop(context); // Close drawer
            Get.to(() => const CrowdfundingHubScreen());
          } else {
            print('NavigationMenu: Button clicked for index $index');
            if (index == 5) {
              print(
                  'NavigationMenu: Transaction button clicked - navigating to TransactionHistoryScreen');
            }
            controller.setScreen(index);
            Navigator.pop(context);
          }
        },
      );
    });
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    Container(color: Colors.cyan),
    Container(color: Colors.orange),
    Container(color: Colors.lightBlue),
    Container(color: Colors.red),
    const TransactionHistoryScreen(),
    const LulContactsScreen(),
    SettingsScreen(),
  ];

  void setScreen(int index) {
    print('NavigationController: setScreen called with index $index');
    if (index >= 0 && index < screens.length) {
      print(
          'NavigationController: Setting selectedIndex to $index, screen: ${screens[index].runtimeType}');
      selectedIndex.value = index;
    } else {
      print('NavigationController: Invalid index $index');
      Get.snackbar(
        "Error",
        "Invalid menu option selected. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
