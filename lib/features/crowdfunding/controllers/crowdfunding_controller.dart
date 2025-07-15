import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/utils/language/language_controller.dart';

class CrowdfundingController extends GetxController {
  static CrowdfundingController get instance => Get.find();

  final LanguageController _languageController = Get.find<LanguageController>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;

  // Campaign creation variables
  final RxString campaignTitle = ''.obs;
  final RxString campaignDescription = ''.obs;
  final RxDouble fundingGoal = 0.0.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedCurrency = 'USD'.obs;
  final RxInt campaignDuration = 30.obs; // days
  final RxList<String> campaignImages = <String>[].obs;
  final RxString campaignVideo = ''.obs;

  // Campaign list variables
  final RxList<Map<String, dynamic>> campaigns = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingCampaigns = false.obs;

  // My campaigns variables
  final RxList<Map<String, dynamic>> myCampaigns = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMyCampaigns = false.obs;

  // Contribution variables
  final RxList<Map<String, dynamic>> myContributions =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingContributions = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('CrowdfundingController: Initialized');
  }

  // Campaign creation methods
  void setCampaignTitle(String title) {
    campaignTitle.value = title;
  }

  void setCampaignDescription(String description) {
    campaignDescription.value = description;
  }

  void setFundingGoal(double goal) {
    fundingGoal.value = goal;
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  void setSelectedCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  void setCampaignDuration(int days) {
    campaignDuration.value = days;
  }

  void addCampaignImage(String imagePath) {
    campaignImages.add(imagePath);
  }

  void removeCampaignImage(int index) {
    if (index < campaignImages.length) {
      campaignImages.removeAt(index);
    }
  }

  void setCampaignVideo(String videoPath) {
    campaignVideo.value = videoPath;
  }

  // Validation methods
  bool get isCampaignFormValid {
    return campaignTitle.value.isNotEmpty &&
        campaignDescription.value.isNotEmpty &&
        fundingGoal.value > 0 &&
        selectedCategory.value.isNotEmpty &&
        campaignDuration.value > 0;
  }

  String? validateCampaignTitle(String? value) {
    if (value == null || value.isEmpty) {
      return _languageController.getText('campaign_title_required') ??
          'Campaign title is required';
    }
    if (value.length < 10) {
      return _languageController.getText('campaign_title_too_short') ??
          'Campaign title must be at least 10 characters';
    }
    if (value.length > 100) {
      return _languageController.getText('campaign_title_too_long') ??
          'Campaign title must be less than 100 characters';
    }
    return null;
  }

  String? validateCampaignDescription(String? value) {
    if (value == null || value.isEmpty) {
      return _languageController.getText('campaign_description_required') ??
          'Campaign description is required';
    }
    if (value.length < 50) {
      return _languageController.getText('campaign_description_too_short') ??
          'Campaign description must be at least 50 characters';
    }
    return null;
  }

  String? validateFundingGoal(String? value) {
    if (value == null || value.isEmpty) {
      return _languageController.getText('funding_goal_required') ??
          'Funding goal is required';
    }
    final goal = double.tryParse(value);
    if (goal == null || goal <= 0) {
      return _languageController.getText('funding_goal_invalid') ??
          'Please enter a valid funding goal';
    }
    if (goal < 10) {
      return _languageController.getText('funding_goal_too_low') ??
          'Funding goal must be at least \$10';
    }
    return null;
  }

  String? validateCampaignDuration(String? value) {
    if (value == null || value.isEmpty) {
      return _languageController.getText('campaign_duration_required') ??
          'Campaign duration is required';
    }
    final duration = int.tryParse(value);
    if (duration == null || duration <= 0) {
      return _languageController.getText('campaign_duration_invalid') ??
          'Please enter a valid duration';
    }
    if (duration < 1) {
      return _languageController.getText('campaign_duration_too_short') ??
          'Campaign duration must be at least 1 day';
    }
    if (duration > 365) {
      return _languageController.getText('campaign_duration_too_long') ??
          'Campaign duration cannot exceed 365 days';
    }
    return null;
  }

  // API methods (mock for now)
  Future<bool> createCampaign() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock success
      print('CrowdfundingController: Campaign created successfully');
      return true;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('CrowdfundingController: Error creating campaign - $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCampaigns() async {
    try {
      isLoadingCampaigns.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      campaigns.value = [
        {
          'id': '1',
          'title': 'Eco-Friendly Water Bottle',
          'description': 'Revolutionary biodegradable water bottle',
          'goal': 50000.0,
          'raised': 35000.0,
          'currency': 'USD',
          'category': 'Environment',
          'creator': 'GreenTech Inc',
          'daysLeft': 15,
          'image': 'https://example.com/image1.jpg',
          'progress': 0.7,
        },
        {
          'id': '2',
          'title': 'Smart Home Security System',
          'description': 'AI-powered home security with facial recognition',
          'goal': 100000.0,
          'raised': 75000.0,
          'currency': 'USD',
          'category': 'Technology',
          'creator': 'SecureTech',
          'daysLeft': 8,
          'image': 'https://example.com/image2.jpg',
          'progress': 0.75,
        },
      ];
    } catch (e) {
      print('CrowdfundingController: Error loading campaigns - $e');
    } finally {
      isLoadingCampaigns.value = false;
    }
  }

  Future<void> loadMyCampaigns() async {
    try {
      isLoadingMyCampaigns.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      myCampaigns.value = [
        {
          'id': '1',
          'title': 'My First Campaign',
          'description': 'A test campaign',
          'goal': 10000.0,
          'raised': 5000.0,
          'currency': 'USD',
          'category': 'Technology',
          'daysLeft': 20,
          'image': 'https://example.com/image3.jpg',
          'progress': 0.5,
          'status': 'active',
        },
      ];
    } catch (e) {
      print('CrowdfundingController: Error loading my campaigns - $e');
    } finally {
      isLoadingMyCampaigns.value = false;
    }
  }

  Future<void> loadMyContributions() async {
    try {
      isLoadingContributions.value = true;

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      myContributions.value = [
        {
          'id': '1',
          'campaignId': '1',
          'campaignTitle': 'Eco-Friendly Water Bottle',
          'amount': 100.0,
          'currency': 'USD',
          'date': '2024-01-15',
          'status': 'confirmed',
        },
        {
          'id': '2',
          'campaignId': '2',
          'campaignTitle': 'Smart Home Security System',
          'amount': 250.0,
          'currency': 'USD',
          'date': '2024-01-10',
          'status': 'confirmed',
        },
      ];
    } catch (e) {
      print('CrowdfundingController: Error loading contributions - $e');
    } finally {
      isLoadingContributions.value = false;
    }
  }

  // Utility methods
  String getFormattedAmount(double amount, String currency) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String getFormattedProgress(double progress) {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  Color getProgressColor(double progress) {
    if (progress >= 0.8) return const Color(0xFF4CAF50); // Green
    if (progress >= 0.5) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }
}
