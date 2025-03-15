import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/wallet/recieve/controllers/qr_code_controller.dart';
import 'package:lul/features/wallet/recieve/screens/scan_user_id_screen.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:iconsax/iconsax.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(QrCodeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Payment QR'),
        centerTitle: true,
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Refresh button in app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshFromApi,
            tooltip: 'Refresh from server',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const ScanUserIdScreen()),
        backgroundColor: TColors.secondary,
        tooltip: 'Scan User ID',
        child: const Icon(Iconsax.scan, color: TColors.black),
      ),
      body: Obx(() {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                'Scan to Pay Me',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: TColors.primary,
                    ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Subtitle
              Text(
                'Share this QR code to receive payments',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // QR Code or Loading/Error State
              _buildQrCodeSection(controller, context),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Worker ID Text
              if (!controller.isLoading.value && !controller.hasError.value)
                Column(
                  children: [
                    Text(
                      'Your Worker ID:',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems / 2),
                    SelectableText(
                      controller.uniqueId.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    // Source indicator
                    Text(
                      controller.loadedFromStorage.value
                          ? '(Loaded from local storage)'
                          : '(Loaded from worker ID endpoint)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQrCodeSection(
      QrCodeController controller, BuildContext context) {
    // Show loading indicator
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error state
    if (controller.hasError.value) {
      return Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: TColors.error,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            controller.errorMessage.value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: TColors.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          ElevatedButton(
            onPressed: controller.retryLoading,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: TSizes.buttonWidth,
                vertical: TSizes.buttonHeight / 2,
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    // Show QR code
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: QrImageView(
        data: controller.uniqueId.value,
        version: QrVersions.auto,
        size: 250.0,
        backgroundColor: Colors.white,
        foregroundColor: TColors.primary,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        embeddedImage: const AssetImage('assets/logos/logo1.png'),
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size(40, 40),
        ),
      ),
    );
  }
}
