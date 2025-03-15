import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';

class DeviceInfoHelper {
  static const String _deviceIdKey = 'device_unique_id';

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceData = '';
    String deviceId = '';
    String deviceName = '';
    String os = '';

    if (kIsWeb) {
      // Handle web platform
      final webInfo = await deviceInfo.webBrowserInfo;
      deviceId = webInfo.userAgent ?? 'unknown';
      deviceName = webInfo.browserName.toString();
      os = 'Web';
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceData = [
        androidInfo.brand, // Device manufacturer
        androidInfo.model, // Device model
        androidInfo.product, // Product name
        androidInfo.hardware, // Hardware name
        androidInfo.device, // Device name
        androidInfo.display, // Build display
        androidInfo.board, // Board name
      ].join('_');
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceData = [
        iosInfo.name, // Device name
        iosInfo.model, // Device model
        iosInfo.systemName, // OS name
        iosInfo.systemVersion, // OS version
        iosInfo.localizedModel, // Localized model
        iosInfo.utsname.machine, // Hardware type
      ].join('_');
    }

    // Generate SHA-256 hash of the device data
    final bytes = utf8.encode(deviceData);
    final hash = sha256.convert(bytes);

    return hash.toString();
  }

  static Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.brand} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name ?? 'iOS Device';
    }
    return 'Unknown Device';
  }

  static Future<String> getDeviceOS() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return 'Android ${androidInfo.version.release}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return '${iosInfo.systemName} ${iosInfo.systemVersion}';
    }
    return 'Unknown OS';
  }

  static Future<Map<String, String>> getLoginDeviceInfo() async {
    try {
      return {
        'deviceId': await getDeviceId(),
        'deviceName': await getDeviceName(),
        'os': await getDeviceOS(),
      };
    } catch (e) {
      print('DeviceInfoHelper error: $e');
      return {'deviceId': 'unknown', 'deviceName': 'unknown', 'os': 'unknown'};
    }
  }
}
