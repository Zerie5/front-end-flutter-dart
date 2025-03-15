import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:lul/features/authentication/screens/onboarding/widgets/onboarding_language_select.dart';
import 'package:lul/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:lul/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:lul/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:lul/utils/constants/image_strings.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/features/authentication/controllers.onboarding/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final LanguageController _languageController = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              LanguageSelectionPage(),
              OnBoardingPage(
                image: TImages.onBoardingImage1,
                title: _languageController.getText('onboardingTitle1'),
                subtitle: _languageController.getText('onboardingSubTitle1'),
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage2,
                title: _languageController.getText('onboardingTitle2'),
                subtitle: _languageController.getText('onboardingSubTitle2'),
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage3,
                title: _languageController.getText('onboardingTitle3'),
                subtitle: _languageController.getText('onboardingSubTitle3'),
              ),
              // Continue with other onboarding pages
            ],
          ),

          ///Skip Button

          const OnboardingSkip(),

          ///Dot Navigation SmoothPage Indicator

          const onBoardingDotNavigation(),

          ///Circular Button

          const onBoardingNextButton(),
        ],
      ),
    );
  }
}
