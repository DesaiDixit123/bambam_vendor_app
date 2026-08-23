import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Addvehicale1Screen extends StatelessWidget {
  const Addvehicale1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Add New Vehicle",
          ),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () => RouteManagement.gotoAddvehicale2Screen(),
              text: "Save & Continue",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              StepHeaderWidget(
                title: "Vehicle Information",
                nextTitle: "Next : Vehicle Documents",
                currentStep: 1,
                totalSteps: 7,
                activeColor: ColorsValue.appColor,
                inactiveColor: ColorsValue.yelloCB,
              ),
              Dimens.boxHeight10,
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Utility.snacBar("Downloading sample rental agreement...", ColorsValue.appColor);
                  },
                  child: Text(
                    "Download Sample Rental Agreement",
                    style: Styles.appColor60014.copyWith(
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              Dimens.boxHeight16,
              Text("Car Image *", style: Styles.g1txtColor60014),
              Dimens.boxHeight4,
              GestureDetector(
                onTap: () => controller.pickVehicleImage('front'),
                child: Container(
                  height: Dimens.hundredFifty,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsValue.fildColos,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorsValue.l2),
                  ),
                  child: controller.frontImageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            controller.frontImageFile!,
                            fit: BoxFit.cover,
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
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Brand Name".tr,
                textEditingController: controller.vehicleBrandNameController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
                onChanged: (vaule) {
                  controller.update();
                },
                title: "Brand Name".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Vehicle Number".tr,
                textEditingController: controller.vehicleNumberController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
                onChanged: (vaule) {
                  controller.update();
                },
                title: "Vehicle Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              Text("Vehicle Type *", style: Styles.g1txtColor60014),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                hint: const Text("Select"),
                value: controller.selectedVehicleTypeId,
                items: controller.vehicleTypesList
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item['_id'].toString(),
                        child: Text(
                          item['name'].toString(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedVehicleTypeId = value;
                  controller.update();
                },
              ),
              Dimens.boxHeight16,
              Text("Fuel Type *", style: Styles.g1txtColor60014),
              Dimens.boxHeight4,
              DropdownButtonFormField<String>(
                isExpanded: true,
                menuMaxHeight: Dimens.twoHundred,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: ColorsValue.fildColos,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                hint: const Text("Select"),
                value: controller.selectedFuelTypeId,
                items: controller.fuelTypesList
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item['_id'].toString(),
                        child: Text(
                          item['name'].toString(),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  controller.selectedFuelTypeId = value;
                  controller.update();
                },
              ),

              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Vehicle Make".tr,
                textEditingController: controller.vehicleMakeYearController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.number,
                onChanged: (vaule) {
                  controller.update();
                },
                title: "Vehicle Make".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
            ],
          ),
        );
      },
    );
  }
}

