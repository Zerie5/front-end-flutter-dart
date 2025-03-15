import 'package:get/get.dart';
import 'package:lul/features/wallet/recieve/controllers/qr_code_controller.dart';

class QrCodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrCodeController>(() => QrCodeController());
  }
}
