import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lul/utils/http/http_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lul/utils/tokens/auth_storage.dart';
import 'package:dio/dio.dart';

class FCMService extends GetxService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final String _deviceIdKey = 'device_id';

  Future<FCMService> init() async {
    print('FCMService: Initializing');

    // Request permission
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // We don't send FCM token here anymore - it will be sent after login
    // Instead, just get the token and store it for later use
    final token = await _firebaseMessaging.getToken();
    print('FCMService: FCM Token generated: $token');

    // Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('FCMService: FCM token refreshed: $newToken');
      // Only send if user is logged in
      _sendTokenIfLoggedIn(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background/terminated tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    print('FCMService: Initialization complete');
    return this;
  }

  // Helper method to check login status and send token if logged in
  Future<void> _sendTokenIfLoggedIn(String token) async {
    final authToken = await AuthStorage.getToken();
    if (authToken != null) {
      // User is logged in, send the token
      await _sendTokenToBackend(token);
    } else {
      print('FCMService: User not logged in, skipping FCM token update');
    }
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print(
        'FCMService: User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        final payload = response.payload;
        if (payload != null) {
          // Handle navigation based on payload
          _handlePayload(payload);
        }
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    return deviceId ?? '';
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final deviceId = await _getDeviceId();
      final authToken = await AuthStorage.getToken();

      if (authToken == null) {
        print('FCMService: No auth token available, skipping FCM token update');
        return;
      }

      // Prepare request body
      final body = {
        'token': token,
        'deviceId': deviceId,
      };

      // Use the Dio instance from THttpHelper
      final response = await THttpHelper.dio.post(
        '/api/notifications/fcm-token',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('FCMService: FCM token sent to backend successfully');
      } else {
        print(
            'FCMService: Failed to send FCM token to backend. Status: ${response.statusCode}, Response: ${response.data}');
      }
    } catch (e) {
      print('FCMService: Error sending FCM token to backend: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('FCMService: Got a message in foreground!');
    print('FCMService: Message data: ${message.data}');

    if (message.notification != null) {
      await _showLocalNotification(message);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('FCMService: Notification tapped!');
    if (message.data.isNotEmpty) {
      _handlePayload(message.data.toString());
    }
  }

  void _handlePayload(String payload) {
    print('FCMService: Handling payload: $payload');
    // Handle navigation based on payload
    // Example:
    // if (payload.contains('transaction')) {
    //   Get.toNamed('/transaction-details', arguments: {'id': extractId(payload)});
    // }
  }
}
