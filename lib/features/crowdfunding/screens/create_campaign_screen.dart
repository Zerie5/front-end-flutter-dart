import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/utils/theme/widget_themes/lul_button_style.dart';
import 'package:lul/utils/theme/widget_themes/lul_textformfield.dart';
import 'package:lul/features/crowdfunding/controllers/crowdfunding_controller.dart';
import 'package:lul/common/widgets/custom_shapes/circular_container.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  late final LanguageController _languageController;
  late final CrowdfundingController _crowdfundingController;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fundingGoalController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _fundingGoalFocusNode = FocusNode();
  final FocusNode _durationFocusNode = FocusNode();

  String _selectedCategory = '';
  String _selectedCurrency = 'USD';

  final List<String> _categories = [
    'Technology',
    'Environment',
    'Art & Culture',
    'Health & Wellness',
    'Education',
    'Social Impact',
    'Business',
    'Entertainment',
    'Sports',
    'Other'
  ];

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    _languageController = Get.find<LanguageController>();
    _crowdfundingController = Get.put(CrowdfundingController());

    // Set default values
    _selectedCategory = _categories.isNotEmpty ? _categories[0] : '';
    _durationController.text = '30';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fundingGoalController.dispose();
    _durationController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _fundingGoalFocusNode.dispose();
    _durationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: TColors.primary,
      body: Stack(
        children: [
          // Background with decorative elements
          SizedBox(
            height: double.infinity,
            child: Stack(
              children: [
                // Top decorative circles
                Positioned(
                  top: -100,
                  right: -150,
                  child: LCircularContainer(
                    backgroundColor: TColors.white.withOpacity(0.1),
                    radius: 120,
                  ),
                ),
                Positioned(
                  top: 50,
                  right: -200,
                  child: LCircularContainer(
                    backgroundColor: TColors.secondary.withOpacity(0.1),
                    radius: 80,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, dark),

                // Form content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? TColors.dark : TColors.light,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(TSizes.cardRadiusLg),
                        topRight: Radius.circular(TSizes.cardRadiusLg),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(TSizes.cardRadiusLg),
                        topRight: Radius.circular(TSizes.cardRadiusLg),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(TSizes.defaultSpace),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Campaign Title
                              _buildSectionTitle(context, 'Campaign Title'),
                              const SizedBox(height: TSizes.sm),
                              LulGeneralTextFormField(
                                controller: _titleController,
                                focusNode: _titleFocusNode,
                                hintText: 'Enter your campaign title',
                                validator: _crowdfundingController
                                    .validateCampaignTitle,
                                onChanged: (value) => _crowdfundingController
                                    .setCampaignTitle(value),
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: TSizes.lg),

                              // Campaign Description
                              _buildSectionTitle(
                                  context, 'Campaign Description'),
                              const SizedBox(height: TSizes.sm),
                              LulGeneralTextFormField(
                                controller: _descriptionController,
                                focusNode: _descriptionFocusNode,
                                hintText: 'Describe your campaign in detail',
                                validator: _crowdfundingController
                                    .validateCampaignDescription,
                                onChanged: (value) => _crowdfundingController
                                    .setCampaignDescription(value),
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                              ),
                              const SizedBox(height: TSizes.lg),

                              // Category Selection
                              _buildSectionTitle(context, 'Category'),
                              const SizedBox(height: TSizes.sm),
                              _buildCategoryDropdown(context),
                              const SizedBox(height: TSizes.lg),

                              // Funding Goal
                              _buildSectionTitle(context, 'Funding Goal'),
                              const SizedBox(height: TSizes.sm),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: LulGeneralTextFormField(
                                      controller: _fundingGoalController,
                                      focusNode: _fundingGoalFocusNode,
                                      hintText: '0.00',
                                      validator: _crowdfundingController
                                          .validateFundingGoal,
                                      onChanged: (value) {
                                        final goal =
                                            double.tryParse(value) ?? 0.0;
                                        _crowdfundingController
                                            .setFundingGoal(goal);
                                      },
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: TSizes.md),
                                  Expanded(
                                    child: _buildCurrencyDropdown(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: TSizes.lg),

                              // Campaign Duration
                              _buildSectionTitle(
                                  context, 'Campaign Duration (Days)'),
                              const SizedBox(height: TSizes.sm),
                              LulGeneralTextFormField(
                                controller: _durationController,
                                focusNode: _durationFocusNode,
                                hintText: '30',
                                validator: _crowdfundingController
                                    .validateCampaignDuration,
                                onChanged: (value) {
                                  final duration = int.tryParse(value) ?? 30;
                                  _crowdfundingController
                                      .setCampaignDuration(duration);
                                },
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: TSizes.lg),

                              // Media Upload Section
                              _buildSectionTitle(context, 'Campaign Media'),
                              const SizedBox(height: TSizes.sm),
                              _buildMediaUploadSection(context),
                              const SizedBox(height: TSizes.lg),

                              // Tips Section
                              _buildTipsSection(context),
                              const SizedBox(height: TSizes.xl),

                              // Submit Button
                              Obx(() => LulButton(
                                    onPressed: _crowdfundingController
                                                .isCampaignFormValid &&
                                            !_crowdfundingController
                                                .isLoading.value
                                        ? _submitCampaign
                                        : null,
                                    text:
                                        _crowdfundingController.isLoading.value
                                            ? 'Creating Campaign...'
                                            : 'Create Campaign',
                                    isLoading:
                                        _crowdfundingController.isLoading.value,
                                    backgroundColor: TColors.secondary,
                                    foregroundColor: TColors.primary,
                                  )),

                              const SizedBox(height: TSizes.xl),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool dark) {
    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: TColors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _languageController.getText('create_campaign') ??
                      'Create Campaign',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: TColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: TSizes.xs),
                Text(
                  _languageController.getText('create_campaign_subtitle') ??
                      'Start your crowdfunding journey',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: TColors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(TSizes.sm),
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              border: Border.all(
                color: TColors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              FontAwesomeIcons.plus,
              color: TColors.secondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: TColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: TColors.borderPrimary.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: TSizes.md),
        ),
        hint: const Text(
          'Select category',
          style: TextStyle(
            color: TColors.textSecondary,
            fontSize: 16,
          ),
        ),
        items: _categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(
              category,
              style: const TextStyle(
                color: TColors.textPrimary,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategory = newValue ?? '';
            _crowdfundingController.setSelectedCategory(_selectedCategory);
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a category';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: TColors.borderPrimary.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCurrency,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: TSizes.md),
        ),
        items: _currencies.map((String currency) {
          return DropdownMenuItem<String>(
            value: currency,
            child: Text(
              currency,
              style: const TextStyle(
                color: TColors.textPrimary,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCurrency = newValue ?? 'USD';
            _crowdfundingController.setSelectedCurrency(_selectedCurrency);
          });
        },
      ),
    );
  }

  Widget _buildMediaUploadSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(
          color: TColors.borderPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Images Upload
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.image,
                color: TColors.primary,
                size: 20,
              ),
              const SizedBox(width: TSizes.sm),
              Text(
                'Campaign Images',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              border: Border.all(
                color: TColors.borderPrimary.withOpacity(0.3),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              onTap: () {
                // TODO: Implement image picker
                print('Add campaign images');
              },
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.plus,
                    color: TColors.textSecondary,
                    size: 24,
                  ),
                  SizedBox(height: TSizes.xs),
                  Text(
                    'Add Images',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TSizes.lg),

          // Video Upload
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.video,
                color: TColors.primary,
                size: 20,
              ),
              const SizedBox(width: TSizes.sm),
              Text(
                'Campaign Video (Optional)',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: TColors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              border: Border.all(
                color: TColors.borderPrimary.withOpacity(0.3),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              onTap: () {
                // TODO: Implement video picker
                print('Add campaign video');
              },
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.plus,
                    color: TColors.textSecondary,
                    size: 20,
                  ),
                  SizedBox(height: TSizes.xs),
                  Text(
                    'Add Video',
                    style: TextStyle(
                      color: TColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TColors.secondary.withOpacity(0.1),
            TColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(
          color: TColors.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.lightbulb,
                color: TColors.secondary,
                size: 20,
              ),
              const SizedBox(width: TSizes.sm),
              Text(
                'Campaign Tips',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: TColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
          _buildTipItem('• Write a compelling title that grabs attention'),
          _buildTipItem('• Include high-quality images and videos'),
          _buildTipItem('• Set realistic funding goals'),
          _buildTipItem('• Tell your story authentically'),
          _buildTipItem('• Engage with your backers regularly'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.xs),
      child: Text(
        tip,
        style: const TextStyle(
          color: TColors.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }

  Future<void> _submitCampaign() async {
    if (_formKey.currentState!.validate()) {
      final success = await _crowdfundingController.createCampaign();

      if (success) {
        Get.snackbar(
          'Success',
          'Campaign created successfully!',
          backgroundColor: TColors.success,
          colorText: TColors.white,
          snackPosition: SnackPosition.TOP,
        );

        // Navigate back or to campaign details
        Get.back();
      } else {
        Get.snackbar(
          'Error',
          _crowdfundingController.errorMessage.value,
          backgroundColor: TColors.error,
          colorText: TColors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }
}
