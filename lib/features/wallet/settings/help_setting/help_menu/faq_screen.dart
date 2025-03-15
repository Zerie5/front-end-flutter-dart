import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';

class FAQScreen extends StatelessWidget {
  FAQScreen({super.key});

  final LanguageController _languageController = Get.find<LanguageController>();

  final List<Map<String, String>> faqItems = [
    {
      'question': 'How do I reset my PIN?',
      'answer':
          'To reset your PIN, go to Settings > Security > PIN and follow the instructions. You\'ll need to verify your identity first.',
    },
    {
      'question': 'What are the transfer limits?',
      'answer':
          'Transfer limits vary by account level. Basic accounts can transfer up to \$1,000 daily, while verified accounts have higher limits.',
    },
    {
      'question': 'How long do transfers take?',
      'answer':
          'Most transfers are instant. International transfers typically take 1-3 business days depending on the destination.',
    },
    {
      'question': 'Is my money safe?',
      'answer':
          'Yes! We use bank-level encryption and security measures to protect your funds and personal information.',
    },
    {
      'question': 'What currencies are supported?',
      'answer':
          'We currently support USD, EUR, GBP, and many other major currencies. Check the currency section for a full list.',
    },
  ];

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
          _languageController.getText('frequently_asked_questions'),
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
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(16),
              title: Text(
                faqItems[index]['question']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faqItems[index]['answer']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
