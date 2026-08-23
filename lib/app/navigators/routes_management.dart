import 'package:get/get.dart';

import 'app_pages.dart';

abstract class RouteManagement {
  static void gotoHomeScreen() => Get.offAllNamed<void>(Routes.homeScreen);
  static void goToInAppUpdateScreen(String appUrl) =>
      Get.offAllNamed<void>(Routes.inAppUpdateScreen, arguments: appUrl);
  static void gotoLogainScreen() => Get.offAllNamed<void>(Routes.logainScreen);
  static void gotoOtpScreen({dynamic arguments}) => Get.toNamed<void>(Routes.otpScreen, arguments: arguments);
  static void gotoRegisterstep1Screen() =>
      Get.toNamed<void>(Routes.registerstep1Screen);
  static void gotoRegisterstep2Screen() =>
      Get.toNamed<void>(Routes.registerstep2Screen);
  static void gotoRegisterstep3Screen() =>
      Get.toNamed<void>(Routes.registerstep3Screen);
  static void gotoRegisterstep4Screen() =>
      Get.toNamed<void>(Routes.registerstep4Screen);
  static void gotoReviewingScreen() =>
      Get.toNamed<void>(Routes.reviewingScreen);
  static void gotoBookingResponseScreen() =>
      Get.toNamed<void>(Routes.bookingResponseScreen);
  static void gotoRideDetilesScreen() =>
      Get.toNamed<void>(Routes.rideDetilesScreen);
  static void gotoDriverVehicalDetiles() =>
      Get.toNamed<void>(Routes.driverVehicalDetiles);
  static void gotoRegisterScreen() => Get.toNamed<void>(Routes.registerScreen);
  static void gotoInRegister1() => Get.toNamed<void>(Routes.inRegister1);
  static void gotoInRegister2() => Get.toNamed<void>(Routes.inRegister2);
  static void gotoInRegister3() => Get.toNamed<void>(Routes.inRegister3);
  static void gotoInRegister4() => Get.toNamed<void>(Routes.inRegister4);
  static void gotoAllocateVehicleScreen() =>
      Get.toNamed<void>(Routes.allocateVehicleScreen);
  static void gotoDriverAllocateScreen() =>
      Get.toNamed<void>(Routes.driverAllocateScreen);
  static void gotoDriverHistoryScreen() =>
      Get.toNamed<void>(Routes.driverHistoryScreen);
  static void gotoVehicleHistoryScreen() =>
      Get.toNamed<void>(Routes.vehicleHistoryScreen);
  static void gotoTripcancelScreen() =>
      Get.toNamed<void>(Routes.tripcancelScreen);
  static void gotoTripcancellationPolicyScreen() =>
      Get.toNamed<void>(Routes.tripcancellationPolicyScreen);
  static void gotoTripdetilesScreen() =>
      Get.toNamed<void>(Routes.tripdetilesScreen);
  static void gotoTriplogoHomepage() =>
      Get.toNamed<void>(Routes.triplogoHomepage);
  static void gotoFineboardDetilesScreen() =>
      Get.toNamed<void>(Routes.fineboardDetilesScreen);
  static void gotoRidereviewsDetilesscreen() =>
      Get.toNamed<void>(Routes.ridereviewsDetilesscreen);
  static void gotoTransactionHistoryscreen() =>
      Get.toNamed<void>(Routes.transactionHistoryscreen);
  static void gotoTopUpwalletscreen() =>
      Get.toNamed<void>(Routes.topUpwalletscreen);
  static void gotoWithdrawScreen() => Get.toNamed<void>(Routes.withdrawScreen);
  static void gotoAddTicketscreen() =>
      Get.toNamed<void>(Routes.addTicketscreen);
  static void gotoTicketDetilesscreen() =>
      Get.toNamed<void>(Routes.ticketDetilesscreen);
  static void gotoAddNewdriversScreen() =>
      Get.toNamed<void>(Routes.addNewdriversScreen);
  static void gotoDriverHistorysScreen() =>
      Get.toNamed<void>(Routes.driverHistorysScreen);
  static void gotoTripDetilesScreen() =>
      Get.toNamed<void>(Routes.tripDetilesScreen);
  static void gotoTripHistorysScreen() =>
      Get.toNamed<void>(Routes.tripHistorysScreen);
  static void gotoAddvehicale1Screen() =>
      Get.toNamed<void>(Routes.addvehicale1Screen);
  static void gotoAddvehicale2Screen() =>
      Get.toNamed<void>(Routes.addvehicale2Screen);
  static void gotoAddvehicale3Screen() =>
      Get.toNamed<void>(Routes.addvehicale3Screen);
  static void gotoAddvehicale4Screen() =>
      Get.toNamed<void>(Routes.addvehicale4Screen);
  static void gotoAddvehicale5Screen() =>
      Get.toNamed<void>(Routes.addvehicale5Screen);
  static void gotoAddvehicale6Screen() =>
      Get.toNamed<void>(Routes.addvehicale6Screen);
  static void gotoAddvehicale7Screen() =>
      Get.toNamed<void>(Routes.addvehicale7Screen);
  static void gotoManagevehicleDetilesscreen() =>
      Get.toNamed<void>(Routes.managevehicleDetilesscreen);
  static void gotoProfileHomescreen() =>
      Get.toNamed<void>(Routes.profileHomescreen);
  static void gotoCityPreferenceScreen() =>
      Get.toNamed<void>(Routes.cityPreferenceScreen);
  static void gotoRingtoneSettingsScreen() =>
      Get.toNamed<void>(Routes.ringtoneSettingsScreen);
  static void gotoNotificationsScreen() =>
      Get.toNamed<void>(Routes.notificationsScreen);
  static void gotoFaqScreen() =>
      Get.toNamed<void>(Routes.faqScreen);
}
