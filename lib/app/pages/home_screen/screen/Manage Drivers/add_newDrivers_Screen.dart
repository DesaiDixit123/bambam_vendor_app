import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';

class AddNewdriversScreen extends StatelessWidget {
  const AddNewdriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final isStep1 = controller.selectedDriver == null && controller.addDriverCurrentStep == 1;
        return Scaffold(
          bottomNavigationBar: isStep1
              ? null
              : Padding(
                  padding: Dimens.edgeInsets20_30_20_30,
                  child: Row(
                    children: [
                      if (controller.selectedDriver == null) ...[
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            onPressed: () {
                              controller.addDriverCurrentStep = 1;
                              controller.update();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFFFF6B00)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Back", style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: CustomButton(
                          onPressed: () {
                            if (controller.selectedDriver != null) {
                              controller.updateDriver();
                            } else {
                              controller.registerDriver();
                            }
                          },
                          text: controller.isTransferredDriver ? "Confirm & Transfer" : "Save",
                          backgroundColor: ColorsValue.appColor,
                        ),
                      ),
                    ],
                  ),
                ),
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () {
              if (controller.selectedDriver == null && controller.addDriverCurrentStep == 2) {
                controller.addDriverCurrentStep = 1;
                controller.update();
              } else {
                Get.back();
              }
            },
            title: controller.selectedDriver != null
                ? "Edit Driver"
                : controller.isTransferredDriver
                    ? "Transfer Driver"
                    : "Add New Driver",
          ),
          body: isStep1
              ? _buildStep1(context, controller)
              : _buildStep2(context, controller),
        );
      },
    );
  }

  Widget _buildStep2(BuildContext context, HomeController controller) {
    return ListView(
      padding: Dimens.edgeInsets20,
      physics: const BouncingScrollPhysics(),
      children: [
        if (controller.selectedDriver == null) ...[
          // Stepper Progress Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    controller.addDriverCurrentStep = 1;
                    controller.update();
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 6),
                      const Text("Step 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 24, height: 1.5, color: Colors.green),
                const SizedBox(width: 12),
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B00),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text("2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 6),
                const Text("Step 2: Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF6B00))),
              ],
            ),
          ),
        ],

        if (controller.isTransferredDriver) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF90CAF9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync_alt_rounded, color: Color(0xFF1976D2), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Transferring Driver", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1))),
                      const SizedBox(height: 2),
                      Text(
                        "Transferred from ${controller.transferredDriverData?['previous_vendor'] ?? 'Previous Vendor'}. Verified details loaded.",
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(12)),
                  child: const Text("Verified", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ),
              ],
            ),
          ),
        ],
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Driver Name".tr,

                textEditingController: controller.driverNameController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
                onChanged: (vaule) {
                  controller.update();
                },

                title: "Driver Name".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Mobile Number".tr,

                textEditingController: controller.driverMobileController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (vaule) {
                  controller.update();
                },

                title: "Mobile Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter DL Number".tr,
                textEditingController: controller.driverDLNumberController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
                onChanged: (vaule) {
                  controller.isDriverDlVerified = false;
                  controller.update();
                },
                suffixIcon: controller.isDriverDlVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isDriverDlVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.verifyDriverDL();
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
                title: "DL Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter PAN Number".tr,
                textEditingController: controller.driverPanNumberController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.text,
                onChanged: (vaule) {
                  controller.isDriverPanVerified = false;
                  controller.update();
                },
                maxLength: 10,
                suffixIcon: controller.isDriverPanVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isDriverPanVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.verifyDriverPAN();
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
                title: "PAN Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter Aadhaar Number".tr,
                textEditingController: controller.driverAadhaarNumberController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.number,
                onChanged: (vaule) {
                  controller.isDriverAadhaarVerified = false;
                  controller.update();
                },
                maxLength: 12,
                suffixIcon: controller.isDriverAadhaarVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isDriverAadhaarVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.requestDriverAadhaarOtp();
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
                title: "Aadhaar Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                      textEditingController: controller.dateSportController,
                      isBorder: true,
                      isTitle: true,
                      title: "Date of Birth".tr,
                      isCompulsory: true,
                      hintText: "DD/MM/YYYY".tr,

                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                      onTap: () async {
                        controller.selectDate = await showDatePicker(
                          context: context,
                          initialDate: controller.selectDate ?? DateTime(2000),
                          firstDate: DateTime(1980),
                          lastDate: DateTime.now(),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                        );

                        if (controller.selectDate != null) {
                          controller.dateSportController.text = DateFormat(
                            "dd/MM/yyyy",
                          ).format(controller.selectDate!);
                        }
                      },
                      suffixIcon: Padding(
                        padding: Dimens.edgeInsets12,
                        child: SvgPicture.asset(AssetConstants.ic_calendar),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'select_date'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Language Known *", style: Styles.g1txtColor60014),
                        Dimens.boxHeight4,
                        InkWell(
                            onTap: () => _showSearchableBottomSheet(
                              context: context,
                              controller: controller,
                              title: "Select Languages",
                              listProvider: (ctrl) => ctrl.filteredLanguages,
                              searchController:
                                  controller.languageSearchController,
                              onSelect: (item) => controller.toggleLanguage(item),
                              isMultiSelect: true,
                              selectedItems: controller.selectedLanguages,
                              displayName: (item) => item['name'].toString(),
                            ),
                          child: Container(
                            padding: Dimens.edgeInsets12,
                            decoration: BoxDecoration(
                              color: ColorsValue.fildColos,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.selectedLanguages.isEmpty
                                        ? "Select".tr
                                        : controller.selectedLanguages
                                              .map((e) => e['name'])
                                              .join(", "),
                                    style: controller.selectedLanguages.isEmpty
                                        ? Styles.g7txtColor40012
                                        : Styles.g7txtColor70014,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                      textEditingController: controller.dlIssueDateController,
                      isBorder: true,
                      isTitle: true,
                      title: "DL Issue Date".tr,
                      isCompulsory: true,
                      hintText: "DD/MM/YYYY".tr,

                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                      onTap: () async {
                        controller.selectDLIssueDate = await showDatePicker(
                          context: context,
                          initialDate:
                              controller.selectDLIssueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                        );

                        if (controller.selectDLIssueDate != null) {
                          controller.dlIssueDateController.text = DateFormat(
                            "dd/MM/yyyy",
                          ).format(controller.selectDLIssueDate!);
                        }
                      },
                      suffixIcon: Padding(
                        padding: Dimens.edgeInsets12,
                        child: SvgPicture.asset(AssetConstants.ic_calendar),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'select_date'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                      textEditingController: controller.dlValidityController,
                      isBorder: true,
                      isTitle: true,
                      title: "DL Validity".tr,
                      isCompulsory: true,
                      hintText: "DD/MM/YYYY".tr,

                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      readOnly: true,
                      onTap: () async {
                        controller.selectDLValidityDate = await showDatePicker(
                          context: context,
                          initialDate:
                              controller.selectDLValidityDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 10),
                          ),
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                        );

                        if (controller.selectDLValidityDate != null) {
                          controller.dlValidityController.text = DateFormat(
                            "dd/MM/yyyy",
                          ).format(controller.selectDLValidityDate!);
                        }
                      },
                      suffixIcon: Padding(
                        padding: Dimens.edgeInsets12,
                        child: SvgPicture.asset(AssetConstants.ic_calendar),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'select_date'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              Text(
                "Select Types of Vehicles Driver Can Operate *",
                style: Styles.g1txtColor60014,
              ),
              Dimens.boxHeight4,
              InkWell(
                onTap: () => _showSearchableBottomSheet(
                  context: context,
                  controller: controller,
                  title: "Select Vehicle Types",
                  listProvider: (ctrl) => ctrl.filteredVehicleTypes,
                  searchController: controller.vehicleSearchController,
                  onSelect: (item) => controller.toggleVehicleType(item),
                  isMultiSelect: true,
                  selectedItems: controller.selectedVehiclesList,
                  displayName: (item) => item['name'].toString(),
                ),
                child: Container(
                  padding: Dimens.edgeInsets12,
                  decoration: BoxDecoration(
                    color: ColorsValue.fildColos,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.selectedVehiclesList.isEmpty
                              ? "Select".tr
                              : controller.selectedVehiclesList
                                    .map((e) => e['name'])
                                    .join(", "),
                          style: controller.selectedVehiclesList.isEmpty
                              ? Styles.g7txtColor40012
                              : Styles.g7txtColor70014,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("State *", style: Styles.g1txtColor60014),
                        Dimens.boxHeight4,
                        InkWell(
                          onTap: () => _showSearchableBottomSheet(
                            context: context,
                            controller: controller,
                            title: "Select State",
                            listProvider: (ctrl) => ctrl.filteredStates,
                            searchController: controller.stateSearchController,
                            onSelect: (item) {
                              controller.selectedState =
                                  item['name'] ?? item['state_name'];
                              controller.selectedCity = null;
                              controller.update();
                              Get.back();
                            },
                            isMultiSelect: false,
                            selectedItems: [controller.selectedState],
                            displayName: (item) =>
                                (item['name'] ?? item['state_name']).toString(),
                          ),
                          child: Container(
                            padding: Dimens.edgeInsets12,
                            decoration: BoxDecoration(
                              color: ColorsValue.fildColos,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.selectedState ??
                                        "Select State".tr,
                                    style: controller.selectedState == null
                                        ? Styles.g7txtColor40012
                                        : Styles.g7txtColor70014,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("City *", style: Styles.g1txtColor60014),
                        Dimens.boxHeight4,
                        InkWell(
                          onTap: () {
                            if (controller.selectedState == null) {
                              Utility.snacBar(
                                "Please select State first",
                                Colors.orange,
                              );
                              return;
                            }
                            _showSearchableBottomSheet(
                              context: context,
                              controller: controller,
                              title: "Select City",
                              listProvider: (ctrl) => ctrl.filteredCities,
                              searchController: controller.citySearchController,
                              onSelect: (item) {
                                controller.selectedCity =
                                    item['name'] ?? item['city_name'];
                                controller.update();
                                Get.back();
                              },
                              isMultiSelect: false,
                              selectedItems: [controller.selectedCity],
                              displayName: (item) =>
                                  (item['name'] ?? item['city_name'])
                                      .toString(),
                            );
                          },
                          child: Container(
                            padding: Dimens.edgeInsets12,
                            decoration: BoxDecoration(
                              color: ColorsValue.fildColos,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.selectedCity ?? "Select City".tr,
                                    style: controller.selectedCity == null
                                        ? Styles.g7txtColor40012
                                        : Styles.g7txtColor70014,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              Text("Upload Photos *", style: Styles.blackColor60014),
              Dimens.boxHeight8,
              Column(
                spacing: Dimens.sixteen,
                children: [
                  Row(
                    spacing: Dimens.sixteen,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Driver Photo",
                              style: TextStyle(fontSize: 12),
                            ),
                            Dimens.boxHeight4,
                            InkWell(
                              onTap: () => _showPicker(context, controller, 'driver'),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ColorsValue.fildColos,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: controller.driverPhotoFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          controller.driverPhotoFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (controller.selectedDriver != null && (controller.selectedDriver!['driver_photo'] ?? '').isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              "${ApiWrapper.imageUrl}${controller.selectedDriver!['driver_photo']}",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.add_a_photo, color: Colors.grey),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_a_photo,
                                            color: Colors.grey,
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("DL Photo", style: TextStyle(fontSize: 12)),
                            Dimens.boxHeight4,
                            InkWell(
                              onTap: () => _showPicker(context, controller, 'dl'),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ColorsValue.fildColos,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: controller.dlPhotoFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          controller.dlPhotoFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (controller.selectedDriver != null && (controller.selectedDriver!['DL_photo'] ?? '').isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              "${ApiWrapper.imageUrl}${controller.selectedDriver!['DL_photo']}",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.add_a_photo, color: Colors.grey),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_a_photo,
                                            color: Colors.grey,
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: Dimens.sixteen,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "PAN Photo",
                              style: TextStyle(fontSize: 12),
                            ),
                            Dimens.boxHeight4,
                            InkWell(
                              onTap: () => _showPicker(context, controller, 'pan'),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ColorsValue.fildColos,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: controller.driverPanPhotoFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          controller.driverPanPhotoFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (controller.selectedDriver != null && (controller.selectedDriver!['pan_photo'] ?? '').isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              "${ApiWrapper.imageUrl}${controller.selectedDriver!['pan_photo']}",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.add_a_photo, color: Colors.grey),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_a_photo,
                                            color: Colors.grey,
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Aadhaar Photo",
                              style: TextStyle(fontSize: 12),
                            ),
                            Dimens.boxHeight4,
                            InkWell(
                              onTap: () => _showPicker(context, controller, 'aadhar'),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: ColorsValue.fildColos,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: controller.driverAadhaarPhotoFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          controller.driverAadhaarPhotoFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (controller.selectedDriver != null && (controller.selectedDriver!['aadhar_photo'] ?? '').isNotEmpty)
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              "${ApiWrapper.imageUrl}${controller.selectedDriver!['aadhar_photo']}",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.add_a_photo, color: Colors.grey),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_a_photo,
                                            color: Colors.grey,
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
            ],
          );
  }

  void _showSearchableBottomSheet({
    required BuildContext context,
    required HomeController controller,
    required String title,
    required List<dynamic> Function(HomeController) listProvider,
    required TextEditingController searchController,
    required Function(dynamic) onSelect,
    required bool isMultiSelect,
    required List<dynamic> selectedItems,
    required String Function(dynamic) displayName,
  }) {
    searchController.clear();
    Get.bottomSheet(
      GetBuilder<HomeController>(
        builder: (controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                AppBar(
                  title: Text(title),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => controller.update(),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final list = listProvider(controller);
                      return list.isEmpty
                          ? const Center(child: Text("No Data Found"))
                          : ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final item = list[index];
                                final name = displayName(item);
                                final isSelected = isMultiSelect
                                    ? selectedItems.any(
                                        (e) =>
                                            (e['_id'] == item['_id']) ||
                                            (e['name'] == item['name']),
                                      )
                                    : selectedItems.contains(name);

                                return ListTile(
                                  title: Text(name),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : null,
                                  onTap: () {
                                    onSelect(item);
                                    if (!isMultiSelect) {
                                      // Handled in onSelect callbacks for single select
                                    }
                                  },
                                );
                              },
                            );
                    },
                  ),
                ),
                if (isMultiSelect)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomButton(
                      onPressed: () => Get.back(),
                      text: "Done",
                      backgroundColor: ColorsValue.appColor,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  void _showPicker(
    BuildContext context,
    HomeController controller,
    String photoType,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  if (photoType == 'driver') {
                    controller.pickDriverPhoto(ImageSource.gallery);
                  } else if (photoType == 'dl') {
                    controller.pickDLPhoto(ImageSource.gallery);
                  } else if (photoType == 'pan') {
                    controller.pickDriverPanPhoto(ImageSource.gallery);
                  } else if (photoType == 'aadhar') {
                    controller.pickDriverAadhaarPhoto(ImageSource.gallery);
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  if (photoType == 'driver') {
                    controller.pickDriverPhoto(ImageSource.camera);
                  } else if (photoType == 'dl') {
                    controller.pickDLPhoto(ImageSource.camera);
                  } else if (photoType == 'pan') {
                    controller.pickDriverPanPhoto(ImageSource.camera);
                  } else if (photoType == 'aadhar') {
                    controller.pickDriverAadhaarPhoto(ImageSource.camera);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep1(BuildContext context, HomeController controller) {
    return ListView(
      padding: Dimens.edgeInsets20,
      physics: const BouncingScrollPhysics(),
      children: [
        // Stepper Progress Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B00),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text("1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Step 1: Mobile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFF6B00))),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 16, height: 1.5, color: Colors.grey.shade300),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text("2", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Step 2: Details", style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Dimens.boxHeight20,

        // Step 1 Verification Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Driver Verification",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
              ),
              const SizedBox(height: 6),
              Text(
                "Enter driver's 10-digit mobile number to verify registration or transfer from another vendor.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Mobile input
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                hintText: "Enter 10-digit mobile number".tr,
                textEditingController: controller.driverMobileController,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (val) {
                  controller.driverTransferCheckResult = null;
                  controller.isTransferOtpSent = false;
                  controller.update();
                },
                title: "Driver Mobile Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              const SizedBox(height: 16),

              // Check Driver Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isCheckingDriverMobile
                      ? null
                      : () {
                          final phone = controller.driverMobileController.text.trim();
                          if (phone.isEmpty) {
                            Utility.snacBar("Please enter mobile number", Colors.red);
                            return;
                          }
                          if (phone.length != 10) {
                            Utility.snacBar("Mobile number must be exactly 10 digits", Colors.red);
                            return;
                          }
                          controller.checkDriverMobileForTransfer();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isCheckingDriverMobile
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Check Driver", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),

              // Case 1: Driver belongs to THIS vendor
              if (controller.driverTransferCheckResult != null && controller.driverTransferCheckResult!['isOwnDriver'] == true) ...[
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
                          const Icon(Icons.info_outline_rounded, color: Color(0xFF1976D2), size: 22),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              "Driver Already in Your List",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBBDEFB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("Existing", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Driver: ${controller.driverTransferCheckResult!['driver_name'] ?? ''}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "DL: ${controller.driverTransferCheckResult!['DL_number'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "This driver was added by you and already exists in your active driver list. No OTP verification is needed.",
                        style: TextStyle(color: Colors.blue.shade900, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("View in Driver List", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Case 2: Driver belongs to another vendor
              if (controller.driverTransferCheckResult != null && controller.driverTransferCheckResult!['belongsToOtherVendor'] == true) ...[
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
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57F17), size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Driver Registered with Another Vendor",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Driver: ${controller.driverTransferCheckResult!['driver_name'] ?? ''}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Current Vendor: ${controller.driverTransferCheckResult!['previous_vendor_name'] ?? 'Another Vendor'}",
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "An OTP must be verified from driver's mobile to authorize transfer.",
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                      ),
                      const SizedBox(height: 14),

                      if (!controller.isTransferOtpSent)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isSendingTransferOtp ? null : () => controller.sendTransferOtp(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF57F17),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: controller.isSendingTransferOtp
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Send OTP to Driver", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        )
                      else ...[
                        const Text("Enter 6-Digit OTP received by Driver:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.transferOtpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 4),
                          decoration: InputDecoration(
                            hintText: "• • • • • •",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFFB300))),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isVerifyingTransferOtp ? null : () => controller.verifyTransferOtp(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B00),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: controller.isVerifyingTransferOtp
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Verify OTP & Transfer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: controller.isSendingTransferOtp ? null : () => controller.sendTransferOtp(),
                            child: const Text("Resend OTP", style: TextStyle(color: Color(0xFFF57F17), fontWeight: FontWeight.bold, fontSize: 12)),
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
}
