import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/app.dart';

class Registerstep1Screen extends StatelessWidget {
  const Registerstep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          extendBody: true,
          backgroundColor: ColorsValue.whiteColor,
          appBar: AppBarWidget(
            onTapBack: () {
              Get.back();
            },
            title: "company_partner_registration".tr,
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            child: SafeArea(
              child: Padding(
                padding: Dimens.edgeInsets20_30_20_30,
                child: CustomButton(
                  onPressed: () {
                    if (controller.companyNameController.text.isEmpty ||
                        controller.companyPersonNameController.text.isEmpty ||
                        controller.companyDobController.text.isEmpty ||
                        controller.usernameController.text.isEmpty ||
                        controller.passwordController.text.isEmpty ||
                        controller.rePasswordController.text.isEmpty) {
                      Get.snackbar("Error", "Please fill all required fields");
                      return;
                    }

                    RouteManagement.gotoRegisterstep2Screen();
                  },
                  backgroundColor: ColorsValue.appColor,
                  text: "Next",
                ),
              ),
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              Container(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Personal Information".tr,
                            style: Styles.g1txtColor60016,
                          ),
                          Text("Step 1 Of 3".tr, style: Styles.appColor70012),
                        ],
                      ),
                      Dimens.boxHeight16,
                      Row(
                        spacing: Dimens.five,
                        children: [
                          Container(
                            height: Dimens.twelve,
                            width: Dimens.twelve,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorsValue.appColor,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,

                              decoration: BoxDecoration(
                                color: ColorsValue.yelloCB,
                                borderRadius: BorderRadius.circular(
                                  Dimens.five,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: Dimens.ten,
                            width: Dimens.ten,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: ColorsValue.yelloCB),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 2,

                              decoration: BoxDecoration(
                                color: ColorsValue.yelloCB,
                                borderRadius: BorderRadius.circular(
                                  Dimens.five,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: Dimens.ten,
                            width: Dimens.ten,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: ColorsValue.yelloCB),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight30,
              // 1. Upload Contact Person Photo
              CustomTextFormField(
                filled: true,
                readOnly: true,
                hintText: "Select File",
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.persoNimageController,
                onChanged: (vaule) {
                  controller.update();
                },
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          controller.pickContactPersonPhoto();
                        },
                        child: Text(
                          "choose_file".tr,
                          style: Styles.g1txtColor60014,
                        ),
                      ),
                    ],
                  ),
                ),
                title: "Upload Contact Person Photo".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 2. Company Name
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Company Name".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.companyNameController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Company Name".tr;
                  }
                  return null;
                },
                title: "Company Name".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 3. Contact Person Name
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Contact Person Name".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.companyPersonNameController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Contact Person Name".tr;
                  }
                  return null;
                },
                title: "Contact Person Name".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  "name_as_per_pan".tr,
                  style: Styles.g7txtColor40012,
                ),
              ),
              Dimens.boxHeight16,
              // 3a. Contact Person Date of Birth
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Select DOB".tr,
                filled: true,
                readOnly: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.companyDobController,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(
                      const Duration(days: 6570),
                    ),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    final day = pickedDate.day.toString().padLeft(2, '0');
                    final month = pickedDate.month.toString().padLeft(2, '0');
                    final year = pickedDate.year;
                    controller.companyDobController.text = "$day/$month/$year";
                    controller.update();
                  }
                },
                title: "Date of Birth".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  "dob_as_per_pan".tr,
                  style: Styles.g7txtColor40012,
                ),
              ),
              Dimens.boxHeight16,
              // 4. Phone Number
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Phone Number".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.mobileNumberController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Phone Number".tr;
                  }
                  return null;
                },
                title: "Phone Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 5. Email
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Email".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.gmailController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Email".tr;
                  }
                  return null;
                },
                title: "Email".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 6. State
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Owner State".tr,
                filled: true,
                readOnly: true,
                onTap: () {
                  controller.showSelectionModal(
                    list: controller.statesList,
                    title: "Select State",
                    searchKey: "state_name",
                    onSelected: (val) {
                      final stateName = (val['state_name'] ?? val['name']).toString();
                      controller.stateController.text = stateName;
                      controller.cityController.clear();
                      controller.fetchCitiesByState(stateName);
                      controller.update();
                    },
                  );
                },
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.stateController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Owner State".tr;
                  }
                  return null;
                },
                title: "Your State".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 7. City
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Owner City".tr,
                filled: true,
                readOnly: true,
                onTap: () {
                  if (controller.stateController.text.trim().isEmpty) {
                    Utility.snacBar("Please select State first", ColorsValue.redColor);
                    return;
                  }
                  controller.showSelectionModal(
                    list: controller.citiesList,
                    title: "Select City",
                    searchKey: "city_name",
                    onSelected: (val) {
                      controller.cityController.text =
                          (val['city_name'] ?? val['name']).toString();
                      controller.update();
                    },
                  );
                },
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.cityController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Owner City".tr;
                  }
                  return null;
                },
                title: "Your City".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 8. Address
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Address".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.adressController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Address".tr;
                  }
                  return null;
                },
                title: "Address".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 9. Pincode
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Pin Code".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.pincodeController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Pin Code".tr;
                  }
                  return null;
                },
                title: "Your Pin Code".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 10. Fleet Size
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Fleet Size ".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                keyboardType: TextInputType.number,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.fleetSizeController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Fleet Size";
                  }
                  return null;
                },
                title: "Fleet Size".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight16,
              // 11. User Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("User Name".tr, style: Styles.blackColor60014),
                  Text(
                    " *",
                    style: Styles.blackColorW50016.copyWith(color: Colors.red),
                  ),
                ],
              ),
              Dimens.boxHeight5,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      style: Styles.g7txtColor70014,
                      hintText: "Enter User Name".tr,
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      isBorder: true,
                      isTitle: false,
                      textEditingController: controller.usernameController,
                      onChanged: (value) {
                        controller.isManualUsername = true;
                        controller.update();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter User Name".tr;
                        }
                        return null;
                      },
                      hintStyle: Styles.g7txtColor40012,
                    ),
                  ),
                  Dimens.boxWidth10,
                  GestureDetector(
                    onTap: () {
                      controller.isManualUsername = false;
                      controller.onRegistrationInfoChanged();
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ColorsValue.borderColor,
                          width: Dimens.one * 0.8,
                        ),
                        color: ColorsValue.fildColos,
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: ColorsValue.blackColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              // 12. Password
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Password".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.passwordController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Password".tr;
                  }
                  return null;
                },
                title: "Password".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Password Hint ",
                          style: Styles.redColor50014,
                        ),
                        TextSpan(
                          text:
                              ":  Password must contain at least 8 characters, including an uppercase letter, a number, and a special character (e.g., !, @, #).",
                          style: Styles.g7txtColor40014,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              // 13. Confirm Password
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Confirm Password ".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.rePasswordController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Confirm Password ".tr;
                  }
                  return null;
                },
                title: "Confirm Password ".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight100,
            ],
          ),
        );
      },
    );
  }
}
