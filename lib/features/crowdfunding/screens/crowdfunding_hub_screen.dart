import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:lul/common/widgets/custom_shapes/circular_container.dart';
import 'package:lul/features/crowdfunding/screens/create_campaign_screen.dart';
import 'package:lul/features/crowdfunding/screens/campaign_hub_screen.dart';

class CrowdfundingHubScreen extends StatefulWidget {
  const CrowdfundingHubScreen({super.key});

  @override
  State<CrowdfundingHubScreen> createState() => _CrowdfundingHubScreenState();
}

class _CrowdfundingHubScreenState extends State<CrowdfundingHubScreen>
    with TickerProviderStateMixin {
  late final LanguageController _languageController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _languageController = Get.find<LanguageController>();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                // Bottom decorative elements
                Positioned(
                  bottom: -50,
                  left: -100,
                  child: LCircularContainer(
                    backgroundColor: TColors.accent.withOpacity(0.1),
                    radius: 100,
                  ),
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeader(context, dark),
                      SizedBox(height: screenHeight * 0.03),

                      // Stats Section
                      _buildStatsSection(context, dark),
                      SizedBox(height: screenHeight * 0.04),

                      // Quick Actions Section
                      _buildQuickActionsSection(context, dark),
                      SizedBox(height: screenHeight * 0.04),

                      // Main Cards Section
                      _buildMainCardsSection(context, dark),
                      SizedBox(height: screenHeight * 0.04),

                      // Recent Activity Section
                      _buildRecentActivitySection(context, dark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool dark) {
    return Row(
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
                _languageController.getText('crowdfunding') ?? 'Crowdfunding',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: TColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: TSizes.xs),
              Text(
                _languageController.getText('crowdfunding_subtitle') ??
                    'Discover, create, and support amazing projects',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: TColors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: Border.all(
              color: TColors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: const Icon(
            FontAwesomeIcons.handHoldingHeart,
            color: TColors.secondary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, bool dark) {
    return Container(
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        color: TColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(
          color: TColors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Active Campaigns',
              '1,234',
              FontAwesomeIcons.rocket,
              TColors.secondary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: TColors.white.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Total Raised',
              '\$2.5M',
              FontAwesomeIcons.dollarSign,
              TColors.success,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: TColors.white.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Success Rate',
              '89%',
              FontAwesomeIcons.chartLine,
              TColors.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: TSizes.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: TColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: TSizes.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: TColors.white.withOpacity(0.7),
                fontSize: 12,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _languageController.getText('quick_actions') ?? 'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: TColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: TSizes.md),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Create Campaign',
                FontAwesomeIcons.plus,
                TColors.secondary,
                () => _navigateToCreateCampaign(),
              ),
            ),
            const SizedBox(width: TSizes.md),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Browse Campaigns',
                FontAwesomeIcons.search,
                TColors.secondary, // Use same color as Create Campaign
                () => Get.to(
                    () => const CampaignHubScreen()), // Attach navigation
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title,
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(
            color: TColors.white.withOpacity(0.35), // More pronounced border
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: TColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCardsSection(BuildContext context, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _languageController.getText('crowdfunding_features') ?? 'Features',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: TColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: TSizes.md),
        _buildFeatureCard(
          context,
          'My Campaigns',
          'Manage and track your created campaigns',
          FontAwesomeIcons.bullhorn,
          TColors.primary,
          () => _navigateToMyCampaigns(),
        ),
        const SizedBox(height: TSizes.md),
        _buildFeatureCard(
          context,
          'My Contributions',
          'View your contribution history and impact',
          FontAwesomeIcons.handHoldingHeart,
          TColors.success,
          () => _navigateToContributionHistory(),
        ),
        const SizedBox(height: TSizes.md),
        _buildFeatureCard(
          context,
          'Withdrawal Requests',
          'Manage campaign funds and withdrawals',
          FontAwesomeIcons.moneyBillTransfer,
          TColors.warning,
          () => _navigateToWithdrawalRequest(),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.lg),
        decoration: BoxDecoration(
          color: TColors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(
            color: TColors.white.withOpacity(0.35), // More pronounced border
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(TSizes.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: Icon(
                icon,
                color: TColors.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: TSizes.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: TColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(height: TSizes.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: TColors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: TColors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _languageController.getText('recent_activity') ??
                  'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: TColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                _languageController.getText('view_all') ?? 'View All',
                style: const TextStyle(
                  color: TColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.md),
        Container(
          padding: const EdgeInsets.all(TSizes.lg),
          decoration: BoxDecoration(
            color: TColors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: Border.all(
              color: TColors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                context,
                'New campaign launched',
                'Tech Startup XYZ',
                '2 hours ago',
                FontAwesomeIcons.rocket,
                TColors.secondary,
              ),
              const SizedBox(height: TSizes.md),
              _buildActivityItem(
                context,
                'Campaign funded successfully',
                'Eco Project ABC',
                '5 hours ago',
                FontAwesomeIcons.checkCircle,
                TColors.success,
              ),
              const SizedBox(height: TSizes.md),
              _buildActivityItem(
                context,
                'New contribution received',
                'Art Project DEF',
                '1 day ago',
                FontAwesomeIcons.heart,
                TColors.info,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String subtitle,
      String time, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
          ),
          child: Icon(
            icon,
            color: TColors.secondary,
            size: 16,
          ),
        ),
        const SizedBox(width: TSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: TColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: TColors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: TColors.white.withOpacity(0.5),
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  // Navigation methods
  void _navigateToCreateCampaign() {
    Get.to(() => const CreateCampaignScreen());
  }

  void _navigateToCampaignHub() {
    // TODO: Navigate to Campaign Hub Screen
    print('Navigate to Campaign Hub');
  }

  void _navigateToMyCampaigns() {
    // TODO: Navigate to My Campaigns Screen
    print('Navigate to My Campaigns');
  }

  void _navigateToContributionHistory() {
    // TODO: Navigate to Contribution History Screen
    print('Navigate to Contribution History');
  }

  void _navigateToWithdrawalRequest() {
    // TODO: Navigate to Withdrawal Request Screen
    print('Navigate to Withdrawal Request');
  }
}
