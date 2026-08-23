import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Addvehicale2Screen extends StatelessWidget {
  const Addvehicale2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () => RouteManagement.gotoAddvehicale3Screen(),
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
                title: "Vehicle Documents",
                nextTitle: "Next : Vehicle Preferences",
                currentStep: 2,
                totalSteps: 7,
                activeColor: ColorsValue.appColor,
                inactiveColor: ColorsValue.yelloCB,
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
                        Text("Permit Type *", style: Styles.g1txtColor60014),
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
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "Fitness Document *",
                      controller.fitnessDocumentFile,
                      () => controller.pickVehicleImage('fitness'),
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
                    ),
                  ),
                  Dimens.boxWidth16,
                  Expanded(
                    child: buildImagePicker(
                      controller,
                      "PUC *",
                      controller.pucDocumentFile,
                      () => controller.pickVehicleImage('puc'),
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
