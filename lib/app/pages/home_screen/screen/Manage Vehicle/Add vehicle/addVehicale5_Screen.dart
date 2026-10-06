import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';

class Addvehicale5Screen extends StatelessWidget {
  const Addvehicale5Screen({super.key});

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
                final hasInterior = controller.interiorImageFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingInteriorImage?.isNotEmpty ?? false));
                final hasDicky = controller.dickyImageFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingDickyImage?.isNotEmpty ?? false));
                final hasCarrier = controller.carrierImageFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingCarrierImage?.isNotEmpty ?? false));
                final hasAgreement = controller.rentedVehicleAgreementFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingAgreement?.isNotEmpty ?? false));

                if (!hasInterior) {
                  Utility.snacBar("Please upload Interior Image", Colors.red);
                  return;
                }
                if (!hasDicky) {
                  Utility.snacBar("Please upload Dicky Image", Colors.red);
                  return;
                }
                if (!hasCarrier) {
                  Utility.snacBar("Please upload Carrier Image", Colors.red);
                  return;
                }
                if (controller.selectedSourcing == "Rented Vehicle" && !hasAgreement) {
                  Utility.snacBar("Please upload Rented Vehicle Agreement", Colors.red);
                  return;
                }
                RouteManagement.gotoAddvehicale6Screen();
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
                      controller.transferredVehicleExistingInteriorImage,
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Dicky Image *",
                      controller.dickyImageFile,
                      () => controller.pickVehicleImage('dicky'),
                      controller.transferredVehicleExistingDickyImage,
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
                      controller.transferredVehicleExistingCarrierImage,
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
                          controller.transferredVehicleExistingAgreement,
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
