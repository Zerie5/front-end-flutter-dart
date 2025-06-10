import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/theme/widget_themes/lul_button_style.dart';
import '../controllers/deposit_controller.dart';
import '../models/deposit_models.dart';
import 'confirmation_screen.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositController>();

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        title: Text(
          'Bank Details',
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
        child: Form(
          key: controller.bankFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Enter your bank information',
                style: Theme.of(context).textTheme.headlineSmall!.apply(
                      color: TColors.white,
                    ),
              ),
              const SizedBox(height: TSizes.sm),

              // Amount display
              Obx(() => Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          FontAwesomeIcons.dollarSign,
                          color: TColors.secondary,
                          size: TSizes.iconSm,
                        ),
                        const SizedBox(width: TSizes.xs),
                        Text(
                          controller.getFormattedAmount(
                              controller.depositAmount.value),
                          style:
                              Theme.of(context).textTheme.headlineMedium!.apply(
                                    color: TColors.white,
                                    fontWeightDelta: 2,
                                  ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Bank Selection
              Text(
                'Select Your Bank',
                style: Theme.of(context).textTheme.titleMedium!.apply(
                      color: TColors.white,
                      fontWeightDelta: 1,
                    ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              Container(
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
                child: Obx(() => DropdownButtonFormField<String>(
                      value: controller.selectedBank.value?.bankName,
                      style: Theme.of(context).textTheme.bodyLarge!.apply(
                            color: TColors.white,
                          ),
                      dropdownColor: TColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Choose your bank',
                        hintStyle: Theme.of(context).textTheme.bodyLarge!.apply(
                              color: TColors.white.withOpacity(0.5),
                            ),
                        prefixIcon: const Icon(
                          FontAwesomeIcons.buildingColumns,
                          color: TColors.secondary,
                          size: TSizes.iconSm,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(TSizes.md),
                      ),
                      items: MockBankData.bankNames.map((String bankName) {
                        return DropdownMenuItem<String>(
                          value: bankName,
                          child: Text(
                            bankName,
                            style:
                                Theme.of(context).textTheme.bodyMedium!.apply(
                                      color: TColors.white,
                                    ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.setSelectedBank(BankModel(
                            bankName: newValue,
                            accountNumber: '',
                            routingNumber: '',
                            accountType: BankAccountType.checking,
                            accountHolderName: '',
                          ));
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your bank';
                        }
                        return null;
                      },
                    )),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Account Number
              Text(
                'Account Number',
                style: Theme.of(context).textTheme.titleMedium!.apply(
                      color: TColors.white,
                      fontWeightDelta: 1,
                    ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              Container(
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
                child: TextFormField(
                  controller: controller.accountNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(17),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge!.apply(
                        color: TColors.white,
                      ),
                  decoration: InputDecoration(
                    hintText: '1234567890123456',
                    hintStyle: Theme.of(context).textTheme.bodyLarge!.apply(
                          color: TColors.white.withOpacity(0.5),
                        ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.hashtag,
                      color: TColors.secondary,
                      size: TSizes.iconSm,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(TSizes.md),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your account number';
                    }
                    if (value.length < 8) {
                      return 'Account number must be at least 8 digits';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Routing Number
              Text(
                'Routing Number',
                style: Theme.of(context).textTheme.titleMedium!.apply(
                      color: TColors.white,
                      fontWeightDelta: 1,
                    ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              Container(
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
                child: TextFormField(
                  controller: controller.routingNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  style: Theme.of(context).textTheme.bodyLarge!.apply(
                        color: TColors.white,
                      ),
                  decoration: InputDecoration(
                    hintText: '123456789',
                    hintStyle: Theme.of(context).textTheme.bodyLarge!.apply(
                          color: TColors.white.withOpacity(0.5),
                        ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.route,
                      color: TColors.secondary,
                      size: TSizes.iconSm,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(TSizes.md),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter routing number';
                    }
                    if (value.length != 9) {
                      return 'Routing number must be 9 digits';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Account Holder Name
              Text(
                'Account Holder Name',
                style: Theme.of(context).textTheme.titleMedium!.apply(
                      color: TColors.white,
                      fontWeightDelta: 1,
                    ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              Container(
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
                child: TextFormField(
                  controller: controller.accountHolderNameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(context).textTheme.bodyLarge!.apply(
                        color: TColors.white,
                      ),
                  decoration: InputDecoration(
                    hintText: 'John Doe',
                    hintStyle: Theme.of(context).textTheme.bodyLarge!.apply(
                          color: TColors.white.withOpacity(0.5),
                        ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.user,
                      color: TColors.secondary,
                      size: TSizes.iconSm,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(TSizes.md),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter account holder name';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Bank Transfer Info
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
                          FontAwesomeIcons.clock,
                          color: TColors.secondary,
                          size: TSizes.iconSm,
                        ),
                        const SizedBox(width: TSizes.sm),
                        Text(
                          'Processing Time: 1-3 Business Days',
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: TColors.white,
                                fontWeightDelta: 1,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.sm),
                    Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.dollarSign,
                          color: TColors.secondary,
                          size: TSizes.iconSm,
                        ),
                        const SizedBox(width: TSizes.sm),
                        Text(
                          'Processing Fee: \$1.50',
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: TColors.white,
                                fontWeightDelta: 1,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Security Info
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
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.lock,
                      color: TColors.secondary,
                      size: TSizes.iconSm,
                    ),
                    const SizedBox(width: TSizes.sm),
                    Expanded(
                      child: Text(
                        'Your bank information is secured and encrypted. We use bank-level security to protect your data.',
                        style: Theme.of(context).textTheme.bodySmall!.apply(
                              color: TColors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections * 2),

              // Continue Button
              LulButton(
                onPressed: () => Get.to(() => const ConfirmationScreen()),
                text: 'Continue',
                backgroundColor: TColors.success,
                foregroundColor: TColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
