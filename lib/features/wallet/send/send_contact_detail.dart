import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/features/wallet/contacts/models/contact_model.dart';
import 'package:lul/features/wallet/send/send_money_choice.dart';
import 'package:lul/features/wallet/send/widgets/transfer_controller.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';

class LulSendContactDetailScreen extends StatelessWidget {
  final ContactModel contact;
  final LanguageController _languageController = Get.find<LanguageController>();
  final TransferController _transferController = Get.put(TransferController());

  LulSendContactDetailScreen({
    super.key,
    required this.contact,
  });

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Obx(() {
          return Text(
            _languageController.getText('contact_detail'),
            style: FormTextStyle.getHeaderStyle(context),
          );
        }),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Profile Circle Avatar
                    CircleAvatar(
                      radius: isLandscape ? 40 : 50,
                      backgroundColor: TColors.primary.withOpacity(0.2),
                      child: Text(
                        contact.fullName[0].toUpperCase(),
                        style: TextStyle(
                          color: TColors.white,
                          fontSize: isLandscape ? 30 : 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 16 : 24),
                    // Contact Details Card with Gradient Border
                    Container(
                      padding: EdgeInsets.all(isLandscape ? 16 : 20),
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
                            contact.fullName,
                            style: TextStyle(
                              color: TColors.white,
                              fontSize: isLandscape ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isLandscape ? 16 : 20),
                          _buildDetailRow(
                            Icons.fingerprint,
                            _languageController.getText('id'),
                            contact.id,
                          ),
                          SizedBox(height: isLandscape ? 12 : 16),
                          _buildDetailRow(
                            Icons.email_outlined,
                            _languageController.getText('email'),
                            contact.email,
                          ),
                          SizedBox(height: isLandscape ? 12 : 16),
                          _buildDetailRow(
                            Icons.phone_outlined,
                            _languageController.getText('phone'),
                            contact.telephone,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Continue Button at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: LulButton(
                onPressed: () {
                  _transferController.setRecipientDetails(
                    contact.id,
                    contact.fullName,
                    contact.email,
                    contact.telephone,
                  );
                  Get.to(() => const LulSendMoneyChoiceScreen());
                },
                text: _languageController.getText('continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with proper alignment
          Container(
            margin: const EdgeInsets.only(right: 12), // Adjust spacing
            child: Icon(
              icon,
              color: TColors.secondary,
              size: 20,
            ),
          ),
          // Label and Value in a single row with left alignment
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: TColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
