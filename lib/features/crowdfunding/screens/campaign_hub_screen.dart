import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/constants/sizes.dart';
import 'package:lul/utils/helpers/helper_functions.dart';

class CampaignHubScreen extends StatelessWidget {
  const CampaignHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final campaigns = [
      {
        'title': 'Clean Water for All',
        'desc': 'Help us build wells in rural areas.',
        'progress': 0.7,
        'amount': ' 500 raised of  5,000',
      },
      {
        'title': 'Tech for Schools',
        'desc': 'Provide tablets to underprivileged students.',
        'progress': 0.45,
        'amount': ' 1,800 raised of  4,000',
      },
      {
        'title': 'Medical Aid Fund',
        'desc': 'Support urgent surgeries for children.',
        'progress': 0.9,
        'amount': ' 4,500 raised of  5,000',
      },
    ];

    return Scaffold(
      backgroundColor: TColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: TColors.white),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: TSizes.sm),
                  Text(
                    'Campaign Hub',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: TColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.lg),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: TColors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: TColors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  style: const TextStyle(color: TColors.white),
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    hintStyle: TextStyle(color: TColors.white.withOpacity(0.7)),
                    prefixIcon:
                        const Icon(Icons.search, color: TColors.secondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.md),
              // Filter/Sort Row
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(FontAwesomeIcons.filter,
                        size: 16, color: TColors.secondary),
                    label: const Text('Filter',
                        style: TextStyle(color: TColors.secondary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.white.withOpacity(0.08),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: TColors.white.withOpacity(0.25)),
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.sm),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.sort,
                        size: 16, color: TColors.secondary),
                    label: const Text('Sort',
                        style: TextStyle(color: TColors.secondary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.white.withOpacity(0.08),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: TColors.white.withOpacity(0.25)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.lg),
              // Campaign List
              Expanded(
                child: ListView.separated(
                  itemCount: campaigns.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: TSizes.md),
                  itemBuilder: (context, i) {
                    final c = campaigns[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: TColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: TColors.white.withOpacity(0.35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: TColors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(TSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: TColors.secondary.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(FontAwesomeIcons.bullhorn,
                                    color: TColors.secondary, size: 22),
                              ),
                              const SizedBox(width: TSizes.md),
                              Expanded(
                                child: Text(
                                  c['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: TColors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: TSizes.sm),
                          Text(
                            c['desc'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: TColors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: TSizes.md),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: c['progress'] as double,
                              minHeight: 8,
                              backgroundColor: TColors.white.withOpacity(0.13),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  TColors.secondary),
                            ),
                          ),
                          const SizedBox(height: TSizes.xs),
                          Text(
                            c['amount'] as String,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: TColors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          const SizedBox(height: TSizes.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: TColors.secondary,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              child: const Text('View Details'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
