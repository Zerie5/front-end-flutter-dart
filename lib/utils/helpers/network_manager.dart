import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../popups/loaders.dart';
import '../http/http_client.dart';

enum ConnectivityStatus {
  checking,
  connected,
  internetOnly,
  serverUnreachable,
  offline,
}

/// Manages the network connectivity status and provides methods to check and handle connectivity changes.
class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Core status tracking
  final Rx<ConnectivityStatus> status = ConnectivityStatus.checking.obs;
  final RxString connectionMessage = 'Checking connection...'.obs;

  // Keep these for backward compatibility
  final RxBool hasInternetConnection = false.obs;
  final RxBool hasServerConnection = false.obs;
  final RxBool isCheckingConnection = false.obs;
  final RxBool _connectivityRestored = false.obs;
  final RxBool bypassConnectivityChecks = false.obs;

  // Update Rx values whenever status changes
  void _updateCompatibilityValues() {
    hasInternetConnection.value = status.value != ConnectivityStatus.offline;
    hasServerConnection.value = status.value == ConnectivityStatus.connected;
    isCheckingConnection.value = status.value == ConnectivityStatus.checking;
    _connectivityRestored.value = status.value == ConnectivityStatus.connected;
  }

  @override
  void onInit() {
    super.onInit();

    // Listen to our own status changes and update compatibility values
    ever(status, (_) => _updateCompatibilityValues());

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    checkConnectivity();
  }

  void _log(String message, [dynamic data]) {
    print('[NetworkManager] $message ${data ?? ''}');
  }

  void setBypassConnectivityChecks(bool bypass) {
    bypassConnectivityChecks.value = bypass;
    if (bypass) {
      status.value = ConnectivityStatus.connected;
      connectionMessage.value = 'Connectivity checks bypassed';
      _log('Connectivity checks bypassed');
    } else {
      checkConnectivity();
    }
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final bool hasConnection = results.any((e) => e != ConnectivityResult.none);
    if (!hasConnection) {
      status.value = ConnectivityStatus.offline;
      connectionMessage.value = 'No internet connection';
      LulLoaders.lulcustomToast(message: 'No Internet Connection');
      return;
    }
    connectionMessage.value =
        'Internet connection restored. Checking server...';
    await checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    if (bypassConnectivityChecks.value) {
      status.value = ConnectivityStatus.connected;
      connectionMessage.value = 'Bypass active';
      return;
    }

    status.value = ConnectivityStatus.checking;
    connectionMessage.value = 'Checking connection...';

    try {
      final connected = await isConnected();
      if (!connected) {
        status.value = ConnectivityStatus.offline;
        connectionMessage.value = 'No internet connection';
        return;
      }

      // First try default server
      final serverOk = await _trySocketAndPing(THttpHelper.baseUrl);
      if (serverOk) {
        status.value = ConnectivityStatus.connected;
        connectionMessage.value = 'Connection fully restored';
        return;
      }

      // Then try alternatives
      final fallbackOk = await _tryAlternativeServers();
      if (fallbackOk) {
        status.value = ConnectivityStatus.connected;
        connectionMessage.value = 'Connected to alternative server';
      } else {
        status.value = ConnectivityStatus.serverUnreachable;
        connectionMessage.value = 'Server not reachable';
      }
    } catch (e) {
      _log('Error during connectivity check', e);
      status.value = ConnectivityStatus.offline;
      connectionMessage.value = 'Error checking connection';
    }
  }

  Future<bool> _trySocketAndPing(String baseUrl) async {
    try {
      // First try socket connection (faster)
      final uri = Uri.parse(baseUrl);
      _log('Attempting socket connection to', uri);

      try {
        final socket = await Socket.connect(uri.host, uri.port,
            timeout: const Duration(seconds: 3));
        await socket.close();
        _log('Socket connection successful');

        // If socket works, we can consider the server reachable even if ping fails
        try {
          final response = await http
              .get(Uri.parse('$baseUrl/api/connectivity/ping'),
                  headers: THttpHelper.getHeaders())
              .timeout(const Duration(seconds: 5));

          _log('Ping response',
              {'status': response.statusCode, 'body': response.body});

          // If we get any response at all, the server is reachable
          return response.statusCode >= 200 && response.statusCode < 500;
        } catch (pingError) {
          _log('Ping failed but socket connected', pingError);
          return true; // Socket connected, so server is reachable even if ping fails
        }
      } catch (socketError) {
        _log('Socket connection failed', socketError);

        // If socket fails, try ping as fallback
        final response = await http
            .get(Uri.parse('$baseUrl/api/connectivity/ping'),
                headers: THttpHelper.getHeaders())
            .timeout(const Duration(seconds: 5));

        _log('Fallback ping response', {'status': response.statusCode});
        return response.statusCode >= 200 && response.statusCode < 500;
      }
    } catch (e) {
      _log('Both socket and ping failed', e);
      return false;
    }
  }

  Future<bool> _tryAlternativeServers() async {
    final urls = [
      ///'https://lul-backend.onrender.com',
      THttpHelper.baseUrl,
    ];

    for (final url in urls) {
      if (url == THttpHelper.baseUrl) continue;
      if (await _trySocketAndPing(url)) {
        _log('Connected to alternative server', url);
        LulLoaders.lulcustomToast(
            message: 'Connected to alternative server: $url');
        return true;
      }
    }
    return false;
  }

  bool _isValidHealthResponse(http.Response response) {
    try {
      if (response.statusCode < 200 || response.statusCode >= 300) return false;

      // First try to parse as JSON
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        // Check for both the old and new response formats
        return (data['status'] == 'UP' && data.containsKey('timestamp')) ||
            (data.containsKey('success') && data['success'] == true);
      } catch (jsonError) {
        // If not JSON but status code is 200, consider it valid anyway
        return response.statusCode == 200;
      }
    } catch (e) {
      _log('Invalid health response format', e);
      return false;
    }
  }

  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.any((e) => e != ConnectivityResult.none);
    } on PlatformException {
      return false;
    }
  }

  bool get hasFullConnectivity => status.value == ConnectivityStatus.connected;
  RxBool get connectivityRestored => _connectivityRestored;

  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}
