import 'package:flutter/material.dart';
import 'package:lul/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/device/device_utility.dart';

class OnboardingSkip extends StatelessWidget {
  const OnboardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: TDeviceUtils.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: TextButton(
          onPressed: () => OnBoardingController.instance.skipPage(),
          child: const Text("Skip")),
    );
  }
}
