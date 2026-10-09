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
                    if (!controller.isCompanyMobileVerified) {
                      Get.snackbar("Verification Required", "Please verify your mobile number with OTP before proceeding");
                      return;
                    }
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
                  backgroundColor: controller.isCompanyMobileVerified ? ColorsValue.appColor : const Color(0xFFCBD5E1),
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
              // 4. Phone Number & OTP Verification
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Phone Number".tr,
                filled: true,
                keyboardType: TextInputType.phone,
                readOnly: controller.isCompanyMobileVerified,
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
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: controller.isCompanyMobileVerified
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF12724A), size: 18),
                            const SizedBox(width: 4),
                            const Text("Verified", style: TextStyle(color: Color(0xFF12724A), fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                controller.isCompanyMobileVerified = false;
                                controller.companyOtpController.clear();
                                controller.update();
                              },
                              child: const Text("Change", style: TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.underline)),
                            ),
                          ],
                        )
                      : TextButton(
                          onPressed: controller.isCompanySendingOtp
                              ? null
                              : () => controller.sendCompanyRegistrationOtp(),
                          child: controller.isCompanySendingOtp
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(
                                  controller.isCompanyMobileOtpSent ? "Resend OTP" : "Send OTP",
                                  style: const TextStyle(color: Color(0xFF12724A), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                        ),
                ),
              ),

              // OTP Input Box (when OTP is sent and not yet verified)
              if (!controller.isCompanyMobileVerified && controller.isCompanyMobileOtpSent) ...[
                Dimens.boxHeight12,
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Enter 6-digit OTP sent to your number",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF166534)),
                          ),
                          Obx(() => controller.canResendCompanyOtp.value
                              ? GestureDetector(
                                  onTap: controller.isCompanySendingOtp
                                      ? null
                                      : () => controller.sendCompanyRegistrationOtp(),
                                  child: const Text("Resend", style: TextStyle(color: Color(0xFF12724A), fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)),
                                )
                              : Text("Resend in ${controller.companyOtpSeconds.value}s", style: const TextStyle(color: Colors.grey, fontSize: 11))),
                        ],
                      ),
                      Dimens.boxHeight10,
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: TextField(
                                controller: controller.companyOtpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 6),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '------',
                                  hintStyle: const TextStyle(letterSpacing: 6, color: Colors.grey),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF12724A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              onPressed: controller.isCompanyVerifyingOtp
                                  ? null
                                  : () => controller.verifyCompanyRegistrationOtp(),
                              child: controller.isCompanyVerifyingOtp
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Verify OTP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Locked state banner if mobile not verified yet
              if (!controller.isCompanyMobileVerified) ...[
                Dimens.boxHeight20,
                Container(
                  padding: Dimens.edgeInsets16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(Dimens.twelve),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: Color(0xFFD97706), size: 24),
                      Dimens.boxWidth12,
                      Expanded(
                        child: Text(
                          "Please verify your mobile number with OTP above to unlock the rest of registration form.".tr,
                          style: const TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
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
            ],
            Dimens.boxHeight100,
          ],
          ),
        );
      },
    );
  }
}
