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

class Addvehicale1Screen extends StatelessWidget {
  const Addvehicale1Screen({super.key});

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
    if (cleanPath.startsWith("/")) {
      cleanPath = cleanPath.substring(1);
    }
    return "${ApiWrapper.imageUrl}$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        if (controller.fuelTypesList.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.fetchFuelTypes();
          });
        }
        final isStep1 = controller.addVehicleCurrentStep == 1;

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () {
              if (controller.addVehicleCurrentStep == 2) {
                controller.addVehicleCurrentStep = 1;
                controller.update();
              } else {
                Get.back();
              }
            },
            title: controller.isTransferredVehicle
                ? "Transfer Vehicle"
                : "Add New Vehicle",
          ),
          bottomNavigationBar: isStep1
              ? null
              : Padding(
                  padding: Dimens.edgeInsets20_30_20_30,
                  child: CustomButton(
                    onPressed: () {
                      controller.registerVehicle();
                    },
                    text: controller.isTransferredVehicle
                        ? "Confirm & Transfer"
                        : "Save Vehicle",
                    backgroundColor: ColorsValue.appColor,
                  ),
                ),
          body: isStep1
              ? _buildStep1(context, controller)
              : _buildStep2(context, controller),
        );
      },
    );
  }

  /// -------------------------------------------------------------
  /// STEP 1: Owner Mobile Verification & Transfer OTP
  /// -------------------------------------------------------------
  Widget _buildStep1(BuildContext context, HomeController controller) {
    return ListView(
      padding: Dimens.edgeInsets20,
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phonelink_ring_rounded,
                        color: Color(0xFFFF6B00), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vehicle Owner Verification",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Check owner number before registration",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                "Enter vehicle owner's 10-digit mobile number to verify vehicle or transfer registration from another vendor.",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 18),

              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter 10-digit owner mobile number".tr,
                textEditingController: controller.vehicleOwnerMobileController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (val) {
                  controller.vehicleTransferCheckResult = null;
                  controller.isVehicleTransferOtpSent = false;
                  controller.update();
                },
                title: "Vehicle Owner Mobile Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isCheckingVehicleOwnerMobile
                      ? null
                      : () {
                          final phone =
                              controller.vehicleOwnerMobileController.text.trim();
                          if (phone.isEmpty) {
                            Utility.snacBar(
                                "Please enter owner mobile number", Colors.red);
                            return;
                          }
                          if (phone.length != 10) {
                            Utility.snacBar(
                                "Mobile number must be exactly 10 digits",
                                Colors.red);
                            return;
                          }
                          controller.checkVehicleOwnerMobileForTransfer();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isCheckingVehicleOwnerMobile
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Check Vehicle / Owner",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                ),
              ),

              // Case 1: Vehicle belongs to THIS vendor
              if (controller.vehicleTransferCheckResult != null &&
                  controller.vehicleTransferCheckResult!['isOwnVehicle'] ==
                      true) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF90CAF9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFF1976D2), size: 22),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Vehicle Already in Your List",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF0D47A1)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBBDEFB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("Existing",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Owner: ${controller.vehicleTransferCheckResult!['vehicle_owner_name'] ?? ''}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vehicle: ${controller.vehicleTransferCheckResult!['vehicle_number'] ?? 'N/A'} (${controller.vehicleTransferCheckResult!['brand_name'] ?? ''})",
                        style: TextStyle(
                            color: Colors.grey.shade800, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "This vehicle is already registered by you and exists in your active vehicle list.",
                        style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 11,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("View in Vehicle List",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Case 2: Vehicle belongs to another vendor (Transfer OTP Flow)
              if (controller.vehicleTransferCheckResult != null &&
                  controller.vehicleTransferCheckResult!['belongsToOtherVendor'] ==
                      true) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFF57F17), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Vehicle Registered with Another Vendor",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Owner: ${controller.vehicleTransferCheckResult!['vehicle_owner_name'] ?? ''}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Current Vendor: ${controller.vehicleTransferCheckResult!['previous_vendor_name'] ?? 'Another Vendor'}",
                        style: TextStyle(
                            color: Colors.grey.shade800, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vehicle: ${controller.vehicleTransferCheckResult!['vehicle_number'] ?? ''} (${controller.vehicleTransferCheckResult!['brand_name'] ?? ''})",
                        style: TextStyle(
                            color: Colors.grey.shade800, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "An OTP will be sent to the vehicle owner's mobile to authorize transfer to your fleet.",
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 11),
                      ),
                      const SizedBox(height: 14),

                      if (!controller.isVehicleTransferOtpSent)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isSendingVehicleTransferOtp
                                ? null
                                : () => controller.sendVehicleTransferOtp(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF57F17),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: controller.isSendingVehicleTransferOtp
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text("Send OTP to Vehicle Owner",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                        )
                      else ...[
                        const Text(
                            "Enter 6-Digit OTP received by Vehicle Owner:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.vehicleTransferOtpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 4),
                          decoration: InputDecoration(
                            hintText: "• • • • • •",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Color(0xFFFFB300))),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isVerifyingVehicleTransferOtp
                                ? null
                                : () => controller.verifyVehicleTransferOtp(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: controller.isVerifyingVehicleTransferOtp
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text("Verify OTP & Transfer",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// -------------------------------------------------------------
  /// STEP 2: Single Scrollable Page (Identical to Edit Vehicle Screen)
  /// -------------------------------------------------------------
  Widget _buildStep2(BuildContext context, HomeController controller) {
    return ListView(
      padding: Dimens.edgeInsets20,
      physics: const BouncingScrollPhysics(),
      children: [
        // Transferred Banner
        if (controller.isTransferredVehicle) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync_alt_rounded,
                    color: Color(0xFF2E7D32), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Transferring Vehicle",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1B5E20))),
                      const SizedBox(height: 2),
                      Text(
                        "Transferred from ${controller.transferredVehicleData?['previous_vendor'] ?? 'Previous Vendor'}. Verified details loaded.",
                        style: TextStyle(
                            fontSize: 11, color: Colors.green.shade900),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFC8E6C9),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Text("Verified",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32))),
                ),
              ],
            ),
          ),
        ],

        // SECTION 1: Vehicle Information
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
          onChanged: (value) {
            if (controller.rcNumberController.text.isEmpty) {
              controller.rcNumberController.text = value.toUpperCase();
            }
            controller.update();
          },
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
            Text(" *",
                style: Styles.blackColorW50016.copyWith(color: Colors.red)),
          ],
        ),
        Dimens.boxHeight4,
        controller.isRcVerified && controller.selectedVehicleTypeId != null
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                hint: const Text("Auto-detected from RC"),
                value: (controller.vehicleTypesList.any((item) =>
                        item['_id'].toString() == controller.selectedVehicleTypeId))
                    ? controller.selectedVehicleTypeId
                    : null,
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
            Text(" *",
                style: Styles.blackColorW50016.copyWith(color: Colors.red)),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

        // SECTION 2: Preferences
        Text("Preferences", style: Styles.appColor60020),
        Dimens.boxHeight16,

        Row(
          children: [
            Text("Sourcing", style: Styles.g1txtColor60014),
            Text(" *",
                style: Styles.blackColorW50016.copyWith(color: Colors.red)),
          ],
        ),
        Dimens.boxHeight4,
        Builder(
          builder: (context) {
            final sourcingOptions = [
              "Owner Vehicle",
              "Rented Vehicle",
              "Self Owned"
            ];
            final currentSourcing =
                controller.selectedSourcing?.toString().trim();
            if (currentSourcing != null &&
                currentSourcing.isNotEmpty &&
                !sourcingOptions.contains(currentSourcing)) {
              sourcingOptions.add(currentSourcing);
            }
            final safeSourcing = (currentSourcing != null &&
                    sourcingOptions.contains(currentSourcing))
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

        // SECTION 3: Expiries & Expiry Documents
        Text("Expiries & Expiry Documents", style: Styles.appColor60020),
        Dimens.boxHeight16,

        Row(
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
            const SizedBox(width: 16),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Permit Type", style: Styles.g1txtColor60014),
                      Text(" *",
                          style: Styles.blackColorW50016
                              .copyWith(color: Colors.red)),
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
                      final currentPermit =
                          controller.selectedPermitType?.toString().trim();
                      if (currentPermit != null &&
                          currentPermit.isNotEmpty &&
                          !permitOptions.contains(currentPermit)) {
                        permitOptions.add(currentPermit);
                      }
                      final safePermit = (currentPermit != null &&
                              permitOptions.contains(currentPermit))
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

        // SECTION 4: RC Verification
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
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: ColorsValue.appColor),
                  ),
                )
              : controller.isRcVerified
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Color(0xFF18904E)),
                        SizedBox(width: 4),
                        Text("Verified ✓",
                            style: TextStyle(
                                color: Color(0xFF18904E),
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
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
                showRcDetailsDialog(context, controller.rcDetails!,
                    controller.rcNumberController.text.trim());
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

        // SECTION 5: Upload Documents
        Text("Upload Documents", style: Styles.blackColor60016),
        Dimens.boxHeight16,

        Row(
          children: [
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Insurance Document",
                localFile: controller.insuranceDocumentFile,
                networkUrl: controller.transferredVehicleExistingInsuranceDoc,
                onTap: () => controller.pickVehicleImage('insurance'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Fitness Document",
                localFile: controller.fitnessDocumentFile,
                networkUrl: controller.transferredVehicleExistingFitnessDoc,
                onTap: () => controller.pickVehicleImage('fitness'),
              ),
            ),
          ],
        ),
        Dimens.boxHeight16,

        Row(
          children: [
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Permit Document",
                localFile: controller.permitDocumentFile,
                networkUrl: controller.transferredVehicleExistingPermitDoc,
                onTap: () => controller.pickVehicleImage('permit'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "PUC",
                localFile: controller.pucDocumentFile,
                networkUrl: controller.transferredVehicleExistingPucDoc,
                onTap: () => controller.pickVehicleImage('puc'),
              ),
            ),
          ],
        ),
        Dimens.boxHeight16,

        Row(
          children: [
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "RC Image",
                localFile: controller.rcImageFile,
                networkUrl: controller.transferredVehicleExistingRcImage,
                onTap: () => controller.pickVehicleImage('rc'),
              ),
            ),
            const SizedBox(width: 16),
            if (controller.selectedSourcing == "Rented Vehicle")
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePickerWithPreview(
                      controller: controller,
                      title: "Rented Agreement",
                      localFile: controller.rentedVehicleAgreementFile,
                      networkUrl:
                          controller.transferredVehicleExistingAgreement,
                      onTap: () => controller.pickVehicleImage('agreement'),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(
                            "https://apis.bambamcabs.com/vendor/vehicles/download-sample-agreement");
                        try {
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            Utility.snacBar(
                                "Could not open sample agreement URL",
                                Colors.red);
                          }
                        } catch (e) {
                          Utility.snacBar(
                              "Error opening download link: $e", Colors.red);
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

        // SECTION 6: Car Photos
        Text("Car Photos", style: Styles.blackColor60016),
        Dimens.boxHeight16,

        Row(
          children: [
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Front View",
                localFile: controller.frontImageFile,
                networkUrl: controller.transferredVehicleExistingFrontImage,
                onTap: () => controller.pickVehicleImage('front'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Back View",
                localFile: controller.backImageFile,
                networkUrl: controller.transferredVehicleExistingBackImage,
                onTap: () => controller.pickVehicleImage('back'),
              ),
            ),
          ],
        ),
        Dimens.boxHeight16,

        Row(
          children: [
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Left View",
                localFile: controller.leftImageFile,
                networkUrl: controller.transferredVehicleExistingLeftImage,
                onTap: () => controller.pickVehicleImage('left'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Right View",
                localFile: controller.rightImageFile,
                networkUrl: controller.transferredVehicleExistingRightImage,
                onTap: () => controller.pickVehicleImage('right'),
              ),
            ),
          ],
        ),
        Dimens.boxHeight16,

        Row(
          children: [
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Interior View",
                localFile: controller.interiorImageFile,
                networkUrl: controller.transferredVehicleExistingInteriorImage,
                onTap: () => controller.pickVehicleImage('interior'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Plate Number",
                localFile: controller.numberPlateImageFile,
                networkUrl: controller.transferredVehicleExistingPlateImage,
                onTap: () => controller.pickVehicleImage('numberPlate'),
              ),
            ),
          ],
        ),
        Dimens.boxHeight16,

        Row(
          children: [
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Dicky View",
                localFile: controller.dickyImageFile,
                networkUrl: controller.transferredVehicleExistingDickyImage,
                onTap: () => controller.pickVehicleImage('dicky'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImagePickerWithPreview(
                controller: controller,
                title: "Carrier View",
                localFile: controller.carrierImageFile,
                networkUrl: controller.transferredVehicleExistingCarrierImage,
                onTap: () => controller.pickVehicleImage('carrier'),
              ),
            ),
          ],
        ),
        Dimens.boxHeight40,
      ],
    );
  }

  Widget _buildPreferenceDropdown({
    required String title,
    required dynamic value,
    required Function(String?) onChanged,
  }) {
    final strVal = value?.toString().trim();
    final safeValue = (strVal == "Yes" ||
            strVal?.toLowerCase() == "yes" ||
            strVal == "true")
        ? "Yes"
        : (strVal == "No" ||
                strVal?.toLowerCase() == "no" ||
                strVal == "false")
            ? "No"
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title.replaceAll(' *', ''), style: Styles.g1txtColor60014),
            Text(" *",
                style: Styles.blackColorW50016.copyWith(color: Colors.red)),
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
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFF6B00),
            ),
          );
        },
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
            Text(" *",
                style: Styles.blackColorW50016.copyWith(color: Colors.red)),
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
}
