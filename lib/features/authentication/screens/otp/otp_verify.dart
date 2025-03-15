import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/widgets/pin/create_new_pin.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/services/otp_service.dart';

import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/tokens/auth_storage.dart';

class LulOtpVerifyScreen extends StatefulWidget {
  final String? phoneNumber;

  const LulOtpVerifyScreen({
    super.key,
    this.phoneNumber,
  });

  @override
  State<LulOtpVerifyScreen> createState() => _LulOtpVerifyScreenState();
}

class _LulOtpVerifyScreenState extends State<LulOtpVerifyScreen> {
  final LanguageController _languageController = Get.find<LanguageController>();
  bool invalidOtp = false;
  bool isLoading = false;
  int resendTime = 120; // Changed to 2 minutes
  late Timer countdownTimer;

  // Six controllers for 6-digit OTP
  final txt1 = TextEditingController();
  final txt2 = TextEditingController();
  final txt3 = TextEditingController();
  final txt4 = TextEditingController();
  final txt5 = TextEditingController();
  final txt6 = TextEditingController();

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        resendTime = resendTime - 1;
      });
      if (resendTime < 1) {
        countdownTimer.cancel();
      }
    });
  }

  void stopTimer() {
    if (countdownTimer.isActive) {
      countdownTimer.cancel();
    }
  }

  String strFormatting(n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.05; // 5% padding

    return Scaffold(
      backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: dark ? TColors.white : TColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _languageController.getText('verification'),
          style: const TextStyle(
            color: TColors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenSize.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _languageController.getText('verification_code'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: TColors.white,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Phone number display (only if available)
                  if (widget.phoneNumber != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'OTP sent to: ${widget.phoneNumber}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: TColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/edit-phone'),
                          child: const Text(
                            'Not your number?',
                            style: TextStyle(
                              color: TColors.secondary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 32),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: screenSize.height * 0.03),
                    child: _buildOtpInputRow(),
                  ),
                  const SizedBox(height: 32),

                  // Verify Button using LulButton
                  LulButton(
                    onPressed: _handleVerify,
                    text: _languageController.getText('verify'),
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Resend Timer Section
                  if (resendTime > 0)
                    Text(
                      '${_languageController.getText('resend_after')} ${strFormatting(resendTime)} ${_languageController.getText('seconds')}',
                      style: const TextStyle(
                        color: TColors.white,
                        fontSize: 14,
                      ),
                    ),

                  if (resendTime == 0)
                    LulOutlineButton(
                      onPressed: () {
                        setState(() {
                          resendTime = 120;
                          startTimer();
                        });
                      },
                      text: _languageController.getText('resend'),
                      fontSize: 16,
                      borderColor: TColors.secondary,
                      textColor: TColors.secondary,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleVerify() async {
    final otp =
        txt1.text + txt2.text + txt3.text + txt4.text + txt5.text + txt6.text;

    if (otp.length != 6) {
      setState(() => invalidOtp = true);
      return;
    }

    final response = await OtpService.verifyOtp(otp);

    if (response['status'] == 'success') {
      // Update registration status to 3
      await AuthStorage.saveRegistrationStage(response['registrationStatus']);

      stopTimer();
      Get.find<LulLoaders>().successDialog(
        title: _languageController.getText('success'),
        message: _languageController.getText('phone_verified'),
        onPressed: () => Get.to(() => const CreatePinScreen()),
      );
    } else {
      setState(() => invalidOtp = true);
      Get.snackbar(
        _languageController.getText('error'),
        _languageController.getText(response['code']),
        backgroundColor: TColors.error,
        colorText: TColors.white,
      );
    }
  }

  // Update the OTP input row with responsive sizing
  Widget _buildOtpInputRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate sizes based on screen width
        final spacing = constraints.maxWidth * 0.02; // 2% of width for spacing
        final inputWidth = (constraints.maxWidth - (spacing * 7)) /
            6; // Divide remaining space by 6
        final inputHeight =
            inputWidth * 1.2; // Make height slightly larger than width

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOtpInput(context, txt1, inputWidth, inputHeight),
            _buildOtpInput(context, txt2, inputWidth, inputHeight),
            _buildOtpInput(context, txt3, inputWidth, inputHeight),
            _buildOtpInput(context, txt4, inputWidth, inputHeight),
            _buildOtpInput(context, txt5, inputWidth, inputHeight),
            _buildOtpInput(context, txt6, inputWidth, inputHeight),
          ],
        );
      },
    );
  }

  // Update the input box builder with dynamic sizing
  Widget _buildOtpInput(BuildContext context, TextEditingController controller,
      double width, double height) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : TColors.lightContainer,
        border: Border.all(
          color: TColors.primary.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontSize: width * 0.4, // Dynamic font size
          fontWeight: FontWeight.bold,
          color: dark ? TColors.white : TColors.black,
        ),
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TColors.primary, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
