import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lul/utils/popups/loaders.dart';
import 'package:url_launcher/url_launcher.dart';

class KnowledgeBaseScreen extends StatelessWidget {
  KnowledgeBaseScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  final List<Map<String, String>> knowledgeBaseItems = [
    {
      'title': 'Getting Started Guide',
      'description': 'Learn the basics of using our digital wallet',
      'category': 'Basics',
      'icon': 'rocket',
    },
    {
      'title': 'Security Best Practices',
      'description': 'Keep your account and transactions secure',
      'category': 'Security',
      'icon': 'shield',
    },
    {
      'title': 'Transfer Limits & Fees',
      'description': 'Understanding transaction limits and associated fees',
      'category': 'Transactions',
      'icon': 'money',
    },
    {
      'title': 'Account Verification Process',
      'description': 'Steps to verify your account and increase limits',
      'category': 'Account',
      'icon': 'check',
    },
    {
      'title': 'Supported Countries & Currencies',
      'description': 'List of supported regions and currencies',
      'category': 'General',
      'icon': 'globe',
    },
  ];

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'rocket':
        return FontAwesomeIcons.rocket;
      case 'shield':
        return FontAwesomeIcons.shield;
      case 'money':
        return FontAwesomeIcons.moneyBill;
      case 'check':
        return FontAwesomeIcons.circleCheck;
      case 'globe':
        return FontAwesomeIcons.globe;
      default:
        return FontAwesomeIcons.book;
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://lulpay.com/');
    if (!await launchUrl(url)) {
      LulLoaders.lulerrorSnackBar(
        title: 'Error',
        message: 'Could not launch website',
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          _languageController.getText('knowledge_base'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: knowledgeBaseItems.length,
        itemBuilder: (context, index) {
          final item = knowledgeBaseItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(
                _getIconData(item['icon']!),
                color: Colors.white,
                size: 24,
              ),
              title: Text(
                item['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    item['description']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['category']!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
              onTap: () {
                if (index == 0) {
                  _launchURL();
                } else {
                  Get.snackbar(
                    'Article',
                    'Opening ${item['title']}',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
