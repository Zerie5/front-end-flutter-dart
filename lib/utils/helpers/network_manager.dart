import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../popups/loaders.dart';
import '../http/http_client.dart';

/// Manages the network connectivity status and provides methods to check and handle connectivity changes.
class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final RxList<ConnectivityResult> _connectionStatus =
      <ConnectivityResult>[].obs;

  // Observable variables for network status
  final RxBool hasInternetConnection = false.obs;
  final RxBool hasServerConnection = false.obs;
  final RxBool isCheckingConnection = false.obs;
  final RxString connectionMessage = 'Checking connection...'.obs;

  // Track if we've fully restored connectivity
  final RxBool _connectivityRestored = false.obs;

  // Flag to bypass connectivity checks (for development/testing)
  final RxBool bypassConnectivityChecks = false.obs;

  /// Initialize the network manager and set up a stream to continually check the connection status.
  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // Initial check
    checkConnectivity();
  }

  /// Update the connection status based on changes in connectivity
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectionStatus.value = result;
    final bool previousConnectionStatus = hasInternetConnection.value;

    // Check if we have any connection that's not "none"
    hasInternetConnection.value = !result.contains(ConnectivityResult.none) ||
        result.any((element) => element != ConnectivityResult.none);

    // If connection status changed
    if (previousConnectionStatus != hasInternetConnection.value) {
      if (hasInternetConnection.value) {
        // Connection restored - check server connectivity
        connectionMessage.value =
            'Internet connection restored. Checking server...';
        await checkServerConnectivity();

        // If both internet and server are available, mark as fully restored
        if (hasServerConnection.value) {
          _connectivityRestored.value = true;
          connectionMessage.value = 'Connection fully restored';
        }
      } else {
        // Connection lost
        hasServerConnection.value = false;
        _connectivityRestored.value = false;
        connectionMessage.value = 'No internet connection';
        LulLoaders.lulcustomToast(message: 'No Internet Connection');
      }
    }
  }

  /// Temporarily bypass connectivity checks (for development/testing)
  void setBypassConnectivityChecks(bool bypass) {
    bypassConnectivityChecks.value = bypass;

    if (bypass) {
      // Force set connectivity to true
      hasInternetConnection.value = true;
      hasServerConnection.value = true;
      _connectivityRestored.value = true;
      connectionMessage.value = 'Connectivity checks bypassed';
      print(
          'WARNING: Connectivity checks bypassed. This should only be used for development/testing.');
    } else {
      // Re-check connectivity
      checkConnectivity();
    }
  }

  /// Check both internet and server connectivity
  Future<void> checkConnectivity() async {
    // If bypassing connectivity checks, return immediately
    if (bypassConnectivityChecks.value) {
      hasInternetConnection.value = true;
      hasServerConnection.value = true;
      _connectivityRestored.value = true;
      return;
    }

    isCheckingConnection.value = true;

    try {
      // First check internet connectivity
      final internetConnected = await isConnected();
      hasInternetConnection.value = internetConnected;

      if (internetConnected) {
        // If internet is available, check server connectivity
        connectionMessage.value = 'Checking server connection...';

        // Check if the server is reachable at the correct port (8080)
        final serverReachable = await isServerIpReachable();
        print('Server reachable: $serverReachable');

        if (!serverReachable) {
          print(
              'Server is not reachable. Check network configuration or server status.');
          hasServerConnection.value = false;
          connectionMessage.value = 'Server not reachable';
          _connectivityRestored.value = false;
          isCheckingConnection.value = false;
          return;
        }

        // Run the test connection method for additional debugging
        await testServerConnection();

        // Try to check server connectivity with the health endpoint
        bool serverConnected = false;
        try {
          serverConnected = await checkServerConnectivity();
        } catch (e) {
          print('First server connectivity check failed: $e');

          // If the first attempt fails, try a fallback approach
          try {
            print('Trying fallback server connectivity check...');
            // Direct ping to the server using a simple GET request
            final response = await http
                .get(Uri.parse('${THttpHelper.baseUrl}/api/connectivity/ping'))
                .timeout(const Duration(seconds: 5));

            print('Fallback server response status: ${response.statusCode}');
            print('Fallback server response body: ${response.body}');

            // Check if the response is valid
            final isValidResponse = _isValidHealthResponse(response);
            print('Is valid health response: $isValidResponse');

            serverConnected = response.statusCode == 200 && isValidResponse;
            print('Fallback server check result: $serverConnected');
          } catch (fallbackError) {
            print('Fallback server check also failed: $fallbackError');
            serverConnected = false;
          }
        }

        hasServerConnection.value = serverConnected;

        // If both are connected, mark as fully restored
        if (serverConnected) {
          _connectivityRestored.value = true;
          connectionMessage.value = 'Connection fully restored';
        } else {
          connectionMessage.value = 'Server unavailable';
          _connectivityRestored.value = false;
        }
      } else {
        connectionMessage.value = 'No internet connection';
        hasServerConnection.value = false;
        _connectivityRestored.value = false;
      }
    } catch (e) {
      print('Error checking connectivity: $e');
      print('Error type: ${e.runtimeType}');
      connectionMessage.value = 'Error checking connection';
      hasInternetConnection.value = false;
      hasServerConnection.value = false;
      _connectivityRestored.value = false;
    } finally {
      isCheckingConnection.value = false;
    }
  }

  /// Test server connection using THttpHelper's test method
  Future<void> testServerConnection() async {
    try {
      print('Running detailed server connection test...');
      // Use a direct approach instead of THttpHelper.testConnection()
      print('=== Network Test ===');
      print('Device type: Physical Android device');
      print('Testing backend at: ${THttpHelper.baseUrl}');
      print('Network test started at: ${DateTime.now()}');

      final response = await http
          .get(
            Uri.parse('${THttpHelper.baseUrl}/api/connectivity/ping'),
            headers: THttpHelper.getHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      print('Response received: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Connection error type: ${e.runtimeType}');
      print('Error details: $e');

      // Additional network information
      print('\nDebug Info:');
      print('1. Check if backend is running on: ${THttpHelper.baseUrl}');
      print('2. Ensure phone and backend are on same network');
      print('3. Verify backend is listening on all interfaces (0.0.0.0)');
    }
  }

  /// Try alternative server URLs if the primary one fails
  Future<bool> tryAlternativeServers() async {
    // List of potential server URLs to try
    final List<String> alternativeUrls = [
      'http://192.168.100.79:8080', // Original URL
      'http://10.0.2.2:8080', // For Android emulator
      'http://localhost:8080', // For local testing
      // Add production URL if available
      // 'https://api.lulpay.com',
    ];

    // Skip the first URL if it's the same as the current baseUrl
    final startIndex = alternativeUrls[0] == THttpHelper.baseUrl ? 1 : 0;

    // Try each alternative URL
    for (int i = startIndex; i < alternativeUrls.length; i++) {
      final alternativeUrl = alternativeUrls[i];
      print('Trying alternative server URL: $alternativeUrl');

      try {
        // Extract host and port
        final Uri uri = Uri.parse(alternativeUrl);
        final String host = uri.host;
        final int port = uri.port > 0 ? uri.port : 8080;

        // Try to establish a socket connection
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 5),
        );

        // If successful, close the socket and update the baseUrl
        await socket.close();
        print('Successfully connected to alternative server: $alternativeUrl');

        // Show a message to the user
        LulLoaders.lulcustomToast(
          message: 'Connected to alternative server: $alternativeUrl',
        );

        // Return true to indicate success
        return true;
      } catch (e) {
        print('Failed to connect to alternative server $alternativeUrl: $e');
      }
    }

    // If all alternatives failed, return false
    return false;
  }

  /// Check if the server is reachable
  Future<bool> checkServerConnectivity() async {
    if (!hasInternetConnection.value) {
      hasServerConnection.value = false;
      return false;
    }

    try {
      connectionMessage.value = 'Checking server connection...';

      // First, check if the server IP is reachable
      final serverReachable = await isServerIpReachable();

      if (!serverReachable) {
        // Try alternative servers before giving up
        final alternativeSuccess = await tryAlternativeServers();

        if (!alternativeSuccess) {
          hasServerConnection.value = false;
          connectionMessage.value =
              'Server not reachable. Check network configuration.';
          return false;
        }
      }

      // Print the full URL for debugging
      print(
          'Checking server connectivity at: ${THttpHelper.baseUrl}/api/connectivity/ping');

      // Use the same approach as testConnection method
      final response = await http
          .get(
            Uri.parse('${THttpHelper.baseUrl}/api/connectivity/ping'),
            headers: THttpHelper.getHeaders(),
          )
          .timeout(
              const Duration(seconds: 10)); // Increase timeout to 10 seconds

      print('Server response status code: ${response.statusCode}');
      print('Server response body: ${response.body}');

      // Check if the response is valid
      final isValidResponse = _isValidHealthResponse(response);
      print('Is valid health response: $isValidResponse');

      hasServerConnection.value = response.statusCode == 200 && isValidResponse;

      if (hasServerConnection.value) {
        connectionMessage.value = 'Connected to server';
      } else {
        connectionMessage.value = 'Server returned invalid response';
      }

      return hasServerConnection.value;
    } catch (e) {
      print('Server connectivity error: $e');
      print('Error type: ${e.runtimeType}');
      hasServerConnection.value = false;

      // Provide more specific error messages based on the exception type
      if (e is SocketException) {
        connectionMessage.value = 'Cannot connect to server: Network error';
      } else if (e is TimeoutException) {
        connectionMessage.value = 'Server connection timed out';
      } else if (e is FormatException) {
        connectionMessage.value = 'Server returned invalid data format';
      } else {
        connectionMessage.value = 'Cannot connect to server: ${e.toString()}';
      }

      return false;
    }
  }

  /// Check if the health response is valid
  bool _isValidHealthResponse(http.Response response) {
    try {
      if (response.statusCode != 200) return false;

      // Try to parse the response body as JSON
      final Map<String, dynamic> data = json.decode(response.body);

      // Check if the response has the expected format
      // The new format includes status, message, and timestamp fields
      final bool hasRequiredFields = data.containsKey('status') &&
          data.containsKey('message') &&
          data.containsKey('timestamp');

      // Check if the status is "UP"
      final bool isStatusUp = data['status'] == 'UP';

      return hasRequiredFields && isStatusUp;
    } catch (e) {
      print('Error parsing health response: $e');
      return false;
    }
  }

  /// Check if we have full connectivity (both internet and server)
  bool hasFullConnectivity() {
    return hasInternetConnection.value && hasServerConnection.value;
  }

  /// Get the connectivity restored status
  RxBool get connectivityRestored => _connectivityRestored;

  /// Check the internet connection status.
  /// Returns `true` if connected, `false` otherwise.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if the server IP is reachable
  Future<bool> isServerIpReachable() async {
    try {
      // Extract host and port from baseUrl
      final Uri uri = Uri.parse(THttpHelper.baseUrl);
      final String host = uri.host;
      final int port = uri.port > 0
          ? uri.port
          : 8080; // Default to 8080 if port is not specified

      print('Checking if server IP is reachable: $host:$port');

      // Try to establish a socket connection to the server
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 10), // Increase timeout to 10 seconds
      );

      // If we get here, the connection was successful
      await socket.close();
      print('Server reachable: true');
      return true;
    } catch (e) {
      print('IP reachability check failed: $e');
      print('Server reachable: false');
      print(
          'Server is not reachable. Check network configuration or server status.');
      return false;
    }
  }

  /// Dispose or close the active connectivity stream.
  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel();
  }
}
