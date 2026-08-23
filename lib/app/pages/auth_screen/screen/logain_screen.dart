import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/app/pages/auth_screen/screen/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: Dimens.edgeInsets20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      AssetConstants.logain_bg,
                      height: Get.height * 0.25,
                    ),
                  ),
                  Dimens.boxHeight32,
                  Text("vendor_logain".tr, style: Styles.g1txtColor60018),
                  Dimens.boxHeight16,
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.changeLoginMode(0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),

                                    child: Center(
                                      child: Text(
                                        "login_usename".tr,
                                        style: controller.loginMode == 0
                                            ? Styles.g1txtColor60014
                                            : Styles.g7txtColor40012,
                                      ),
                                    ),
                                  ),
                                  controller.loginMode == 0
                                      ? Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: ColorsValue.appColor,
                                            borderRadius: BorderRadius.circular(
                                              Dimens.ten,
                                            ),
                                          ),
                                        )
                                      : Dimens.boxWidth0,
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.changeLoginMode(1),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "logain_otp".tr,
                                        style: controller.loginMode == 1
                                            ? Styles.g1txtColor60014
                                            : Styles.g7txtColor40012,
                                      ),
                                    ),
                                  ),
                                  controller.loginMode == 1
                                      ? Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: ColorsValue.appColor,
                                            borderRadius: BorderRadius.circular(
                                              Dimens.ten,
                                            ),
                                          ),
                                        )
                                      : Dimens.boxWidth0,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: ColorsValue.borderColor, height: 1),
                    ],
                  ),
                  Dimens.boxHeight24,
                  if (controller.loginMode == 0) ...[
                    // Username field
                    CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      style: Styles.g7txtColor70014,
                      hintText: "enter_usename".tr,
                      //filled: true,
                      isBorder: true,
                      isTitle: true,
                      isCompulsory: true,
                      textEditingController: controller.usernameController,
                      onChanged: (vaule) {
                        controller.update();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "enter_usename".tr;
                        }
                        return null;
                      },
                      title: "username".tr,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                    ),
                    Dimens.boxHeight16,
                    // Password field
                    CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      isCompulsory: true,
                      style: Styles.g7txtColor70014,
                      hintText: "enter_password".tr,
                      //filled: true,
                      isBorder: true,
                      isTitle: true,
                      textEditingController: controller.passwordController,
                      onChanged: (vaule) {
                        controller.update();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "enter_password".tr;
                        }
                        return null;
                      },
                      obscureText: !controller.isPasswordVisible.value,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordVisible.value
                              ? Icons
                                    .visibility // 👀 password shown
                              : Icons.visibility_off, // 🙈 password hidden
                          color: ColorsValue.appColor,
                        ),
                        onPressed: () {
                          controller.isPasswordVisible.value =
                              !controller.isPasswordVisible.value;
                          controller.update();
                        },
                      ),

                      title: "password".tr,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                    ),
                    Dimens.boxHeight10,
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(() => ForgotPasswordScreen());
                        },
                        child: Text(
                          "Forgot Password?",
                          style: Styles.appColor60014.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Dimens.boxHeight16,
                    CustomButton(
                      onPressed: controller.loginWithUsername,
                      text: "logain".tr,
                      textStyle: Styles.whiteColorW60016,
                      backgroundColor: ColorsValue.appColor,
                      radius: Dimens.twelve,
                    ),
                  ] else ...[
                    Text("mobile_de".tr, style: Styles.g6txtColor40012),
                    Dimens.boxHeight16,
                    // Mobile number field — uses dedicated mobileController (separate from usernameController)
                    CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      style: Styles.g7txtColor70014,
                      hintText: "enter_mobile_number".tr,

                      isBorder: true,
                      isCompulsory: true,
                      isTitle: true,
                      keyboardType: TextInputType.phone,
                      textEditingController: controller.mobileController,
                      onChanged: (vaule) {
                        controller.update();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "enter_mobile_number".tr;
                        }
                        return null;
                      },
                      title: "mobile_number".tr,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                    ),
                    Dimens.boxHeight16,
                    CustomButton(
                      onPressed: controller.getOtp,
                      text: "get_otp".tr,
                      textStyle: Styles.whiteColorW60016,
                      backgroundColor: ColorsValue.appColor,
                      radius: Dimens.twelve,
                    ),
                  ],
                  Dimens.boxHeight16,
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        RouteManagement.gotoRegisterScreen();
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
        );
      },
    );
  }
}
