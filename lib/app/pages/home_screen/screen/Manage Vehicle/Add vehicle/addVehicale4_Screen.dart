import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';

class Addvehicale4Screen extends StatelessWidget {
  const Addvehicale4Screen({super.key});

  String _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    String cleanPath = trimmed;
    if (cleanPath.startsWith('uploads/')) {
      cleanPath = cleanPath.substring('uploads/'.length);
    } else if (cleanPath.startsWith('/uploads/')) {
      cleanPath = cleanPath.substring('/uploads/'.length);
    }
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    return "${ApiWrapper.imageUrl}$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                final hasBack = controller.backImageFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingBackImage?.isNotEmpty ?? false));
                final hasLeft = controller.leftImageFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingLeftImage?.isNotEmpty ?? false));
                final hasRight = controller.rightImageFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingRightImage?.isNotEmpty ?? false));
                final hasPlate = controller.numberPlateImageFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingPlateImage?.isNotEmpty ?? false));

                if (!hasBack) {
                  Utility.snacBar("Please upload Back Image", Colors.red);
                  return;
                }
                if (!hasLeft) {
                  Utility.snacBar("Please upload Left Image", Colors.red);
                  return;
                }
                if (!hasRight) {
                  Utility.snacBar("Please upload Right Image", Colors.red);
                  return;
                }
                if (!hasPlate) {
                  Utility.snacBar("Please upload Number Plate Image", Colors.red);
                  return;
                }
                RouteManagement.gotoAddvehicale5Screen();
              },
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
            physics: const BouncingScrollPhysics(),
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
                      controller.transferredVehicleExistingBackImage,
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Left Image *",
                      controller.leftImageFile,
                      () => controller.pickVehicleImage('left'),
                      controller.transferredVehicleExistingLeftImage,
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
                      controller.transferredVehicleExistingRightImage,
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Number Plate *",
                      controller.numberPlateImageFile,
                      () => controller.pickVehicleImage('numberPlate'),
                      controller.transferredVehicleExistingPlateImage,
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
    VoidCallback onTap, [
    String? existingImageUrl,
  ]) {
    final hasExisting = existingImageUrl != null && existingImageUrl.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title.replaceAll(' *', ''), style: Styles.g1txtColor60014),
            Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
          ],
        ),
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
                : hasExisting
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _resolveImageUrl(existingImageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Image.asset(
                              AssetConstants.ic_uolodImage,
                              height: Dimens.sixty,
                            ),
                          ),
                        ),
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
