import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lul/common/styles/text_style.dart';
import 'package:lul/utils/constants/colors.dart';
import 'package:lul/utils/device/device_info_helper.dart';
import 'package:lul/utils/helpers/helper_functions.dart';
import 'package:lul/utils/language/language_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lul/services/access_history_service.dart';
import 'package:intl/intl.dart';

class LulAccessHistoryScreen extends StatelessWidget {
  LulAccessHistoryScreen({super.key});

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
              _languageController.getText('accesshistory'),
              style: const TextStyle(
                color: TColors.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: AccessHistoryService.getAccessHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading access history'));
          }

          final accessHistory = snapshot.data ?? [];

          // Get current device info
          return FutureBuilder<Map<String, dynamic>>(
            future: DeviceInfoHelper.getLoginDeviceInfo(),
            builder: (context, deviceSnapshot) {
              if (!deviceSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final currentDeviceInfo = deviceSnapshot.data!;

              // Find current device in history
              final currentDeviceHistory = accessHistory.firstWhere(
                (entry) =>
                    entry['os']?.toString().toLowerCase() ==
                        currentDeviceInfo['os']?.toString().toLowerCase() &&
                    entry['deviceName']?.toString().toLowerCase() ==
                        currentDeviceInfo['deviceName']
                            ?.toString()
                            .toLowerCase(),
                orElse: () => {
                  'os': currentDeviceInfo['os'],
                  'deviceName': currentDeviceInfo['deviceName'],
                  'city': 'Unknown',
                  'country': 'Unknown',
                  'ipAddress': 'Unknown',
                  'accessTime': DateTime.now().toIso8601String(),
                },
              );

              // Filter out current device from other history items
              final otherDevices = accessHistory
                  .where((entry) =>
                      entry['os']?.toString().toLowerCase() !=
                          currentDeviceInfo['os']?.toString().toLowerCase() ||
                      entry['deviceName']?.toString().toLowerCase() !=
                          currentDeviceInfo['deviceName']
                              ?.toString()
                              .toLowerCase())
                  .toList();

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Session Card (without badge)
                      Card(
                        color: THelperFunctions.isDarkMode(context)
                            ? TColors.primaryDark.withOpacity(0.3)
                            : TColors.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: TColors.secondary.withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(FontAwesomeIcons.shield,
                                      color: TColors.secondary),
                                  const SizedBox(width: 8),
                                  Obx(() => Text(
                                        _languageController
                                            .getText('current_session'),
                                        style: const TextStyle(
                                          color: TColors.secondary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildCurrentSessionInfo(
                                  currentDeviceHistory, currentDeviceInfo),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Recent Activity Section Title
                      Obx(() => Text(
                            _languageController.getText('recent_devices'),
                            style: FormTextStyle.getLabelStyle(context),
                          )),
                      const SizedBox(height: 16),

                      // Recent Activity List (including current device as first item)
                      // First, add current device with badge
                      _buildHistoryItem(currentDeviceHistory, context,
                          isCurrentDevice: true),

                      // Then add all other devices
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: otherDevices.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(otherDevices[index], context,
                              isCurrentDevice: false);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentSessionInfo(
      Map<String, dynamic> history, Map<String, dynamic> deviceInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(FontAwesomeIcons.mobile, deviceInfo['deviceName']),
        _buildInfoRow(FontAwesomeIcons.windows, deviceInfo['os']),
        _buildInfoRow(FontAwesomeIcons.locationDot,
            "${history['city']}, ${history['country']}"),
        _buildInfoRow(FontAwesomeIcons.networkWired, history['ipAddress']),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      // Parse the ISO-8601 timestamp correctly
      final accessTime = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();

      // Check if the timestamp is in the future
      if (accessTime.isAfter(now)) {
        // Handle future dates by assuming there's a year error
        // Create a corrected date by setting the year to current year
        final correctedTime = DateTime(
          now.year,
          accessTime.month,
          accessTime.day,
          accessTime.hour,
          accessTime.minute,
          accessTime.second,
          accessTime.millisecond,
          accessTime.microsecond,
        );

        // If still in the future (could happen if it's today but later time),
        // subtract a day to make it in the past
        final timeToUse = correctedTime.isAfter(now)
            ? correctedTime.subtract(const Duration(days: 1))
            : correctedTime;

        final difference = now.difference(timeToUse);
        return _formatDifference(difference);
      } else {
        // Normal case - timestamp is in the past
        final difference = now.difference(accessTime);
        return _formatDifference(difference);
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
      return 'Unknown time';
    }
  }

  // Helper method to format time difference
  String _formatDifference(Duration difference) {
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      // For older dates, show the actual date
      final dateFormat = DateFormat('MMM d, yyyy');
      return dateFormat.format(DateTime.now().subtract(difference));
    }
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, BuildContext context,
      {bool isCurrentDevice = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: THelperFunctions.isDarkMode(context)
          ? TColors.primaryDark.withOpacity(0.3)
          : TColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.desktop,
                  color: TColors.textWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['deviceName'] ?? item['os'],
                        style: const TextStyle(
                          color: TColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCurrentDevice)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Current Device',
                            style: TextStyle(
                              color: TColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(FontAwesomeIcons.windows, item['os']),
            _buildInfoRow(FontAwesomeIcons.locationDot,
                "${item['city']}, ${item['country']}"),
            _buildInfoRow(FontAwesomeIcons.networkWired, item['ipAddress']),
            _buildInfoRow(
              FontAwesomeIcons.clock,
              _formatTimestamp(item['accessTime']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: TColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              text,
              style: FormTextStyle.getInfoTextStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}
