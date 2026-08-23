import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pcf;

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        if (Get.arguments != null && Get.arguments is String) {
          final String argMobile = Get.arguments as String;
          if (controller.mobile != argMobile) {
            controller.mobile = argMobile;
            controller.mobileController.text = argMobile; // ✅ fixed: was usernameController
          }
        }
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBarWidget(
            onTapBack: () {
              Get.back();
            },
            title: "",
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: Dimens.edgeInsets20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              
                  children: [
                    Dimens.boxHeight16,
                    Center(child: SvgPicture.asset(AssetConstants.otp_bg)),
                    Dimens.boxHeight32,
                    Text("otp_verify".tr, style: Styles.g1txtColor60018),
                    Dimens.boxHeight6,
                    Text("Enter the OTP sent to +91 ${controller.mobile ?? controller.usernameController.text}", style: Styles.g6txtColor40012),
                    Dimens.boxHeight30,
                    pcf.PinCodeTextField(
                      appContext: context,
                      length: 6,
                      keyboardType: TextInputType.number,
                      autoFocus: true,
                      onCompleted: (pin) {
                        controller.code = pin;
                      },
                      onChanged: (value) {
                        controller.code = value;
                      },
                      pinTheme: pcf.PinTheme(
                        shape: pcf.PinCodeFieldShape.box,
                        fieldHeight: Get.width / 8,
                        fieldWidth: Get.width / 8,
                        borderRadius: BorderRadius.circular(Dimens.ten),
                        selectedColor: ColorsValue.g1txtColor,
                        activeColor: ColorsValue.g1txtColor,
                        inactiveColor: ColorsValue.borderColor,
                        activeFillColor: ColorsValue.fildColos,
                        selectedFillColor: ColorsValue.fildColos,
                        inactiveFillColor: ColorsValue.fildColos,
                        errorBorderColor: ColorsValue.redColor,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: ColorsValue.appColor,
                      enableActiveFill: true,
                    ),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            controller.canResendOtp.value
                                ? GestureDetector(
                                    onTap: controller.resendOtp,
                                    child: Text(
                                      "Resend OTP",
                                      style: Styles.appColor60014,
                                    ),
                                  )
                                : Text(
                                    "00:${controller.otpSeconds.value.toString().padLeft(2, '0')}",
                                    style: Styles.appColor60014,
                                  ),
                          ],
                        )),
                    Dimens.boxHeight30,
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Center(child: Text(controller.code, style: Styles.g1txtColor40012)),
                    // ),
                    CustomButton(
                      onPressed: controller.verifyOtp,
                      text: "verify_otp".tr,
                      textStyle: Styles.whiteColorW60016,
                      backgroundColor: ColorsValue.appColor,
                      radius: Dimens.twelve,
                    ),
                    Dimens.boxHeight16,
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          RouteManagement.gotoRegisterstep1Screen();
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "don_account".tr,
                            style: Styles.g7txtColor70014,
                            children: [
                              TextSpan(text: "  "),
                              TextSpan(
                                text: "register".tr,
                                style: Styles.appColor60014,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
