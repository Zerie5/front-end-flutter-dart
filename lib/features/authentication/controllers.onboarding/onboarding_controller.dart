import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lul/features/authentication/screens/login/login.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int> currentpageindex = 0.obs;

  /// Update current index when page scrolls
  void updatePageIndicator(int index) {
    currentpageindex.value = index;
  }

  /// Navigate to specific page when a dot is clicked
  void dotNavigationClick(int index) {
    currentpageindex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Update current index and navigate to the next page
  void nextPage() {
    if (currentpageindex.value == 3) {
      // Navigate to the login screen or another screen
      Get.offAll(() => LoginScreen());
    } else {
      int nextPage = currentpageindex.value + 1;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentpageindex.value = nextPage; // Update the index
    }
  }

  /// Update current index and jump to the last page
  void skipPage() {
    currentpageindex.value = 3;
    pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
