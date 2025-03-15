import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LulOurCompanyScreen extends StatelessWidget {
  LulOurCompanyScreen({super.key});
  final LanguageController _languageController = Get.find<LanguageController>();
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
              _languageController.getText('our_company'),
              style: FormTextStyle.getHeaderStyle(context),
            )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Gradient
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    TColors.secondary.withOpacity(0.3),
                    TColors.primary.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: TColors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: TColors.secondary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: TColors.secondary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 50,
                      color: TColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lul',
                    style: FormTextStyle.getHeaderStyle(context)?.copyWith(
                      fontSize: 28,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionWithIcon(
                    context,
                    title: 'Our Mission',
                    content:
                        'To revolutionize cross-border payments and make financial services accessible to everyone through innovative digital solutions.',
                    icon: FontAwesomeIcons.rocket,
                  ),
                  _buildSectionWithIcon(
                    context,
                    title: 'About Us',
                    content:
                        'Lul Pay is a leading fintech company specializing in digital payments and cross-border remittance solutions. Founded with the vision of making financial transactions seamless and accessible, we leverage cutting-edge technology to provide secure, fast, and affordable payment services.',
                    icon: FontAwesomeIcons.buildingColumns,
                  ),
                  _buildFeatureGrid(context),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _buildSectionWithIcon(
                    context,
                    title: 'Our Values',
                    content: '',
                    icon: FontAwesomeIcons.handshake,
                    child: _buildValuesList(context),
                  ),
                  _buildSectionWithIcon(
                    context,
                    title: 'Global Presence',
                    content:
                        'Operating across multiple countries, we serve millions of customers worldwide, facilitating billions in transactions annually.',
                    icon: FontAwesomeIcons.globe,
                  ),
                  _buildContactSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithIcon(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    Widget? child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: TColors.secondary, size: 24),
              const SizedBox(width: 12),
              Text(title, style: FormTextStyle.getLabelStyle(context)),
            ],
          ),
          const SizedBox(height: 16),
          if (content.isNotEmpty)
            Text(
              content,
              style: FormTextStyle.getInfoTextStyle(context)?.copyWith(
                color: TColors.textWhite.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      {'icon': FontAwesomeIcons.moneyBillTransfer, 'text': 'Instant Transfers'},
      {'icon': FontAwesomeIcons.shield, 'text': 'Secure Payments'},
      {'icon': FontAwesomeIcons.receipt, 'text': 'Bill Payments'},
      {'icon': FontAwesomeIcons.globe, 'text': 'Multi-Currency'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: TColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TColors.secondary.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                features[index]['icon'] as IconData,
                color: TColors.secondary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                features[index]['text'] as String,
                style: FormTextStyle.getInfoTextStyle(context)?.copyWith(
                  color: TColors.textWhite,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValuesList(BuildContext context) {
    final values = [
      {
        'icon': FontAwesomeIcons.lightbulb,
        'title': 'Innovation',
        'desc': 'Embracing new technologies'
      },
      {
        'icon': FontAwesomeIcons.shieldHalved,
        'title': 'Security',
        'desc': 'Protecting our users\' assets'
      },
      {
        'icon': FontAwesomeIcons.users,
        'title': 'Accessibility',
        'desc': 'Making finance available to all'
      },
      {
        'icon': FontAwesomeIcons.scaleBalanced,
        'title': 'Transparency',
        'desc': 'Clear and fair practices'
      },
    ];
    return Column(
      children: values
          .map((value) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(value['icon'] as IconData,
                        color: TColors.secondary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value['title'] as String,
                            style: FormTextStyle.getInfoTextStyle(context)
                                ?.copyWith(
                              color: TColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            value['desc'] as String,
                            style: FormTextStyle.getInfoTextStyle(context)
                                ?.copyWith(
                              color: TColors.textWhite.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColors.secondary.withOpacity(0.2),
            TColors.primary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Get in Touch', style: FormTextStyle.getLabelStyle(context)),
          const SizedBox(height: 16),
          _buildContactRow(FontAwesomeIcons.globe, 'www.lulpay.com'),
          _buildContactRow(FontAwesomeIcons.envelope, 'support@lulpay.com'),
          _buildContactRow(
              FontAwesomeIcons.locationDot, 'Addis Ababa, Ethiopia'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: TColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: TColors.textWhite.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }
}
