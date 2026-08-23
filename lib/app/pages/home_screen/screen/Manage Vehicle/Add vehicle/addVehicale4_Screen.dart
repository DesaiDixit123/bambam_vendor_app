import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Addvehicale4Screen extends StatelessWidget {
  const Addvehicale4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () => RouteManagement.gotoAddvehicale5Screen(),
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
              StepHeaderWidget(
                title: "Exterior Images",
                nextTitle: "Next : Interior & Other",
                currentStep: 4,
                totalSteps: 7,
                activeColor: ColorsValue.appColor,
                inactiveColor: ColorsValue.yelloCB,
              ),
              Dimens.boxHeight16,
              Row(
                children: [
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Back Image *",
                      controller.backImageFile,
                      () => controller.pickVehicleImage('back'),
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Left Image *",
                      controller.leftImageFile,
                      () => controller.pickVehicleImage('left'),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              Row(
                children: [
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Right Image *",
                      controller.rightImageFile,
                      () => controller.pickVehicleImage('right'),
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Number Plate *",
                      controller.numberPlateImageFile,
                      () => controller.pickVehicleImage('numberPlate'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildImagePicker(
    HomeController controller,
    String title,
    File? imageFile,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.g1txtColor60014),
        Dimens.boxHeight4,
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: Dimens.hundredFifty,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorsValue.fildColos,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorsValue.l2),
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(imageFile, fit: BoxFit.cover),
                  )
                : Center(
                    child: Image.asset(
                      AssetConstants.ic_uolodImage,
                      height: Dimens.sixty,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
