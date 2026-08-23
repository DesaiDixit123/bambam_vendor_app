import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Addvehicale5Screen extends StatelessWidget {
  const Addvehicale5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () => RouteManagement.gotoAddvehicale6Screen(),
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
                title: "Interior & Other",
                nextTitle: "Next : Vehicle Features",
                currentStep: 5,
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
                      "Interior Image *",
                      controller.interiorImageFile,
                      () => controller.pickVehicleImage('interior'),
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Dicky Image *",
                      controller.dickyImageFile,
                      () => controller.pickVehicleImage('dicky'),
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
                      "Carrier Image *",
                      controller.carrierImageFile,
                      () => controller.pickVehicleImage('carrier'),
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildImagePicker(
                          controller,
                          "Rented Agreement",
                          controller.rentedVehicleAgreementFile,
                          () => controller.pickVehicleImage('agreement'),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final Uri url = Uri.parse(
                                "https://apis.bambamcabs.com/vendor/vehicles/download-sample-agreement");
                            try {
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                Utility.snacBar("Could not open sample agreement URL", Colors.red);
                              }
                            } catch (e) {
                              Utility.snacBar("Error opening download link: $e", Colors.red);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.download_rounded,
                                  color: ColorsValue.orangeColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Download Sample",
                                  style: Styles.g1txtColor60012.copyWith(
                                    color: ColorsValue.orangeColor,
                                    decoration: TextDecoration.underline,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
