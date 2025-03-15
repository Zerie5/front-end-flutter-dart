import 'package:get/get.dart';
import 'package:lul/services/profile_service.dart';

import 'package:lul/utils/language/language_controller.dart';

class UserController extends GetxController {
  final LanguageController _languageController = Get.find<LanguageController>();

  // User properties as observables
  final Rx<String> userId = ''.obs;
  final Rx<String> username = ''.obs;
  final Rx<String> email = ''.obs;
  final Rx<String> firstName = ''.obs;
  final Rx<String> lastName = ''.obs;
  final RxBool isLoading = false.obs;

  // Add loading state getter
  bool get loading => isLoading.value;

  @override
  void onInit() {
    super.onInit();
    print('UserController: Initialized without auto-loading profile');
  }

  Future<void> loadUserProfile() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      print('Loading user profile...');

      final response = await ProfileService.getUserProfile();
      print('Profile Response: $response');

      if (response['status'] == 'success' && response['data'] != null) {
        final userData = response['data'];
        // Update user data
        userId.value = userData['userId']?.toString() ?? '';
        username.value = userData['username'] ?? '';
        email.value = userData['email'] ?? '';

        // Extract first and last name from email if not provided
        if (userData['firstName'] == null && userData['lastName'] == null) {
          final emailName = email.value.split('@')[0];
          firstName.value = emailName;
          lastName.value = '';
        } else {
          firstName.value = userData['firstName'] ?? '';
          lastName.value = userData['lastName'] ?? '';
        }

        print('User profile loaded: ${username.value}');
      } else {
        print('Profile load skipped or failed silently');
        // Don't show error dialog, just log it
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Don't show error dialog
    } finally {
      isLoading.value = false;
    }
  }

  // Add method to clear user data
  void clearUserData() {
    userId.value = '';
    username.value = '';
    email.value = '';
    firstName.value = '';
    lastName.value = '';
  }
}
