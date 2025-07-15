import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lul/services/pin_service.dart';
import 'package:lul/features/wallet/settings/security_setting/widgets/pin_check.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:lul/features/wallet/settings/currency_setting/widget/currency_controller.dart';
import 'package:lul/features/authentication/screens/login/login.dart';
import 'package:lul/features/authentication/screens/otp/otp_verify.dart';
import 'package:lul/common/widgets/pin/create_new_pin.dart';
import 'package:lul/services/token_manager.dart';

class PINController extends GetxController with WidgetsBindingObserver {
  final RxBool isPinEnabled = true.obs;
  final RxBool isPinCheckRequired = false.obs;
  final RxBool isLoading = false.obs;
  String? _lastRoute; // Store full route instead of just index
  bool _isCheckingPin = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('PINController: Lifecycle state changed to $state');

    switch (state) {
      case AppLifecycleState.paused:
        // Before storing route and setting check required, check if token and proper stage exist
        final token = await AuthStorage.getToken();
        final registrationStage = await AuthStorage.getRegistrationStage();

        print('PINController: paused - token exists: ${token != null}');
        print('PINController: paused - registration stage: $registrationStage');

        // Only set PIN check required if user is fully activated (stage 4)
        if (token != null && registrationStage == 4) {
          // Store current route
          _lastRoute = Get.currentRoute;
          isPinCheckRequired.value = true;
          print('PINController: Stored route: $_lastRoute, PIN check enabled');
        } else {
          print(
              'PINController: Skipping PIN check setup - not fully activated user');
          isPinCheckRequired.value = false;
        }
        break;

      case AppLifecycleState.resumed:
        // Only proceed if PIN check is required and we're not already checking
        if (isPinEnabled.value && isPinCheckRequired.value && !_isCheckingPin) {
          _isCheckingPin = true;

          // CRITICAL FIX: Check for token AND registration stage FIRST before proceeding with PIN check
          try {
            final token = await AuthStorage.getToken();
            final registrationStage = await AuthStorage.getRegistrationStage();

            // Add detailed logging to debug the issue
            print(
                'PINController: Token exists: ${token != null && token.isNotEmpty}');
            print('PINController: Registration stage: $registrationStage');

            // If no token exists, user is logged out, redirect to login
            if (token == null || token.isEmpty) {
              print('PINController: No token found, skipping PIN check');
              isPinCheckRequired.value = false;
              _isCheckingPin = false;
              CurrencyController.isPinCheckActive = false;

              // If not already on login screen, navigate to login
              if (Get.currentRoute != '/login') {
                print('PINController: Redirecting to login page');
                Get.offAll(() => LoginScreen());
              }
              return;
            }

            // SECURITY CRITICAL: Registration stage must be EXACTLY 4 to show PIN check
            // This is a security requirement - PIN check must only be shown for fully activated users
            if (registrationStage != 4) {
              print(
                  'PINController: Registration stage $registrationStage is not 4, skipping PIN check');
              isPinCheckRequired.value = false;
              _isCheckingPin = false;
              CurrencyController.isPinCheckActive = false;

              // Redirect based on registration stage
              switch (registrationStage) {
                case 2: // Basic registration done, needs OTP verification
                  print('PINController: Redirecting to OTP verification');
                  Get.offAll(() => const LulOtpVerifyScreen());
                  break;
                case 3: // OTP verified, needs PIN creation
                  print('PINController: Redirecting to Create PIN screen');
                  Get.offAll(() => const CreatePinScreen());
                  break;
                default: // Unknown stage, safer to redirect to login
                  print(
                      'PINController: Unknown registration stage, redirecting to login');
                  Get.offAll(() => LoginScreen());
              }
              return;
            }

            // Manually check the current route to avoid showing PIN checks during registration flow
            final currentRoute = Get.currentRoute;
            if (currentRoute == '/LulOtpVerifyScreen' ||
                currentRoute == '/CreatePinScreen' ||
                currentRoute == '/login') {
              print(
                  'PINController: On registration/login flow screen ($currentRoute), skipping PIN check');
              isPinCheckRequired.value = false;
              _isCheckingPin = false;
              CurrencyController.isPinCheckActive = false;
              return;
            }

            // ENHANCED: Handle token refresh before PIN check
            print(
                'PINController: Handling app resume - checking token status...');

            try {
              final tokenManager = TokenManager.instance;
              await tokenManager.onAppResume();
              print('PINController: Token refresh handling completed');
            } catch (e) {
              print('PINController: Error during token refresh handling: $e');
              // Continue with PIN check even if token refresh fails
            }

            // Token exists and stage is 4, proceed with PIN check
            print(
                'PINController: Token found and registration stage is 4, showing PIN check dialog');

            // Set the flag to disable currency refreshes
            CurrencyController.isPinCheckActive = true;

            // Clear any existing dialogs before showing new one
            while (Get.isDialogOpen ?? false) {
              Get.back();
            }

            // Show PIN check dialog
            await Get.dialog(
              PopScope(
                canPop: false,
                child: LulCheckPinScreen(
                  maxAttempts: 3,
                  onSuccess: () {
                    print('PINController: PIN check successful');
                    isPinCheckRequired.value = false;
                    _isCheckingPin = false;
                    // Clear the flag when PIN check is successful
                    CurrencyController.isPinCheckActive = false;
                    Get.back();

                    // Restore last route
                    if (_lastRoute != null && _lastRoute != Get.currentRoute) {
                      print('PINController: Navigating to route $_lastRoute');
                      Get.toNamed(_lastRoute!);
                    }
                  },
                  onFailure: () {
                    print('PINController: PIN check failed');
                    _isCheckingPin = false;
                    // Clear the flag when PIN check fails
                    CurrencyController.isPinCheckActive = false;
                  },
                ),
              ),
              barrierDismissible: false,
            );
          } catch (e) {
            // Handle any errors during token check
            print('PINController: Error checking token: $e');
            _isCheckingPin = false;
            CurrencyController.isPinCheckActive = false;
          }
        }
        break;

      default:
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Initialize with PIN check not required
    isPinCheckRequired.value = false;
    print('PINController: Initialized with isPinCheckRequired = false');

    // Check registration stage on init for debugging
    AuthStorage.getRegistrationStage().then((stage) {
      print('PINController: Current registration stage on init = $stage');
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // Toggle whether PIN is enabled.
  void togglePin(bool value) {
    isPinEnabled.value = value;
  }

  // Validate the entered PIN via the backend.
  // Return a Map with validation result and error information
  Future<Map<String, dynamic>> validatePin(String pin) async {
    try {
      print('PINController: Validating PIN');
      final response = await PinService.verifyPin(pin);
      print('PIN Controller response: $response');

      if (response['status'] == 'success' &&
          response['data'] != null &&
          response['data']['isValid'] == true) {
        return {'isValid': true};
      }

      // Handle different error codes
      final errorCode = response['code'];
      final errorMessage = response['message'] ?? 'PIN verification failed';

      switch (errorCode) {
        case 'ERR_502': // Invalid Token
          // Handle session expiry - return special flag to redirect to login
          return {
            'isValid': false,
            'errorType': 'session_expired',
            'errorCode': errorCode,
            'errorMessage': errorMessage
          };

        case 'ERR_652': // PIN not set
          // Handle PIN not set - return special flag to redirect to PIN setup
          return {
            'isValid': false,
            'errorType': 'pin_not_set',
            'errorCode': errorCode,
            'errorMessage': errorMessage
          };

        case 'ERR_655': // Connectivity issue
          // Handle connectivity issues - don't count against attempts
          return {
            'isValid': false,
            'errorType': 'connectivity',
            'errorCode': errorCode,
            'errorMessage': errorMessage
          };

        case 'ERR_651': // Wrong PIN
          // Handle wrong PIN - count against attempts
          return {
            'isValid': false,
            'errorType': 'wrong_pin',
            'errorCode': errorCode,
            'errorMessage': errorMessage
          };

        default:
          // Handle other errors
          return {
            'isValid': false,
            'errorType': 'general_error',
            'errorCode': errorCode,
            'errorMessage': errorMessage
          };
      }
    } catch (e) {
      print('PIN validation error: $e');
      return {
        'isValid': false,
        'errorType': 'exception',
        'errorMessage': e.toString()
      };
    }
  }

  // Update the PIN (e.g. during creation/updating) via the backend.
  Future<bool> updatePin(String newPin) async {
    if (!isLoading.value) {
      isLoading.value = true;
      try {
        final response = await PinService.updatePin(newPin);

        if (response['status'] == 'success') {
          return true;
        }

        // Handle specific error codes.
        switch (response['code']) {
          case 'ERR_650': // PIN Verification Failed
            Get.find<LulLoaders>().errorDialog(
              title: Get.find<LanguageController>().getText('error'),
              message: Get.find<LanguageController>().getText('err_650'),
            );
            break;
          case 'ERR_651': // PIN Not Set
            Get.find<LulLoaders>().errorDialog(
              title: Get.find<LanguageController>().getText('error'),
              message: Get.find<LanguageController>().getText('err_651'),
            );
            break;
          case 'ERR_502': // Invalid Token
            Get.find<LulLoaders>().errorDialog(
              title: Get.find<LanguageController>().getText('error'),
              message: Get.find<LanguageController>().getText('err_502'),
            );
            break;
          case 'ERR_501': // User Not Found
            Get.find<LulLoaders>().errorDialog(
              title: Get.find<LanguageController>().getText('error'),
              message: Get.find<LanguageController>().getText('err_501'),
            );
            break;
          default:
            Get.find<LulLoaders>().errorDialog(
              title: Get.find<LanguageController>().getText('error'),
              message: Get.find<LanguageController>().getText('general_error'),
            );
        }
        return false;
      } catch (e) {
        print('PIN update error: $e');
        Get.find<LulLoaders>().errorDialog(
          title: Get.find<LanguageController>().getText('error'),
          message: Get.find<LanguageController>().getText('pin_update_failed'),
        );
        return false;
      } finally {
        isLoading.value = false;
      }
    }
    return false;
  }

  /// Optional helper to programmatically show the PIN check screen if required.
  void checkAndShowPinScreen() {
    if (isPinEnabled.value && isPinCheckRequired.value) {
      Get.to(
        () => LulCheckPinScreen(
          maxAttempts: 3,
          onSuccess: () {},
        ),
        fullscreenDialog: true,
        transition: Transition.fade,
      );
    }
  }
}
