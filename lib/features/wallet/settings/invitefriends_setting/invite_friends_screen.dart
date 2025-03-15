import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LulInviteFriendsScreen extends StatelessWidget {
  LulInviteFriendsScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();
  final String referralCode = "PRQH76NX2"; // Your referral code

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralCode)).then((_) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languageController.getText('copied')),
          backgroundColor: TColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  Future<void> _shareToWhatsApp() async {
    final message = """Hey! 👋

I'm using Lul for fast and secure money transfers. Join me and get special benefits!

Use my referral code: $referralCode 🎁

Download the app: https://lulpay.com
    
*Terms and conditions apply""";

    // For Android WhatsApp
    final whatsappAndroid =
        Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(whatsappAndroid)) {
        await launchUrl(
          whatsappAndroid,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to web URL
        final whatsappWeb =
            Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
        if (await canLaunchUrl(whatsappWeb)) {
          await launchUrl(
            whatsappWeb,
            mode: LaunchMode.externalApplication,
          );
        } else {
          Get.snackbar(
            'Error',
            'WhatsApp is not installed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: TColors.secondary.withOpacity(0.9),
            colorText: TColors.textWhite,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not launch WhatsApp',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.secondary.withOpacity(0.9),
        colorText: TColors.textWhite,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: THelperFunctions.getScreenBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColors.textWhite),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              _languageController.getText('invite_friends'),
              style: const TextStyle(
                color: TColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Reward Banner
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColors.secondary.withOpacity(0.3),
                      TColors.primary.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: TColors.secondary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      FontAwesomeIcons.gift,
                      color: TColors.secondary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _languageController.getText('get_rewards'),
                      style: const TextStyle(
                        color: TColors.textWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Referral Code Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: TColors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Text(
                      _languageController.getText('referal_code'),
                      style: TextStyle(
                        color: TColors.textWhite.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: TColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: TColors.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            referralCode,
                            style: const TextStyle(
                              color: TColors.secondary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: () => _copyToClipboard(context),
                            icon: const Icon(
                              Icons.copy,
                              color: TColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Share Options
              Row(
                children: [
                  Expanded(
                    child: _buildShareOption(
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WhatsApp',
                      onTap: _shareToWhatsApp,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildShareOption(
                      icon: FontAwesomeIcons.telegram,
                      label: 'Telegram',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildShareOption(
                      icon: FontAwesomeIcons.shareNodes,
                      label: 'More',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // How it works section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _languageController.getText('how_it_works'),
                      style: const TextStyle(
                        color: TColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      '1',
                      _languageController.getText('step_1'),
                      FontAwesomeIcons.shareFromSquare,
                    ),
                    _buildStep(
                      '2',
                      _languageController.getText('step_2'),
                      FontAwesomeIcons.userPlus,
                    ),
                    _buildStep(
                      '3',
                      _languageController.getText('step_3'),
                      FontAwesomeIcons.gift,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: TColors.secondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: TColors.textWhite,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: TColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: TColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: TColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: TColors.textWhite.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
