import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InRegister1 extends StatelessWidget {
  const InRegister1({super.key});

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
                    if (controller.fullNameController.text.isEmpty ||
                        controller.mobileNumberController.text.isEmpty ||
                        controller.gmailController.text.isEmpty ||
                        controller.usernameController.text.isEmpty ||
                        controller.passwordController.text.isEmpty ||
                        controller.rePasswordController.text.isEmpty) {
                      Get.snackbar("Error", "Please fill all required fields");
                      return;
                    }

                    RouteManagement.gotoInRegister2();
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
              // uplod photo
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
              // full Name
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Name".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.fullNameController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Name".tr;
                  }
                  return null;
                },
                title: "full_name".tr,
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
              // DOB and UPI ID
              Row(
                spacing: Dimens.twenty,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          style: Styles.g7txtColor70014,
                          hintText: "Select DOB".tr,
                          filled: true,
                          readOnly: true,
                          fillColor: ColorsValue.fildColos,
                          isBorder: true,
                          isTitle: true,
                          isCompulsory: true,
                          textEditingController: controller.dobController,
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
                              controller.dobController.text = "$day/$month/$year";
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
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      style: Styles.g7txtColor70014,
                      hintText: "Enter UPI ID".tr,
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      isBorder: true,
                      isTitle: true,
                      isCompulsory: true,
                      textEditingController: controller.upiIdController,
                      title: "UPI ID".tr,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                    ),
                  ),
                ],
              ),
              // phoneNumner and  Email
              Dimens.boxHeight16,
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
              // Address
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
              // Address
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
              // PIN Code
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
              // Address
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
              // User Name
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
              // Address
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
              // Address
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
