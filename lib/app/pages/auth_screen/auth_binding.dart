import 'package:bam_bam_vendor/app/pages/pages.dart';
import 'package:bam_bam_vendor/domain/usecases/usecases.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        Get.put(
          AuthPresenter(Get.put(AuthUsecases(Get.find()), permanent: true)),
        ),
      ),
    );
  }
}
