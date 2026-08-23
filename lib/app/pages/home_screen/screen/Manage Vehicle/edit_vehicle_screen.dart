import 'dart:io';
import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
        Get.find<HomeController>().initVehicleEdit(vehicle);
      },
      builder: (controller) {
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
                hintText: "Enter Vehicle Number".tr,
                textEditingController: controller.vehicleNumberController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                hint: const Text("Select"),
                value: controller.selectedVehicleTypeId,
                items: controller.vehicleTypesList
                    .map((item) => DropdownMenuItem<String>(
                          value: item['_id'].toString(),
                          child: Text(item['name'].toString()),
                        ))
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                hint: const Text("Select"),
                value: controller.selectedFuelTypeId,
                items: controller.fuelTypesList
                    .map((item) => DropdownMenuItem<String>(
                          value: item['_id'].toString(),
                          child: Text(item['name'].toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  controller.selectedFuelTypeId = value;
                  controller.update();
                },
              ),
              Dimens.boxHeight16,

              Text("Sourcing *", style: Styles.g1txtColor60014),
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
                value: controller.selectedSourcing?.toString().isEmpty == true ? null : controller.selectedSourcing,
                items: ["Self Owned", "Rented Vehicle"]
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                onChanged: (value) {
                  controller.selectedSourcing = value;
                  controller.update();
                },
              ),
              Dimens.boxHeight24,

              Text("Preferences", style: Styles.appColor60020),
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
                        Text("Permit Type *", style: Styles.g1txtColor60014),
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
                          value: controller.selectedPermitType?.toString().isEmpty == true ? null : controller.selectedPermitType,
                          items: ["State Permit", "National Permit"]
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
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
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.g1txtColor60014),
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
          value: value?.toString().isEmpty == true ? null : value,
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
