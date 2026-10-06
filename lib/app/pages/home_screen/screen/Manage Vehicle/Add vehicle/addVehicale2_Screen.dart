import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bam_bam_vendor/app/widgets/verification_dialogs.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';

class Addvehicale2Screen extends StatelessWidget {
  const Addvehicale2Screen({super.key});

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
        if (controller.rcNumberController.text.isEmpty && controller.vehicleNumberController.text.isNotEmpty) {
          controller.rcNumberController.text = controller.vehicleNumberController.text.trim();
        }
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                if (controller.rcNumberController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter RC number", Colors.red);
                  return;
                }
                if (!controller.isRcVerified) {
                  Utility.snacBar("Please verify RC Number before continuing", Colors.red);
                  return;
                }
                if (controller.fitnessExpiryController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter fitness expiry date", Colors.red);
                  return;
                }
                if (controller.insuranceExpiryController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter insurance expiry date", Colors.red);
                  return;
                }
                if (controller.permitExpiryController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter permit expiry date", Colors.red);
                  return;
                }
                if (controller.selectedPermitType == null || controller.selectedPermitType!.isEmpty) {
                  Utility.snacBar("Please select permit type", Colors.red);
                  return;
                }
                final hasInsurance = controller.insuranceDocumentFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingInsuranceDoc?.isNotEmpty ?? false));
                final hasFitness = controller.fitnessDocumentFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingFitnessDoc?.isNotEmpty ?? false));
                final hasPermit = controller.permitDocumentFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingPermitDoc?.isNotEmpty ?? false));
                final hasPuc = controller.pucDocumentFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingPucDoc?.isNotEmpty ?? false));
                final hasRc = controller.rcImageFile != null ||
                    (controller.isTransferredVehicle && (controller.transferredVehicleExistingRcImage?.isNotEmpty ?? false));

                if (!hasInsurance) {
                  Utility.snacBar("Please upload Insurance Document", Colors.red);
                  return;
                }
                if (!hasFitness) {
                  Utility.snacBar("Please upload Fitness Document", Colors.red);
                  return;
                }
                if (!hasPermit) {
                  Utility.snacBar("Please upload Permit Document", Colors.red);
                  return;
                }
                if (!hasPuc) {
                  Utility.snacBar("Please upload PUC Document", Colors.red);
                  return;
                }
                if (!hasRc) {
                  Utility.snacBar("Please upload RC Image", Colors.red);
                  return;
                }
                RouteManagement.gotoAddvehicale3Screen();
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
                title: "Vehicle Documents",
                nextTitle: "Next : Vehicle Preferences",
                currentStep: 2,
                totalSteps: 7,
                activeColor: ColorsValue.appColor,
                inactiveColor: ColorsValue.yelloCB,
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter RC Number".tr,
                textEditingController: controller.rcNumberController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(13),
                ],
                onChanged: (value) {
                  controller.isRcVerified = false;
                  controller.rcDetails = null;
                  controller.rcVehicleTypeError = null;
                  controller.update();
                },
                suffixIcon: controller.isRcVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isRcVerified
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.check_circle, color: Color(0xFF18904E)),
                              SizedBox(width: 4),
                              Text("Verified ✓", style: TextStyle(color: Color(0xFF18904E), fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(width: 10),
                            ],
                          )
                        : TextButton(
                            onPressed: () {
                              controller.verifyVehicleRC();
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
                title: "RC Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              if (controller.isRcVerified && controller.rcDetails != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: InkWell(
                    onTap: () {
                      showRcDetailsDialog(context, controller.rcDetails!, controller.rcNumberController.text.trim());
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.info_outline, size: 16, color: Color(0xFF18904E)),
                        SizedBox(width: 4),
                        Text(
                          "View RTO Verification Details",
                          style: TextStyle(
                            color: Color(0xFF18904E),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Dimens.boxHeight16,
              Row(
                spacing: Dimens.sixteen,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                      textEditingController: controller.fitnessExpiryController,
                      isBorder: true,
                      isTitle: true,
                      title: "Fitness Expiry".tr,
                      isCompulsory: true,
                      hintText: "YYYY-MM-DD".tr,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (picked != null) {
                          controller.fitnessExpiryController.text = DateFormat(
                            "yyyy-MM-dd",
                          ).format(picked);
                        }
                      },
                      suffixIcon: Padding(
                        padding: Dimens.edgeInsets12,
                        child: SvgPicture.asset(AssetConstants.ic_calendar),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                      textEditingController:
                          controller.insuranceExpiryController,
                      isBorder: true,
                      isTitle: true,
                      title: "Insurance Expiry".tr,
                      isCompulsory: true,
                      hintText: "YYYY-MM-DD".tr,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (picked != null) {
                          controller.insuranceExpiryController.text =
                              DateFormat("yyyy-MM-dd").format(picked);
                        }
                      },
                      suffixIcon: Padding(
                        padding: Dimens.edgeInsets12,
                        child: SvgPicture.asset(AssetConstants.ic_calendar),
                      ),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              Row(
                spacing: Dimens.sixteen,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                      textEditingController: controller.permitExpiryController,
                      isBorder: true,
                      isTitle: true,
                      title: "Permit Expiry".tr,
                      isCompulsory: true,
                      hintText: "YYYY-MM-DD".tr,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (picked != null) {
                          controller.permitExpiryController.text = DateFormat(
                            "yyyy-MM-dd",
                          ).format(picked);
                        }
                      },
                      suffixIcon: Padding(
                        padding: Dimens.edgeInsets12,
                        child: SvgPicture.asset(AssetConstants.ic_calendar),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Permit Type", style: Styles.g1txtColor60014),
                            Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
                          ],
                        ),
                        Dimens.boxHeight4,
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          menuMaxHeight: Dimens.hundredFifty,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: ColorsValue.fildColos,
                          ),
                          hint: const Text("Select"),
                          initialValue: controller.selectedPermitType,
                          items: ["State Permit", "National Permit"]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            controller.selectedPermitType = value;
                            controller.update();
                          },
                        ),
                      ],
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
                      "Insurance Document *",
                      controller.insuranceDocumentFile,
                      () => controller.pickVehicleImage('insurance'),
                      controller.transferredVehicleExistingInsuranceDoc,
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Fitness Document *",
                      controller.fitnessDocumentFile,
                      () => controller.pickVehicleImage('fitness'),
                      controller.transferredVehicleExistingFitnessDoc,
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
                      "Permit Document *",
                      controller.permitDocumentFile,
                      () => controller.pickVehicleImage('permit'),
                      controller.transferredVehicleExistingPermitDoc,
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "PUC *",
                      controller.pucDocumentFile,
                      () => controller.pickVehicleImage('puc'),
                      controller.transferredVehicleExistingPucDoc,
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
                      "Rc Image *",
                      controller.rcImageFile,
                      () => controller.pickVehicleImage('rc'),
                      controller.transferredVehicleExistingRcImage,
                    ),
                  ),
                  Spacer(),
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
