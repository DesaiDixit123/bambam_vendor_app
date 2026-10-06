import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          appBar: AppBarWidget(
            title: "Become a BamBam Vendor ",
            onTapBack: () {
              Get.back();
            },
          ),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                if (controller.selectedOption == 1) {
                  RouteManagement.gotoInRegister1();
                } else if (controller.selectedOption == 2) {
                  RouteManagement.gotoRegisterstep1Screen();
                } else {
                  Utility.errorMessage("Please select one option");
                }
              },
              text: "Next",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: Dimens.edgeInsets20,
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(AssetConstants.with_car),
                        Dimens.boxHeight16,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Radio<int>(
                              value: 1,
                              groupValue: controller.selectedOption,
                              activeColor: Colors.orange,
                              onChanged: (value) {
                                controller.selectedOption = value!;
                                controller.update();
                              },
                            ),

                            Text(
                              "Do you have a car?",
                              style: Styles.g1txtColor60016,
                            ),
                          ],
                        ),

                        Dimens.boxHeight30,
                        Image.asset(AssetConstants.withCarorDriver),

                        Dimens.boxHeight16,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Radio<int>(
                              value: 2,
                              groupValue: controller.selectedOption,
                              activeColor: Colors.orange,

                              onChanged: (value) {
                                controller.selectedOption = value!;
                                controller.update();
                              },
                            ),

                            Text(
                              "Have a fleet of cars and drivers?",
                              style: Styles.g1txtColor60016,
                            ),
                          ],
                        ),

                        // InkWell(
                        //   onTap: () {
                        //     RouteManagement.gotoInRegister1();
                        //   },
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: ColorsValue.appColor,
                        //       borderRadius: BorderRadius.circular(Dimens.twelve),
                        //     ),
                        //     child: Padding(
                        //       padding: Dimens.edgeInsets10,
                        //       child: Text(
                        //         "reg2".tr,
                        //         style: Styles.whiteColorW60012.copyWith(
                        //           fontSize: Dimens.eighteen,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // Dimens.boxHeight16,
                        // InkWell(
                        //   onTap: () {
                        //     RouteManagement.gotoRegisterstep1Screen();
                        //   },
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       color: ColorsValue.appColor,
                        //       borderRadius: BorderRadius.circular(Dimens.twelve),
                        //     ),
                        //     child: Padding(
                        //       padding: Dimens.edgeInsets10,
                        //       child: Text(
                        //         "reg3".tr,
                        //         style: Styles.whiteColorW60012.copyWith(
                        //           fontSize: Dimens.eighteen,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
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
