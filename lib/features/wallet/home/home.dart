import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lul/common/widgets/custom_shapes/circular_container.dart';
import 'package:lul/features/wallet/home/widgets/build_currency_items.dart';
import 'package:lul/features/wallet/home/widgets/build_quickaction.dart';
import 'package:lul/features/wallet/recieve/screens/qr_code_screen.dart';
import 'package:lul/features/wallet/recieve/screens/scan_user_id_screen.dart';
import 'package:lul/features/wallet/recieve/bindings/scan_user_id_binding.dart';
import 'package:lul/features/wallet/send/send_choice.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_controller.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lul/features/wallet/home/widgets/build_promo_card.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/features/wallet/settings/profile/controller/user_controller.dart';
import 'package:lul/features/wallet/deposit/screens/wallet_selection_screen.dart';
import 'package:lul/features/wallet/deposit/controllers/deposit_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool isObscured = true; // State to track whether the value is obscured
  final LanguageController _languageController = Get.find<LanguageController>();
  final CurrencyController _currencyController = Get.find<CurrencyController>();
  final UserController _userController = Get.find<UserController>();
  DateTime _lastRefreshTime = DateTime.now();
  // Non-reactive portfolio value
  String portfolioValue = "\$0.00";

  @override
  void initState() {
    super.initState();
    // Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Check if user is logged in before refreshing currency data
    _checkLoginAndRefreshData();

    // Load user profile
    _loadUserProfile();
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
      print('HomeScreen: User is logged in, refreshing currency data');
      _refreshCurrencyData();
    } else {
      print('HomeScreen: User is not logged in, skipping currency refresh');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // We no longer refresh on app resume
    // Currency data will only be refreshed when the screen is first opened
    if (state == AppLifecycleState.resumed) {
      print(
          'HomeScreen: App resumed, but not refreshing currency data (will only refresh when screen is opened)');
    }
  }

  Future<void> _refreshCurrencyData() async {
    await _currencyController.refreshCurrencyData(showLoader: false);
    _lastRefreshTime = DateTime.now();
    _updatePortfolioValue();
  }

  // Update the portfolio value based on currency data
  void _updatePortfolioValue() {
    if (_currencyController.hasError.value ||
        _currencyController.isRefreshing.value ||
        _currencyController.currencies.isEmpty) {
      setState(() {
        portfolioValue = "\$0.00";
      });
      return;
    }

    double total = 0.0;

    // Sum up all currency balances
    for (var currency in _currencyController.currencies) {
      total += currency.availableBalance;
    }

    // Format the total with dollar sign and commas
    setState(() {
      portfolioValue =
          "\$${total.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
    });
  }

  Future<void> _loadUserProfile() async {
    await _userController.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    // Portfolio Value calculated from currencies
    final dark = THelperFunctions.isDarkMode(context);

    // Screen dimensions for responsive design
    final double screenWidth = MediaQuery.of(context).size.width;
    final double monetaryFontSize = screenWidth > 400 ? 55 : 45;
    final double buttonSize = screenWidth > 400 ? 60 : 50;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Section with Circular Decorations
                Container(
                  color: TColors.primary,
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                    height: 400,
                    child: Stack(
                      children: [
                        // Circular Decorations
                        Positioned(
                          top: -150,
                          right: -250,
                          child: LCircularContainer(
                              backgroundColor:
                                  TColors.textWhite.withOpacity(0.1)),
                        ),
                        Positioned(
                          top: 100,
                          right: -300,
                          child: LCircularContainer(
                              backgroundColor:
                                  TColors.textWhite.withOpacity(0.1)),
                        ),

                        // User ID at the top
                        Positioned(
                          top: 40,
                          left: 0,
                          right: 0,
                          child: Obx(() {
                            return Center(
                              child: Column(
                                children: [
                                  Text(
                                    _languageController.getText('user_id'),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userController.userId.value.isNotEmpty
                                        ? _userController.userId.value
                                        : "",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),

                        // Portfolio Header
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Obx(() {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _languageController
                                            .getText('Total Value'),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Tooltip(
                                        message: isObscured
                                            ? "Show value"
                                            : "Hide value",
                                        child: GestureDetector(
                                          onTap: _toggleObscureState,
                                          child: Icon(
                                            isObscured
                                                ? Iconsax.eye
                                                : Iconsax.eye_slash,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              // Monetary Value
                              GestureDetector(
                                onTap: _toggleObscureState,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    isObscured ? "***" : portfolioValue,
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      color: Colors.white,
                                      fontSize: monetaryFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quick Action Buttons
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Obx(() {
                                return BuildQuickActionButton(
                                  context: context,
                                  icon: FontAwesomeIcons.paperPlane,
                                  label: _languageController.getText('send_hm'),
                                  buttonSize: buttonSize,
                                  onPressed: () {
                                    Get.to(() => LulSendChoiceScreen());
                                  },
                                );
                              }),
                              Obx(() {
                                return BuildQuickActionButton(
                                  context: context,
                                  icon: FontAwesomeIcons.download,
                                  label:
                                      _languageController.getText('recieve_hm'),
                                  buttonSize: buttonSize,
                                  onPressed: () {
                                    Get.to(() => const QrCodeScreen());
                                  },
                                );
                              }),
                              Obx(() {
                                return BuildQuickActionButton(
                                  context: context,
                                  icon: FontAwesomeIcons.moneyCheckDollar,
                                  label: _languageController.getText('pay_hm'),
                                  buttonSize: buttonSize,
                                  onPressed: () async {
                                    Get.to(
                                      () => const ScanUserIdScreen(),
                                      binding: ScanUserIdBinding(),
                                    );
                                  },
                                );
                              }),
                              Obx(() {
                                return BuildQuickActionButton(
                                  context: context,
                                  icon: FontAwesomeIcons.circleDollarToSlot,
                                  label: _languageController
                                      .getText('raisefunds_hm'),
                                  buttonSize: buttonSize,
                                  onPressed: () {
                                    // Initialize DepositController and navigate to wallet selection
                                    Get.put(DepositController());
                                    Get.to(() => const WalletSelectionScreen());
                                  },
                                );
                              }),
                              Obx(() {
                                return BuildQuickActionButton(
                                  context: context,
                                  icon: FontAwesomeIcons.rightLeft,
                                  label: _languageController.getText('swap_hm'),
                                  buttonSize: buttonSize,
                                  onPressed: () => {},
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Promotional Section
                const SizedBox(height: 20),
                CarouselSlider(
                  items: [
                    Obx(() {
                      return BuildPromoCard(
                        title: _languageController.getText('slider1title'),
                        description:
                            _languageController.getText('slider1subtitle'),
                        backgroundColor: Colors.amber.withOpacity(0.2),
                        darkMode: dark,
                      );
                    }),
                    Obx(() {
                      return BuildPromoCard(
                        title: _languageController.getText('slider2title'),
                        description:
                            _languageController.getText('slider2subtitle'),
                        backgroundColor: Colors.green.withOpacity(0.2),
                        darkMode: dark,
                      );
                    }),
                  ],
                  options: CarouselOptions(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.height * 0.18
                        : MediaQuery.of(context).size.height * 0.25,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                  ),
                ),

                // My Currency Section
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _languageController.getText('myasset'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("Search clicked")));
                                  },
                                  icon: const Icon(Iconsax.search_normal),
                                ),
                                IconButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text("Filter clicked")));
                                  },
                                  icon: const Icon(Iconsax.setting_4),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 10),
                      _buildCurrencySection(context),
                    ],
                  ),
                ),

                // Footer Button - Add Asset
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Add Asset pressed!")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.add, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            _languageController.getText('Add Currency'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to toggle the obscured state
  void _toggleObscureState() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  // Currency Section with improved inline loader
  Widget _buildCurrencySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Obx(() {
        // Show loading indicator if refreshing
        if (_currencyController.isRefreshing.value) {
          return Container(
            height: 150,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: TColors.primary),
                const SizedBox(height: 10),
                Text(
                  _languageController.getText('loading_currencies'),
                  style: const TextStyle(
                    color: TColors.primary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Show error message if there's an error
        if (_currencyController.hasError.value) {
          return Container(
            height: 150,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: TColors.primary, size: 32),
                const SizedBox(height: 10),
                Text(
                  _currencyController.errorMessage.value,
                  style: const TextStyle(color: TColors.primary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _refreshCurrencyData,
                  icon: const Icon(Icons.refresh, color: TColors.primary),
                  label: Text(
                    _languageController.getText('refresh'),
                    style: const TextStyle(color: TColors.primary),
                  ),
                ),
              ],
            ),
          );
        }

        // Show empty state if no currencies
        if (_currencyController.currencies.isEmpty) {
          return Container(
            height: 150,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _languageController.getText('no_currencies'),
                  style: const TextStyle(color: TColors.primary, fontSize: 14),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _refreshCurrencyData,
                  icon: const Icon(Icons.refresh, color: TColors.primary),
                  label: Text(
                    _languageController.getText('refresh'),
                    style: const TextStyle(color: TColors.primary),
                  ),
                ),
              ],
            ),
          );
        }

        // Show currencies
        return Column(
          children: _currencyController.currencies
              .map((currency) => BuildCurrencyItem(
                    context: context,
                    countryCode: currency.countryCode,
                    nameKey: currency.name,
                    descriptionKey: currency.description,
                    balance: currency.availableBalance,
                  ))
              .toList(),
        );
      }),
    );
  }
}
