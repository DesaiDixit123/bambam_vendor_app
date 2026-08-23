import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Addvehicale7Screen extends StatelessWidget {
  const Addvehicale7Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Add New Vehicle",
          ),
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () async {
                // prevent double-tap while request is running
                if (controller.isRegisteringVehicle) return;
                await controller.registerVehicle();
              },
              text: "Save ",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              StepHeaderWidget(
                title: "Terms & Conditions ",
                nextTitle: " ",
                currentStep: 7,
                totalSteps: 7,
                activeColor: ColorsValue.appColor,
                inactiveColor: ColorsValue.yelloCB,
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                maxLines: 7,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Terms & Conditions  *".tr,

                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
                onChanged: (vaule) {
                  controller.update();
                },
                title: "Terms & Conditions  *".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
            ],
          ),
        );
      },
    );
  }
}
