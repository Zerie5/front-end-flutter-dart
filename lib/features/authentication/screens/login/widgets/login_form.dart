import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lul/features/authentication/screens/signup/signup_screen.dart';
import 'package:lul/navigation_menu.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/services/auth_service.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class LoginForm extends StatelessWidget {
  LoginForm({
    super.key,
    required LanguageController languageController,
    required this.isPasswordVisible,
  }) : _languageController = languageController;

  final LanguageController _languageController;
  final RxBool isPasswordVisible;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _isLoading = false.obs;

  // Handle specific error codes with appropriate messages
  void _handleAuthError(Map<String, dynamic> response) {
    final String errorCode = response['code'] ?? 'ERR_UNKNOWN';
    final String errorMessage =
        response['message'] ?? 'An unknown error occurred';

    print('Handling error code: $errorCode with message: $errorMessage');

    switch (errorCode) {
      case 'ERR_400':
        // Missing email or password
        print('Showing ERR_400 error dialog: Form Error');
        LulLoaders.lulerrorDialog(
          title: 'Form Error',
          message:
              'Email and password are required. Please fill in all fields.',
        );
        break;

      case 'ERR_401':
        // This code is used for multiple error types, check the message
        if (errorMessage.contains('Invalid email or password') ||
            errorMessage == 'LOGIN_FAILED') {
          // Invalid credentials
          print(
              'Showing ERR_401 error dialog: Authentication Failed - Invalid credentials');
          LulLoaders.lulerrorDialog(
            title: 'Authentication Failed',
            message:
                'The email or password you entered is incorrect. Please try again.',
          );
        } else if (errorMessage.contains('JWT token has expired')) {
          // Token expired
          print('Showing ERR_401 error dialog: Session Expired');
          AuthStorage.clearAll(); // Clear stored tokens
          LulLoaders.lulerrorDialog(
            title: 'Session Expired',
            message: 'Your session has expired. Please log in again.',
            onPressed: () {
              // Redirect to login screen after dialog is dismissed
              Get.offAll(() => const NavigationMenu());
            },
          );
        } else if (errorMessage.contains('Invalid JWT signature') ||
            errorMessage.contains('JWT token is malformed')) {
          // Invalid token
          print(
              'Showing ERR_401 error dialog: Authentication Error - Invalid token');
          AuthStorage.clearAll(); // Clear stored tokens
          LulLoaders.lulerrorDialog(
            title: 'Authentication Error',
            message: 'Your login session is invalid. Please log in again.',
            onPressed: () {
              // Redirect to login screen after dialog is dismissed
              Get.offAll(() => const NavigationMenu());
            },
          );
        } else {
          // Generic authentication error
          print('Showing ERR_401 error dialog: Authentication Error - Generic');
          LulLoaders.lulerrorDialog(
            title: 'Authentication Error',
            message: 'Invalid email or password. Please try again.',
          );
        }
        break;

      case 'ERR_403':
        // Account locked or disabled
        print('Showing ERR_403 error dialog: Account Locked');
        LulLoaders.lulerrorDialog(
          title: 'Account Locked',
          message:
              'Your account has been locked or disabled. Please contact support at support@lulpay.com for assistance.',
        );
        break;

      case 'ERR_502':
        // No authorization header
        print('Showing ERR_502 error dialog: Authentication Required');
        AuthStorage.clearAll(); // Clear stored tokens
        LulLoaders.lulerrorDialog(
          title: 'Authentication Required',
          message: 'You need to log in to access this feature.',
          onPressed: () {
            // Redirect to login screen after dialog is dismissed
            Get.offAll(() => const NavigationMenu());
          },
        );
        break;

      case 'ERR_CONNECTION':
        // Connection error
        print('Showing ERR_CONNECTION error dialog: Connection Error');
        LulLoaders.lulerrorDialog(
          title: 'Connection Error',
          message: errorMessage,
        );
        break;

      default:
        // Unknown error
        print('Showing default error dialog: Error - $errorCode');
        LulLoaders.lulerrorDialog(
          title: 'Error',
          message: errorMessage,
        );
        break;
    }
  }

  Future<void> _handleLogin() async {
    if (_isLoading.value) return;

    // Validate form fields before submission
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      LulLoaders.lulerrorDialog(
        title: 'Form Error',
        message: 'Email and password are required. Please fill in all fields.',
      );
      return;
    }

    try {
      _isLoading.value = true;
      print('Login: Attempting login...');

      final response = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Log entire response
      print('Login Response: $response');
      print('Response status: ${response['status']}');
      print('Response code: ${response['code']}');
      print('Response message: ${response['message']}');

      if (response['status'] == 'success') {
        final token = response['token'] as String;
        final userId = response['userId'] as String;
        final registerStatus = response['registerStatus'] as int;

        await AuthStorage.saveToken(token);
        await AuthStorage.saveUserId(userId);
        await AuthStorage.saveRegistrationStage(registerStatus);

        // Navigate to main screen on success
        Get.offAll(() => const NavigationMenu());
      } else {
        // Handle authentication errors
        print('Handling auth error with code: ${response['code']}');
        _handleAuthError(response);
      }
    } catch (e) {
      print('Login error: ${e.toString()}');
      LulLoaders.lulerrorDialog(
        title: 'Error',
        message: 'An unexpected error occurred. Please try again later.',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            /// E-Mail
            Obx(
              () => TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.direct_right),
                  labelText: _languageController.getText('email'),
                ),
              ),
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields,
            ),

            /// Password
            Obx(
              () => TextFormField(
                controller: _passwordController,
                obscureText: !isPasswordVisible.value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.password_check),
                  labelText: _languageController.getText('password'),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      isPasswordVisible.value = !isPasswordVisible.value;
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields / 2,
            ),

            /// Remember me & Forget Password
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Remember Me
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (value) {}),
                      Text(_languageController.getText('remember_me')),
                    ],
                  ),

                  /// Forgot My Password
                  TextButton(
                    onPressed: () {},
                    child:
                        Text(_languageController.getText('forgot_my_password')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            /// Sign In Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading.value ? null : _handleLogin,
                  child: _isLoading.value
                      ? const CircularProgressIndicator()
                      : Text(_languageController.getText('sign_in')),
                ),
              ),
            ),

            const SizedBox(
              height: TSizes.spaceBtwItems,
            ),

            /// Create Account
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.to(() => SignUpScreen2()),
                  child: Text(_languageController.getText('create_account')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
