import 'package:flutter/material.dart';
import 'package:lul/common/widgets/logo/app_logo.dart';
import 'package:lul/utils/constants/sizes.dart';

class LogoExampleScreen extends StatelessWidget {
  const LogoExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Examples'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Default Logo
              const LulLogo(),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Small Logo
              const LulLogo(size: 60),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Logo without text
              const LulLogo(showText: false),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Logo with custom colors
              const LulLogo(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Logo in a row with text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LulLogo(size: 40, showText: false),
                  const SizedBox(width: TSizes.md),
                  Text(
                    'Lul Pay',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
