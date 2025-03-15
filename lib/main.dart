import 'package:flutter/material.dart';
import 'package:lul/app.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:lul/utils/helpers/network_manager.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the splash screen visible until initialization is complete
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase and other dependencies
  await App.initDependencies();

  // Initialize NetworkManager
  final networkManager = NetworkManager();
  Get.put(networkManager);

  // Remove the splash screen when ready
  FlutterNativeSplash.remove();

  runApp(const App());
}
