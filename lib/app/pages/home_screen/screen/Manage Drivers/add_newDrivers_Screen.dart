import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
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
        return Scaffold(
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                if (controller.selectedDriver != null) {
                  controller.updateDriver();
                } else {
                  controller.registerDriver();
                }
              },
              text: "Save",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Add New Driver",
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
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
          ),
        );
      },
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
}
