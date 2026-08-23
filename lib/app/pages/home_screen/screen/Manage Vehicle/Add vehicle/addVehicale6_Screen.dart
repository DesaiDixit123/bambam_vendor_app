import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Addvehicale6Screen extends StatelessWidget {
  const Addvehicale6Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () => RouteManagement.gotoAddvehicale7Screen(),
              text: "Save & Continue",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Add New Vehicle",
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              //
              StepHeaderWidget(
                title: "Vehicle Features",
                nextTitle: "Next : Terms & Conditions ",
                currentStep: 6,
                totalSteps: 7,
                activeColor: ColorsValue.appColor,
                inactiveColor: ColorsValue.yelloCB,
              ),
              Dimens.boxHeight16,
              FacilityListWidget(),
            ],
          ),
        );
      },
    );
  }
}
