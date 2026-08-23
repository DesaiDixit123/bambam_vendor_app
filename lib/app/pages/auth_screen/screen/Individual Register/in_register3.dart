import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InRegister3 extends StatelessWidget {
  const InRegister3({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          extendBody: true,
          backgroundColor: ColorsValue.whiteColor,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Individual Registration".tr,
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            child: SafeArea(
              child: Padding(
                padding: Dimens.edgeInsets20_30_20_30,
                child: CustomButton(
                  onPressed: () {
                    if (controller.brandNameController.text.isEmpty ||
                        controller.vehicleNumberController.text.isEmpty ||
                        controller.selectedVehicleType == null) {
                      Utility.snacBar(
                        "Please fill required vehicle details",
                        ColorsValue.redColor,
                      );
                      return;
                    }
                    RouteManagement.gotoInRegister4();
                  },
                  backgroundColor: ColorsValue.appColor,
                  text: "Next",
                ),
              ),
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const BouncingScrollPhysics(),
            children: [
              _stepHeader(),
              Dimens.boxHeight30,
              _sectionHeader("Vehicle Basic Info".tr),
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.brandNameController,
                title: "Brand Name".tr,
                hintText: "e.g. Maruti Suzuki",
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.vehicleNumberController,
                title: "Vehicle Number".tr,
                hintText: "e.g. DL-01-AB-1234",
              ),
              Dimens.boxHeight20,
              _dropdownField(
                title: "Vehicle Type".tr,
                value: controller.selectedVehicleType,
                items: controller.vehicleTypesList.map((e) {
                  return DropdownMenuItem(
                    value: e['_id'].toString(),
                    child: Text(e['name'].toString()),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.selectedVehicleType = val;
                  controller.update();
                },
              ),
              Dimens.boxHeight20,
              Row(
                spacing: Dimens.twenty,
                children: [
                  Expanded(
                    child: _dropdownField(
                      title: "Fuel Type".tr,
                      value: controller.selectedFuelType,
                      items: controller.fuelTypesList.map((e) {
                        return DropdownMenuItem(
                          value: e['_id'].toString(),
                          child: Text(e['name'].toString()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedFuelType = val;
                        controller.update();
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      isTitle: true,
                      isCompulsory: true,
                      textEditingController:
                          controller.vehicleMakeYearController,
                      title: "Make Year".tr,
                      hintText: "e.g. 2022",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight30,
              _sectionHeader("Statutory Documents & Expiries".tr),
              _dropdownField(
                title: "Permit Type".tr,
                value: controller.permitTypeController.text.isEmpty
                    ? null
                    : controller.permitTypeController.text,
                items:
                    [
                      "State Permit",
                      "All India Permit",
                      "Special Permit",
                      "Local City Permit",
                    ].map((e) {
                      return DropdownMenuItem(value: e, child: Text(e.tr));
                    }).toList(),
                onChanged: (val) {
                  controller.permitTypeController.text = val ?? "";
                  controller.update();
                },
              ),
              Dimens.boxHeight20,
              Row(
                spacing: Dimens.twenty,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      style: Styles.g7txtColor70014,
                      hintText: "Insurance Expiry".tr,
                      filled: true,
                      readOnly: true,
                      fillColor: ColorsValue.fildColos,
                      isBorder: true,
                      isTitle: true,
                      isCompulsory: true,
                      textEditingController:
                          controller.insuranceExpiryController,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                        );
                        if (pickedDate != null) {
                          controller.insuranceExpiryController.text = pickedDate
                              .toLocal()
                              .toString()
                              .split(' ')[0];
                          controller.update();
                        }
                      },
                      title: "Insurance Expiry".tr,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                    ),
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      style: Styles.g7txtColor70014,
                      hintText: "Fitness Expiry".tr,
                      filled: true,
                      readOnly: true,
                      fillColor: ColorsValue.fildColos,
                      isBorder: true,
                      isTitle: true,
                      isCompulsory: true,
                      textEditingController: controller.fitnessExpiryController,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                        );
                        if (pickedDate != null) {
                          controller.fitnessExpiryController.text = pickedDate
                              .toLocal()
                              .toString()
                              .split(' ')[0];
                          controller.update();
                        }
                      },
                      title: "Fitness Expiry".tr,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Permit Expiry".tr,
                filled: true,
                readOnly: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.permitExpiryController,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2050),
                  );
                  if (pickedDate != null) {
                    controller.permitExpiryController.text = pickedDate
                        .toLocal()
                        .toString()
                        .split(' ')[0];
                    controller.update();
                  }
                },
                title: "Permit Expiry".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight30,
              _sectionHeader("Preferences & Sourcing".tr),
              _dropdownField(
                title: "Sourcing".tr,
                value: controller.sourcingController.text.isEmpty
                    ? null
                    : controller.sourcingController.text,
                items: ["Owner Vehicle", "Rented Vehicle"].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e.tr));
                }).toList(),
                onChanged: (val) {
                  controller.sourcingController.text = val ?? "";
                  controller.update();
                },
              ),
              Dimens.boxHeight20,
              Row(
                spacing: Dimens.ten,
                children: [
                  Expanded(
                    child: _dropdownField(
                      title: "Pet Friendly".tr,
                      value: controller.petFriendlyController.text.isEmpty
                          ? null
                          : controller.petFriendlyController.text,
                      items: ["Yes", "No"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e.tr));
                      }).toList(),
                      onChanged: (val) {
                        controller.petFriendlyController.text = val ?? "";
                        controller.update();
                      },
                    ),
                  ),
                  Expanded(
                    child: _dropdownField(
                      title: "Luggage Carrier".tr,
                      value: controller.luggageCarrierController.text.isEmpty
                          ? null
                          : controller.luggageCarrierController.text,
                      items: ["Yes", "No"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e.tr));
                      }).toList(),
                      onChanged: (val) {
                        controller.luggageCarrierController.text = val ?? "";
                        controller.update();
                      },
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight20,
              _dropdownField(
                title: "Working Rear Seat Belts".tr,
                value: controller.workingRearSeatBeltsController.text.isEmpty
                    ? null
                    : controller.workingRearSeatBeltsController.text,
                items: ["Yes", "No"].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e.tr));
                }).toList(),
                onChanged: (val) {
                  controller.workingRearSeatBeltsController.text = val ?? "";
                  controller.update();
                },
              ),
              Dimens.boxHeight30,
              _sectionHeader("Skills & Languages".tr),
              Text("Languages Known".tr, style: Styles.blackColor60014),
              Dimens.boxHeight10,
              Wrap(
                spacing: 8,
                children: controller.languagesList.map((lang) {
                  final isSelected = controller.selectedLanguages.any(
                    (e) => e['_id'] == lang['_id'],
                  );
                  return FilterChip(
                    label: Text(lang['name']),
                    selected: isSelected,
                    onSelected: (val) => controller.toggleLanguage(lang),
                    selectedColor: ColorsValue.appColor.withValues(alpha: .2),
                    checkmarkColor: ColorsValue.appColor,
                  );
                }).toList(),
              ),
              Dimens.boxHeight20,
              Text("Vehicles You Can Drive".tr, style: Styles.blackColor60014),
              Dimens.boxHeight10,
              Wrap(
                spacing: 8,
                children: controller.vehicleTypesList.map((vType) {
                  final isSelected = controller.selectedVehiclesToDrive.any(
                    (e) => e['_id'] == vType['_id'],
                  );
                  return FilterChip(
                    label: Text(vType['name']),
                    selected: isSelected,
                    onSelected: (val) => controller.toggleVehicleToDrive(vType),
                    selectedColor: ColorsValue.appColor.withValues(alpha: .2),
                    checkmarkColor: ColorsValue.appColor,
                  );
                }).toList(),
              ),
              Dimens.boxHeight100,
            ],
          ),
        );
      },
    );
  }

  Widget _stepHeader() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.twelve),
        color: ColorsValue.appColor.withValues(alpha: .1),
      ),
      child: Padding(
        padding: Dimens.edgeInsets16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Vehicle Details".tr, style: Styles.g1txtColor60016),
                Text("Step 3 Of 4".tr, style: Styles.appColor70012),
              ],
            ),
            Dimens.boxHeight16,
            _progressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _progressIndicator() {
    return Row(
      spacing: Dimens.five,
      children: List.generate(4, (index) {
        bool isDone = index < 3;
        bool isCurrent = index == 2;
        return Expanded(
          child: Row(
            children: [
              Container(
                height: Dimens.twelve,
                width: Dimens.twelve,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone || isCurrent
                      ? ColorsValue.appColor
                      : ColorsValue.yelloCB,
                ),
              ),
              if (index < 3)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isDone ? ColorsValue.appColor : ColorsValue.yelloCB,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimens.fifteen),
      child: Text(title, style: Styles.blackColor60016),
    );
  }

  Widget _dropdownField({
    required String title,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required ValueChanged<dynamic> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.blackColor60014),
        Dimens.boxHeight8,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ColorsValue.fildColos,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ColorsValue.g7txtColor.withValues(alpha: .2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              hint: Text("Select".tr, style: Styles.g7txtColor40012),
            ),
          ),
        ),
      ],
    );
  }
}
