import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bam_bam_vendor/app/widgets/verification_dialogs.dart';

class EditVehicleScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final vehicleId = vehicle['_id']?.toString() ?? "";
    final info = vehicle['vehicleInformation'] ?? {};
    final docs = vehicle['vehicleDocuments'] ?? {};

    return GetBuilder<HomeController>(
      initState: (state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.find<HomeController>().initVehicleEdit(vehicle);
        });
      },
      builder: (controller) {
        if (controller.fuelTypesList.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.fetchFuelTypes();
          });
        }
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Edit Vehicle",
          ),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                if (controller.vehicleBrandNameController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter brand name", Colors.red);
                  return;
                }
                if (controller.vehicleOwnerNameController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter vehicle owner name", Colors.red);
                  return;
                }
                if (controller.vehicleOwnerMobileController.text.trim().isEmpty || controller.vehicleOwnerMobileController.text.trim().length != 10) {
                  Utility.snacBar("Please enter valid 10-digit vehicle owner mobile number", Colors.red);
                  return;
                }
                if (controller.vehicleNumberController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter vehicle number", Colors.red);
                  return;
                }
                if (controller.rcNumberController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter RC number", Colors.red);
                  return;
                }
                if (!controller.isRcVerified) {
                  Utility.snacBar("Please verify RC Number before saving", Colors.red);
                  return;
                }
                if (controller.vehicleMakeYearController.text.trim().isEmpty) {
                  Utility.snacBar("Please enter vehicle make year", Colors.red);
                  return;
                }
                if (controller.selectedVehicleTypeId == null || controller.selectedVehicleTypeId!.isEmpty) {
                  Utility.snacBar("Please select vehicle type", Colors.red);
                  return;
                }
                if (controller.selectedFuelTypeId == null || controller.selectedFuelTypeId!.isEmpty) {
                  Utility.snacBar("Please select fuel type", Colors.red);
                  return;
                }
                if (controller.selectedSourcing == null || controller.selectedSourcing!.isEmpty) {
                  Utility.snacBar("Please select sourcing preference", Colors.red);
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
                if (controller.insuranceDocumentFile == null && (docs['insurance_document'] == null || docs['insurance_document'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Insurance Document", Colors.red);
                  return;
                }
                if (controller.fitnessDocumentFile == null && (docs['fitness_document'] == null || docs['fitness_document'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Fitness Document", Colors.red);
                  return;
                }
                if (controller.permitDocumentFile == null && (docs['permit_document'] == null || docs['permit_document'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Permit Document", Colors.red);
                  return;
                }
                if (controller.pucDocumentFile == null && (docs['puc_document'] == null || docs['puc_document'].toString().isEmpty)) {
                  Utility.snacBar("Please upload PUC Document", Colors.red);
                  return;
                }
                if (controller.rcImageFile == null && (docs['rc_image'] == null || docs['rc_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload RC Image", Colors.red);
                  return;
                }
                if (controller.selectedSourcing == "Rented Vehicle") {
                  if (controller.rentedVehicleAgreementFile == null && (info['rented_vehicle_agreement'] == null || info['rented_vehicle_agreement'].toString().isEmpty)) {
                    Utility.snacBar("Please upload Rented Vehicle Agreement", Colors.red);
                    return;
                  }
                }
                if (controller.frontImageFile == null && (info['front_image'] == null || info['front_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Front View car photo", Colors.red);
                  return;
                }
                if (controller.backImageFile == null && (info['back_image'] == null || info['back_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Back View car photo", Colors.red);
                  return;
                }
                if (controller.leftImageFile == null && (info['left_image'] == null || info['left_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Left View car photo", Colors.red);
                  return;
                }
                if (controller.rightImageFile == null && (info['right_image'] == null || info['right_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Right View car photo", Colors.red);
                  return;
                }
                if (controller.interiorImageFile == null && (info['interior_image'] == null || info['interior_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Interior View car photo", Colors.red);
                  return;
                }
                if (controller.numberPlateImageFile == null && (info['number_plate_image'] == null || info['number_plate_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Plate Number car photo", Colors.red);
                  return;
                }
                if (controller.dickyImageFile == null && (info['dicky_image'] == null || info['dicky_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Dicky View car photo", Colors.red);
                  return;
                }
                if (controller.carrierImageFile == null && (info['carrier_image'] == null || info['carrier_image'].toString().isEmpty)) {
                  Utility.snacBar("Please upload Carrier View car photo", Colors.red);
                  return;
                }
                controller.submitVehicleUpdate(vehicleId);
              },
              text: "Save Changes",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const BouncingScrollPhysics(),
            children: [
              Text("Vehicle Information", style: Styles.appColor60020),
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
                onChanged: (value) => controller.update(),
                title: "Brand Name".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,

              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Vehicle Owner Name".tr,
                textEditingController: controller.vehicleOwnerNameController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
                onChanged: (value) => controller.update(),
                title: "Vehicle Owner Name".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,

              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Vehicle Owner Mobile Number".tr,
                textEditingController: controller.vehicleOwnerMobileController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                maxLength: 10,
                keyboardType: TextInputType.phone,
                onChanged: (value) => controller.update(),
                title: "Vehicle Owner Mobile Number".tr,
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  UpperCaseTextFormatter(),
                  LengthLimitingTextInputFormatter(13),
                ],
                onChanged: (value) => controller.update(),
                title: "Vehicle Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,

              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Vehicle Make Year".tr,
                textEditingController: controller.vehicleMakeYearController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.number,
                onChanged: (value) => controller.update(),
                title: "Vehicle Make Year".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,

              Row(
                children: [
                  Text("Vehicle Type", style: Styles.g1txtColor60014),
                  Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
                ],
              ),
              Dimens.boxHeight4,
              controller.selectedVehicleTypeId != null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ColorsValue.fildColos,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        controller.vehicleTypesList.firstWhereOrNull((item) =>
                                item['_id'].toString() == controller.selectedVehicleTypeId)?['name']?.toString() ??
                            controller.selectedVehicleType ??
                            "Auto-detected from RC",
                        style: Styles.g7txtColor70014,
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      menuMaxHeight: Dimens.hundredFifty,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: ColorsValue.fildColos,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      hint: const Text("Auto-detected from RC"),
                      value: (controller.vehicleTypesList.any((item) => item['_id'].toString() == controller.selectedVehicleTypeId))
                          ? controller.selectedVehicleTypeId
                          : null,
                      items: controller.vehicleTypesList
                          .map((item) => DropdownMenuItem<String>(
                                value: item['_id'].toString(),
                                child: Text(item['name'].toString()),
                              ))
                          .toList(),
                      onChanged: (val) {
                        controller.selectedVehicleTypeId = val;
                        controller.update();
                      },
                    ),
              if (controller.rcVehicleTypeError != null) ...[
                const SizedBox(height: 6),
                Text(
                  controller.rcVehicleTypeError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              Dimens.boxHeight16,

              Row(
                children: [
                  Text("Fuel Type", style: Styles.g1txtColor60014),
                  Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
                ],
              ),
              Dimens.boxHeight4,
              controller.isRcVerified && (controller.selectedFuelTypeId != null || controller.selectedFuelType != null)
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ColorsValue.fildColos,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        controller.fuelTypesList.firstWhereOrNull((item) =>
                                (item['_id']?.toString() == controller.selectedFuelTypeId ||
                                    item['id']?.toString() == controller.selectedFuelTypeId))?['name']?.toString() ??
                            controller.selectedFuelType ??
                            "Auto-detected from RC",
                        style: Styles.g7txtColor70014,
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      menuMaxHeight: Dimens.twoHundred,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: ColorsValue.fildColos,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      hint: const Text("Select"),
                      value: (controller.fuelTypesList.any((item) =>
                              (item['_id']?.toString() == controller.selectedFuelTypeId ||
                                  item['id']?.toString() == controller.selectedFuelTypeId)))
                          ? (controller.fuelTypesList.firstWhereOrNull((item) =>
                              (item['_id']?.toString() == controller.selectedFuelTypeId ||
                                  item['id']?.toString() == controller.selectedFuelTypeId))?['_id'] ?? controller.selectedFuelTypeId)?.toString()
                          : null,
                      items: controller.fuelTypesList
                          .map((item) => DropdownMenuItem<String>(
                                value: (item['_id'] ?? item['id']).toString(),
                                child: Text(item['name'].toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        controller.selectedFuelTypeId = value;
                        final match = controller.fuelTypesList.firstWhereOrNull((item) =>
                            (item['_id'] ?? item['id']).toString() == value);
                        if (match != null) controller.selectedFuelType = match['name']?.toString();
                        controller.update();
                      },
                    ),
              Dimens.boxHeight24,

              Text("Preferences", style: Styles.appColor60020),
              Dimens.boxHeight16,

              Row(
                children: [
                  Text("Sourcing", style: Styles.g1txtColor60014),
                  Text(" *", style: Styles.blackColorW50016.copyWith(color: Colors.red)),
                ],
              ),
              Dimens.boxHeight4,
              Builder(
                builder: (context) {
                  final sourcingOptions = ["Owner Vehicle", "Rented Vehicle", "Self Owned"];
                  final currentSourcing = controller.selectedSourcing?.toString().trim();
                  if (currentSourcing != null && currentSourcing.isNotEmpty && !sourcingOptions.contains(currentSourcing)) {
                    sourcingOptions.add(currentSourcing);
                  }
                  final safeSourcing = (currentSourcing != null && sourcingOptions.contains(currentSourcing))
                      ? currentSourcing
                      : null;

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                    ),
                    hint: const Text("Select"),
                    value: safeSourcing,
                    items: sourcingOptions
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) {
                      controller.selectedSourcing = value;
                      controller.update();
                    },
                  );
                },
              ),
              Dimens.boxHeight16,

              _buildPreferenceDropdown(
                title: "Working Rear Seat Belts *",
                value: controller.selectedWorkingRearSeatBelts,
                onChanged: (val) {
                  controller.selectedWorkingRearSeatBelts = val;
                  controller.update();
                },
              ),
              Dimens.boxHeight16,

              _buildPreferenceDropdown(
                title: "Pet Friendly *",
                value: controller.selectedPetFriendly,
                onChanged: (val) {
                  controller.selectedPetFriendly = val;
                  controller.update();
                },
              ),
              Dimens.boxHeight16,

              _buildPreferenceDropdown(
                title: "Luggage Carrier *",
                value: controller.selectedLuggageCarrier,
                onChanged: (val) {
                  controller.selectedLuggageCarrier = val;
                  controller.update();
                },
              ),
              Dimens.boxHeight24,

              Text("Expiries & Expiry Documents", style: Styles.appColor60020),
              Dimens.boxHeight16,

              Row(
                spacing: Dimens.sixteen,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildExpiryDatePicker(
                      context: context,
                      title: "Fitness Expiry",
                      textController: controller.fitnessExpiryController,
                      controller: controller,
                    ),
                  ),
                  Expanded(
                    child: _buildExpiryDatePicker(
                      context: context,
                      title: "Insurance Expiry",
                      textController: controller.insuranceExpiryController,
                      controller: controller,
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
                    child: _buildExpiryDatePicker(
                      context: context,
                      title: "Permit Expiry",
                      textController: controller.permitExpiryController,
                      controller: controller,
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
                        Builder(
                          builder: (context) {
                            final permitOptions = [
                              "All India Permit",
                              "State Permit",
                              "National Permit",
                              "All India Tourist Permit"
                            ];
                            final currentPermit = controller.selectedPermitType?.toString().trim();
                            if (currentPermit != null && currentPermit.isNotEmpty && !permitOptions.contains(currentPermit)) {
                              permitOptions.add(currentPermit);
                            }
                            final safePermit = (currentPermit != null && permitOptions.contains(currentPermit))
                                ? currentPermit
                                : null;

                            return DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: ColorsValue.fildColos,
                              ),
                              hint: const Text("Select"),
                              value: safePermit,
                              items: permitOptions
                                  .map((item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(item),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                controller.selectedPermitType = value;
                                controller.update();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight24,

              Text("RC Verification", style: Styles.appColor60020),
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
              Dimens.boxHeight24,

              Text("Upload Documents", style: Styles.blackColor60016),
              Dimens.boxHeight16,

              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Insurance Document",
                      localFile: controller.insuranceDocumentFile,
                      networkUrl: docs['insurance_document'],
                      onTap: () => controller.pickVehicleImage('insurance'),
                    ),
                  ),
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Fitness Document",
                      localFile: controller.fitnessDocumentFile,
                      networkUrl: docs['fitness_document'],
                      onTap: () => controller.pickVehicleImage('fitness'),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,

              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Permit Document",
                      localFile: controller.permitDocumentFile,
                      networkUrl: docs['permit_document'],
                      onTap: () => controller.pickVehicleImage('permit'),
                    ),
                  ),
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "PUC",
                      localFile: controller.pucDocumentFile,
                      networkUrl: docs['puc_document'],
                      onTap: () => controller.pickVehicleImage('puc'),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,

              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "RC Image",
                      localFile: controller.rcImageFile,
                      networkUrl: docs['rc_image'],
                      onTap: () => controller.pickVehicleImage('rc'),
                    ),
                  ),
                  if (controller.selectedSourcing == "Rented Vehicle")
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImagePickerWithPreview(
                            controller: controller,
                            title: "Rented Agreement",
                            localFile: controller.rentedVehicleAgreementFile,
                            networkUrl: info['rented_vehicle_agreement'],
                            onTap: () => controller.pickVehicleImage('agreement'),
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
                                    "Download Sample Agreement",
                                    style: Styles.g1txtColor60012.copyWith(
                                      color: ColorsValue.orangeColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
              Dimens.boxHeight24,

              Text("Car Photos", style: Styles.blackColor60016),
              Dimens.boxHeight16,

              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Front View",
                      localFile: controller.frontImageFile,
                      networkUrl: info['front_image'],
                      onTap: () => controller.pickVehicleImage('front'),
                    ),
                  ),
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Back View",
                      localFile: controller.backImageFile,
                      networkUrl: info['back_image'],
                      onTap: () => controller.pickVehicleImage('back'),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,

              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Left View",
                      localFile: controller.leftImageFile,
                      networkUrl: info['left_image'],
                      onTap: () => controller.pickVehicleImage('left'),
                    ),
                  ),
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Right View",
                      localFile: controller.rightImageFile,
                      networkUrl: info['right_image'],
                      onTap: () => controller.pickVehicleImage('right'),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,

              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Interior View",
                      localFile: controller.interiorImageFile,
                      networkUrl: info['interior_image'],
                      onTap: () => controller.pickVehicleImage('interior'),
                    ),
                  ),
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Plate Number",
                      localFile: controller.numberPlateImageFile,
                      networkUrl: info['number_plate_image'],
                      onTap: () => controller.pickVehicleImage('number_plate'),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,

              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Dicky View",
                      localFile: controller.dickyImageFile,
                      networkUrl: info['dicky_image'],
                      onTap: () => controller.pickVehicleImage('dicky'),
                    ),
                  ),
                  Expanded(
                    child: _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Carrier View",
                      localFile: controller.carrierImageFile,
                      networkUrl: info['carrier_image'],
                      onTap: () => controller.pickVehicleImage('carrier'),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreferenceDropdown({
    required String title,
    required dynamic value,
    required Function(String?) onChanged,
  }) {
    final strVal = value?.toString().trim();
    final safeValue = (strVal == "Yes" || strVal?.toLowerCase() == "yes" || strVal == "true")
        ? "Yes"
        : (strVal == "No" || strVal?.toLowerCase() == "no" || strVal == "false")
            ? "No"
            : null;

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
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: ColorsValue.fildColos,
          ),
          hint: const Text("Select"),
          value: safeValue,
          items: ["Yes", "No"]
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildExpiryDatePicker({
    required BuildContext context,
    required String title,
    required TextEditingController textController,
    required HomeController controller,
  }) {
    return CustomTextFormField(
      filled: true,
      fillColor: ColorsValue.fildColos,
      hintStyle: Styles.g7txtColor40012,
      titleStyle: Styles.blackColor60014,
      textEditingController: textController,
      isBorder: true,
      isTitle: true,
      title: title.tr,
      isCompulsory: true,
      hintText: "YYYY-MM-DD".tr,
      readOnly: true,
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 3650)),
        );
        if (picked != null) {
          textController.text = DateFormat("yyyy-MM-dd").format(picked);
          controller.update();
        }
      },
      suffixIcon: Padding(
        padding: Dimens.edgeInsets12,
        child: SvgPicture.asset(AssetConstants.ic_calendar),
      ),
    );
  }

  Widget _buildImagePickerWithPreview({
    required HomeController controller,
    required String title,
    required File? localFile,
    required String? networkUrl,
    required VoidCallback onTap,
  }) {
    Widget imageWidget;
    if (localFile != null) {
      imageWidget = Image.file(localFile, fit: BoxFit.cover);
    } else if (networkUrl != null && networkUrl.trim().isNotEmpty) {
      imageWidget = Image.network(
        _resolveImageUrl(networkUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Image.asset(
            AssetConstants.ic_uolodImage,
            height: Dimens.sixty,
          ),
        ),
      );
    } else {
      imageWidget = Center(
        child: Image.asset(
          AssetConstants.ic_uolodImage,
          height: Dimens.sixty,
        ),
      );
    }

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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageWidget,
            ),
          ),
        ),
      ],
    );
  }

  String _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    final trimmed = path.trim();
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }
    
    String cleanPath = trimmed;
    if (cleanPath.startsWith("uploads/")) {
      cleanPath = cleanPath.substring("uploads/".length);
    } else if (cleanPath.startsWith("/uploads/")) {
      cleanPath = cleanPath.substring("/uploads/".length);
    }
    
    return "${ApiWrapper.imageUrl}$cleanPath";
  }
}
