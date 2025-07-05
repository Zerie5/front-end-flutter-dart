import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/theme/widget_themes/lul_button_style.dart';
import '../controllers/deposit_controller.dart';
import '../models/wallet_models.dart';
import 'deposit_screen.dart';

class WalletSelectionScreen extends StatelessWidget {
  const WalletSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositController>();
    final dark = THelperFunctions.isDarkMode(context);

    // Load wallets when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadUserWallets();
    });

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        title: Text(
          'Select Wallet',
          style: Theme.of(context).textTheme.headlineMedium!.apply(
                color: TColors.white,
                fontWeightDelta: 1,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: TColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Choose which wallet to fund',
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                    color: TColors.white,
                  ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Wallets List
            Obx(() {
              if (controller.isLoadingWallets.value) {
                return _buildLoadingState(context);
              }

              if (controller.hasWalletError.value) {
                return _buildErrorState(context, controller);
              }

              if (controller.userWallets.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available wallets',
                    style: Theme.of(context).textTheme.titleMedium!.apply(
                          color: TColors.white,
                          fontWeightDelta: 1,
                        ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Wallet Cards
                  ...controller.userWallets.map((wallet) {
                    return Obx(() => Padding(
                          padding: const EdgeInsets.only(
                              bottom: TSizes.spaceBtwItems),
                          child: _WalletCard(
                            wallet: wallet,
                            isSelected:
                                controller.selectedWallet.value?.userWalletId ==
                                    wallet.userWalletId,
                            onTap: () => controller.setSelectedWallet(wallet),
                            dark: dark,
                          ),
                        ));
                  }),
                ],
              );
            }),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Information Panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                border: Border.all(
                  color: TColors.secondary,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.infoCircle,
                        color: TColors.secondary,
                        size: TSizes.iconSm,
                      ),
                      const SizedBox(width: TSizes.sm),
                      Text(
                        'Wallet Information',
                        style: Theme.of(context).textTheme.titleSmall!.apply(
                              color: TColors.white,
                              fontWeightDelta: 1,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.xs),
                  Text(
                    'Select the wallet you want to add funds to. You can fund any of your active wallets with different currencies.',
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: TColors.white,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections * 2),

            // Next Button
            Obx(() => LulButton(
                  onPressed: controller.hasSelectedWallet
                      ? () => Get.to(() => const DepositScreen())
                      : null,
                  text: 'Next',
                  backgroundColor: TColors.success,
                  foregroundColor: TColors.white,
                  isDisabled: !controller.hasSelectedWallet,
                  showShadow: true,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.xl),
      decoration: BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: TColors.secondary,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TColors.secondary),
          ),
          const SizedBox(height: TSizes.md),
          Text(
            'Loading your wallets...',
            style: Theme.of(context).textTheme.bodyMedium!.apply(
                  color: TColors.white,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, DepositController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: TColors.error,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            FontAwesomeIcons.exclamationTriangle,
            color: TColors.error,
            size: TSizes.iconLg,
          ),
          const SizedBox(height: TSizes.md),
          Text(
            'Error Loading Wallets',
            style: Theme.of(context).textTheme.titleMedium!.apply(
                  color: TColors.white,
                  fontWeightDelta: 1,
                ),
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            controller.walletErrorMessage.value,
            style: Theme.of(context).textTheme.bodySmall!.apply(
                  color: TColors.white.withOpacity(0.8),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.md),
          LulOutlineButton(
            onPressed: () => controller.loadUserWallets(),
            text: 'Retry',
            borderColor: TColors.secondary,
            textColor: TColors.secondary,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TSizes.xl),
      decoration: BoxDecoration(
        color: TColors.primary,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: TColors.secondary,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            FontAwesomeIcons.wallet,
            color: TColors.secondary,
            size: TSizes.iconLg,
          ),
          const SizedBox(height: TSizes.md),
          Text(
            'No Wallets Available',
            style: Theme.of(context).textTheme.titleMedium!.apply(
                  color: TColors.white,
                  fontWeightDelta: 1,
                ),
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            'You don\'t have any wallets available for funding at the moment.',
            style: Theme.of(context).textTheme.bodySmall!.apply(
                  color: TColors.white.withOpacity(0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final UserWallet wallet;
  final bool isSelected;
  final VoidCallback onTap;
  final bool dark;

  const _WalletCard({
    required this.wallet,
    required this.isSelected,
    required this.onTap,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: TColors.primary,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          border: Border.all(
            color: isSelected ? TColors.success : TColors.secondary,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? TColors.success.withOpacity(0.4)
                  : TColors.secondary.withOpacity(0.3),
              blurRadius: isSelected ? 12 : 8,
              spreadRadius: isSelected ? 2 : 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            // Wallet Icon
            Container(
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? TColors.success.withOpacity(0.2)
                    : TColors.secondary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                wallet.walletType.toUpperCase() == 'BLOCKCHAIN'
                    ? FontAwesomeIcons.link
                    : FontAwesomeIcons.wallet,
                color: isSelected ? TColors.success : TColors.secondary,
                size: TSizes.iconMd,
              ),
            ),

            const SizedBox(width: TSizes.md),

            // Wallet Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        wallet.currencyName,
                        style: Theme.of(context).textTheme.titleMedium!.apply(
                              color: TColors.white,
                              fontWeightDelta: 1,
                            ),
                      ),
                      const SizedBox(width: TSizes.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(TSizes.xs),
                        ),
                        child: Text(
                          wallet.currencyCode,
                          style: Theme.of(context).textTheme.labelSmall!.apply(
                                color: TColors.secondary,
                                fontWeightDelta: 1,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.xs / 2),
                  Text(
                    wallet.walletTypeDisplay,
                    style: Theme.of(context).textTheme.bodySmall!.apply(
                          color: TColors.white.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),

            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  wallet.formattedBalance,
                  style: Theme.of(context).textTheme.titleMedium!.apply(
                        color: TColors.white,
                        fontWeightDelta: 1,
                      ),
                ),
                const SizedBox(height: TSizes.xs / 2),
                Text(
                  wallet.formattedBalanceUSD,
                  style: Theme.of(context).textTheme.bodySmall!.apply(
                        color: TColors.white.withOpacity(0.7),
                      ),
                ),
              ],
            ),

            const SizedBox(width: TSizes.sm),

            // Selection Indicator
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected ? TColors.success : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? TColors.success : TColors.secondary,
                  width: 2,
                ),
              ),
              child: Icon(
                isSelected ? Icons.check : null,
                color: TColors.white,
                size: TSizes.iconSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
