import 'package:get/get.dart';
import 'package:lul/services/user_lookup_service.dart';
import 'package:lul/utils/language/language_controller.dart';

class ScanUserIdBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure the UserLookupService is initialized
    if (!Get.isRegistered<UserLookupService>()) {
      Get.lazyPut<UserLookupService>(() => UserLookupService());
    }

    // Ensure the LanguageController is initialized
    if (!Get.isRegistered<LanguageController>()) {
      Get.lazyPut<LanguageController>(() => LanguageController());
    }
  }
}
