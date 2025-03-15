import 'package:get/get.dart';
import 'package:lul/services/user_info_service.dart';
import 'package:lul/utils/popups/loaders.dart';

class QrCodeController extends GetxController {
  // Observable variables
  final RxString uniqueId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool loadedFromStorage = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUniqueId();
  }

  /// Loads the user's worker ID, first trying from storage, then from the backend API if needed
  Future<void> loadUniqueId() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      loadedFromStorage.value = false;

      // First try to get the ID from storage
      print('QrCodeController: Trying to load worker ID from storage...');
      final storageId = await UserInfoService.getUserUniqueIdFromStorage();

      if (storageId != null && storageId.isNotEmpty) {
        // Successfully loaded from storage
        uniqueId.value = storageId;
        loadedFromStorage.value = true;
        print('QrCodeController: Worker ID loaded from storage: $storageId');
        isLoading.value = false;
        return;
      }

      // If not found in storage, try to get from the API
      print('QrCodeController: Worker ID not found in storage, trying API...');
      final id = await UserInfoService.getWorkerIdFromApi();

      if (id != null && id.isNotEmpty) {
        uniqueId.value = id;
        print('QrCodeController: Worker ID loaded from API: $id');
      } else {
        hasError.value = true;
        errorMessage.value =
            'Could not retrieve your worker ID from the server';
        print('QrCodeController: Failed to load worker ID from API');

        // Show error toast
        LulLoaders.lulerrorSnackBar(
          title: 'Error',
          message: 'Could not retrieve your worker ID from the server',
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'An error occurred while retrieving your worker ID: $e';
      print('QrCodeController: Error loading worker ID: $e');

      // Show error toast
      LulLoaders.lulerrorSnackBar(
        title: 'Error',
        message: 'An error occurred while retrieving your worker ID',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Force refresh the worker ID from the backend API
  Future<void> refreshFromApi() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      loadedFromStorage.value = false;

      print('QrCodeController: Force refreshing worker ID from API...');

      // Get the worker ID directly from the API, bypassing storage
      final id = await UserInfoService.getWorkerIdFromApi();

      if (id != null && id.isNotEmpty) {
        uniqueId.value = id;
        print('QrCodeController: Worker ID refreshed from API: $id');
      } else {
        hasError.value = true;
        errorMessage.value =
            'Could not retrieve your worker ID from the server';
        print('QrCodeController: Failed to refresh worker ID from API');

        // Show error toast
        LulLoaders.lulerrorSnackBar(
          title: 'Error',
          message: 'Could not retrieve your worker ID from the server',
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'An error occurred while connecting to the server: $e';
      print('QrCodeController: Error refreshing worker ID from API: $e');

      // Show error toast
      LulLoaders.lulerrorSnackBar(
        title: 'Server Error',
        message:
            'An error occurred while retrieving your worker ID from the server',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry loading the worker ID
  void retryLoading() {
    loadUniqueId();
  }
}
