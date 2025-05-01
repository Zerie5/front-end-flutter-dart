import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/features/wallet/send/send_non_money_review.dart';
import 'package:lul/features/wallet/send/widgets/transfer_controller.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_dropdown_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/utils/validators/validation.dart';

class SetAmountScreen extends StatefulWidget {
  const SetAmountScreen({super.key});

  @override
  State<SetAmountScreen> createState() => _SetAmountScreenState();
}

class _SetAmountScreenState extends State<SetAmountScreen> {
  final LanguageController _languageController = Get.find<LanguageController>();
  final TransferController _transferController = Get.find<TransferController>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();

  final RxString _selectedCurrency = ''.obs;
  final RxInt _selectedCurrencyValue = 0.obs;

  // Currency options with their corresponding values
  final Map<String, int> _currencyOptions = {
    'USD': 2,
    'EUR': 6,
  };

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _languageController.getText('set_amount') ?? 'Set Amount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // Using ResizeToAvoidBottomInset to prevent keyboard overflow
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          // Using a SingleChildScrollView to allow scrolling when keyboard appears
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reduced initial spacing to move details higher
                const SizedBox(height: 5),

                // Enhanced Recipient info summary
                if (_transferController.fullName.value.isNotEmpty) ...[
                  // Recipient Avatar and Card
                  Center(
                    child: CircleAvatar(
                      radius: isLandscape ? 25 : 35, // Slightly smaller avatar
                      backgroundColor: TColors.primary.withOpacity(0.2),
                      child: Text(
                        _transferController.fullName.value.isNotEmpty
                            ? _transferController.fullName.value[0]
                                .toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: TColors.white,
                          fontSize: isLandscape ? 22 : 28, // Smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Reduced spacing between avatar and details
                  const SizedBox(height: 8),

                  // Contact Details Card with Gradient Border
                  Container(
                    padding: EdgeInsets.all(
                        isLandscape ? 10 : 14), // Reduced padding
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          TColors.primary.withOpacity(0.2),
                          TColors.secondary.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: TColors.primary.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: TColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _transferController.fullName.value,
                          style: TextStyle(
                            color: TColors.white,
                            fontSize: isLandscape ? 16 : 18, // Smaller font
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Reduced spacing between name and details
                        const SizedBox(height: 8),

                        // ID/Contact details
                        if (_transferController.contactId.value.isNotEmpty)
                          _buildDetailRow(
                            Icons.fingerprint,
                            _languageController.getText('id') ?? 'ID',
                            _transferController.contactId.value,
                          ),

                        if (_transferController.contactId.value.isNotEmpty)
                          const SizedBox(height: 6), // Smaller spacing

                        // Phone details
                        if (_transferController.phone.value.isNotEmpty)
                          _buildDetailRow(
                            Icons.phone_outlined,
                            _languageController.getText('phone') ?? 'Phone',
                            _transferController.phone.value,
                          ),

                        if (_transferController.phone.value.isNotEmpty)
                          const SizedBox(height: 6), // Smaller spacing

                        // Country details
                        if (_transferController.country.value.isNotEmpty)
                          _buildDetailRow(
                            Icons.public,
                            _languageController.getText('country') ?? 'Country',
                            _transferController.country.value,
                          ),
                      ],
                    ),
                  ),
                  // Reduced spacing after the card
                  const SizedBox(height: 15),
                ],

                // Currency selection dropdown
                Text(
                  _languageController.getText('currency') ?? 'Currency',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                Obx(() => LulDropdown<String>(
                      value: _selectedCurrency.value.isEmpty
                          ? null
                          : _selectedCurrency.value,
                      items: _currencyOptions.keys
                          .map((currency) => DropdownMenuItem<String>(
                                value: currency,
                                child: Text(currency),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          _selectedCurrency.value = newValue;
                          _selectedCurrencyValue.value =
                              _currencyOptions[newValue] ?? 0;
                        }
                      },
                      hintText:
                          _languageController.getText('select_currency') ??
                              'Select Currency',
                      validator: (value) => LValidator().validateEmpty(
                          value,
                          _languageController.getText('currency') ??
                              'Currency'),
                      prefixIcon:
                          const Icon(Icons.attach_money, color: TColors.white),
                    )),

                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Amount input field
                Text(
                  _languageController.getText('amount') ?? 'Amount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                LulGeneralTextFormField(
                  controller: _amountController,
                  hintText: _languageController.getText('enter_amount') ??
                      'Enter Amount',
                  prefixIcon: const Icon(Icons.payment, color: TColors.white),
                  validator: (value) => LValidator().validateEmpty(
                      value, _languageController.getText('amount') ?? 'Amount'),
                  textInputAction: TextInputAction.next,
                  // Set keyboard type to number
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: TSizes.spaceBtwInputFields),

                // Transaction ID field (optional)
                Text(
                  _languageController.getText('transaction_id') ??
                      'Transaction ID (optional)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                LulGeneralTextFormField(
                  controller: _transactionIdController,
                  hintText:
                      _languageController.getText('enter_transaction_id') ??
                          'Enter Transaction ID (if available)',
                  prefixIcon:
                      const Icon(Icons.assignment, color: TColors.white),
                  textInputAction: TextInputAction.done,
                ),

                // Reduced space between fields and button
                const SizedBox(height: 20),

                // Continue button
                LulButton(
                  onPressed: _handleContinue,
                  text: _languageController.getText('continue') ?? 'Continue',
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 6, horizontal: 8), // Smaller padding
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with proper alignment
          Container(
            margin: const EdgeInsets.only(right: 10), // Slightly reduced margin
            child: Icon(
              icon,
              color: TColors.secondary,
              size: 18, // Smaller icon
            ),
          ),
          // Label and Value in a single row with left alignment
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: TColors.white,
                fontSize: 14, // Smaller font
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      try {
        // Parse the amount
        final double amount = double.parse(_amountController.text);

        // Ensure we have a valid currency selected
        if (_selectedCurrencyValue.value <= 0) {
          Get.snackbar(
            _languageController.getText('error') ?? 'Error',
            _languageController.getText('select_valid_currency') ??
                'Please select a valid currency',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        // Set transfer details
        _transferController.setTransferDetails(
          amount,
          _selectedCurrency.value,
          null, // No wallet ID since this is external
          _selectedCurrencyValue
              .value, // Currency value for fee calculation (2 for USD, 6 for EUR)
        );

        // Store the transaction ID if provided
        if (_transactionIdController.text.isNotEmpty) {
          _transferController.transactionId.value =
              _transactionIdController.text;
        }

        // Navigate to review screen
        Get.to(() => LulSendNonMoneyReviewScreen());
      } catch (e) {
        // Show error for invalid amount
        Get.snackbar(
          _languageController.getText('error') ?? 'Error',
          _languageController.getText('invalid_amount') ??
              'Please enter a valid amount',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
