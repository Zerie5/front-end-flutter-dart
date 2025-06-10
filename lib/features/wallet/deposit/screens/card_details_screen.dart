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

class CardDetailsScreen extends StatelessWidget {
  const CardDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepositController>();

    return Scaffold(
      backgroundColor: TColors.primary,
      appBar: AppBar(
        title: Text(
          'Card Details',
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
          key: controller.cardFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Enter your card information',
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

              // Card Number Input
              Text(
                'Card Number',
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
                  controller: controller.cardNumberController,
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyLarge!.apply(
                        color: TColors.white,
                      ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    CardNumberInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '1234-5678-9012-3456',
                    hintStyle: Theme.of(context).textTheme.bodyLarge!.apply(
                          color: TColors.white.withOpacity(0.5),
                        ),
                    prefixIcon: const Icon(
                      FontAwesomeIcons.creditCard,
                      color: TColors.secondary,
                      size: TSizes.iconSm,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(TSizes.md),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    final cleaned = value.replaceAll('-', '');
                    if (cleaned.length < 13) {
                      return 'Card number must be at least 13 digits';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Expiry and CVV Row
              Row(
                children: [
                  // Expiry Date
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expiry Date',
                          style: Theme.of(context).textTheme.titleMedium!.apply(
                                color: TColors.white,
                                fontWeightDelta: 1,
                              ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Row(
                          children: [
                            // Month
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  borderRadius: BorderRadius.circular(
                                      TSizes.cardRadiusMd),
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
                                  controller: controller.expiryMonthController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .apply(
                                        color: TColors.white,
                                      ),
                                  decoration: InputDecoration(
                                    hintText: 'MM',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .apply(
                                          color: TColors.white.withOpacity(0.5),
                                        ),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.all(TSizes.sm),
                                    counterText: '',
                                  ),
                                  textAlign: TextAlign.center,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'MM';
                                    }
                                    final month = int.tryParse(value);
                                    if (month == null ||
                                        month < 1 ||
                                        month > 12) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: TSizes.sm),

                            // Year
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: TColors.primary,
                                  borderRadius: BorderRadius.circular(
                                      TSizes.cardRadiusMd),
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
                                  controller: controller.expiryYearController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .apply(
                                        color: TColors.white,
                                      ),
                                  decoration: InputDecoration(
                                    hintText: 'YY',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .apply(
                                          color: TColors.white.withOpacity(0.5),
                                        ),
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.all(TSizes.sm),
                                    counterText: '',
                                  ),
                                  textAlign: TextAlign.center,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'YY';
                                    }
                                    final year = int.tryParse(value);
                                    final currentYear =
                                        DateTime.now().year % 100;
                                    if (year == null || year < currentYear) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: TSizes.md),

                  // CVV
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CVV',
                          style: Theme.of(context).textTheme.titleMedium!.apply(
                                color: TColors.white,
                                fontWeightDelta: 1,
                              ),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Container(
                          decoration: BoxDecoration(
                            color: TColors.primary,
                            borderRadius:
                                BorderRadius.circular(TSizes.cardRadiusMd),
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
                            controller: controller.cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            style: Theme.of(context).textTheme.bodyLarge!.apply(
                                  color: TColors.white,
                                ),
                            decoration: InputDecoration(
                              hintText: '123',
                              hintStyle:
                                  Theme.of(context).textTheme.bodyLarge!.apply(
                                        color: TColors.white.withOpacity(0.5),
                                      ),
                              suffixIcon: const Icon(
                                FontAwesomeIcons.shield,
                                color: TColors.secondary,
                                size: TSizes.iconXs,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(TSizes.sm),
                              counterText: '',
                            ),
                            textAlign: TextAlign.center,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length < 3) {
                                return 'Invalid CVV';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: TSizes.spaceBtwSections),

              // Cardholder Name
              Text(
                'Cardholder Name',
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
                  controller: controller.cardholderNameController,
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
                      return 'Please enter cardholder name';
                    }
                    return null;
                  },
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
                        'Your card information is secured and encrypted. We never store your card details.',
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

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(newText[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
