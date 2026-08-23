import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/domain/domain.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure HomeController is recreated automatically if removed (fenix: true)
    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.put(
          HomePresenter(Get.put(HomeUsecases(Get.find()), permanent: true)),
        ),
      ),
      fenix: true,
    );
  }
}
