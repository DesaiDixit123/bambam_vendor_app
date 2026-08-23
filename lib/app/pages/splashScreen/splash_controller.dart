import 'dart:async';

import 'package:bam_bam_vendor/domain/repositories/local_storage_keys.dart';
import 'package:bam_bam_vendor/domain/repositories/repository.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/navigators/routes_management.dart';
import 'package:bam_bam_vendor/app/utils/utility.dart';
import 'package:bam_bam_vendor/app/pages/splashScreen/splash_presenter.dart';

class SplashController extends GetxController {
  SplashController(this.splashPresenter);

  final SplashPresenter splashPresenter;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  String? appUrl;


void startTimer() async {
  await Utility.checker.checkUpdate();

  Future.delayed(const Duration(seconds: 2)).then((value) {
    final repo = Get.find<Repository>();
    final accessToken = repo.getStringValue(LocalKeys.authToken);

   
   
    if (accessToken.isNotEmpty) {
      // ✅ This prints the actual saved token
      print("✅ User logged in. Access Token: $accessToken");

      // You can also show it in a snackbar for debugging if needed:
      // Utility.showMessage("Access Token: $accessToken", MessageType.information, null, "ok");

 RouteManagement.gotoHomeScreen();
           }else{
        print("⚠️ No access token found. Redirecting to gotoIntro1Screen...");
         RouteManagement.gotoLogainScreen();
    }
  });

  update();
}

 
}
