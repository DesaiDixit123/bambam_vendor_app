import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/app.dart';

class Registerstep3Screen extends StatelessWidget {
  const Registerstep3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          extendBody: true,
          backgroundColor: ColorsValue.whiteColor,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "company_partner_registration".tr,
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            child: SafeArea(
              child: Padding(
                padding: Dimens.edgeInsets20_30_20_30,
                child: CustomButton(
                  onPressed: () {
                    if (controller.businessProofNumberController.text.trim().isEmpty) {
                      Utility.snacBar(
                        "Please enter ${controller.selectedBusinessProofType} number",
                        ColorsValue.redColor,
                      );
                      return;
                    }
                    if (controller.addressProofNumberController.text.trim().isEmpty) {
                      Utility.snacBar(
                        "Please enter ${controller.selectedAddressProofType} number",
                        ColorsValue.redColor,
                      );
                      return;
                    }
                    if (controller.businessLicense == null ||
                        controller.aadharCard == null ||
                        controller.panCard == null ||
                        controller.gstCertificate == null ||
                        controller.addressProof == null ||
                        controller.officePhoto == null ||
                        controller.visitingCard == null) {
                      Utility.snacBar(
                        "Please upload all required documents",
                        ColorsValue.appColor,
                      );
                      return;
                    }
                    controller.submitCompanyRegister();
                  },
                  backgroundColor: ColorsValue.appColor,
                  text: "Submit",
                ),
              ),
            ),
          ),

          // -------------------- BODY --------------------
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const ClampingScrollPhysics(),
            children: [
              _stepHeader(),

              Dimens.boxHeight30,

              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.aadhaarNumberController,
                title: "Aadhaar Number".tr,
                hintText: "Enter Aadhaar Number".tr,
                readOnly: false,
                onChanged: (value) {
                  controller.isCompanyAadhaarVerified = false;
                  controller.update();
                },
                maxLength: 12,
                keyboardType: TextInputType.number,
                suffixIcon: controller.isCompanyAadhaarVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isCompanyAadhaarVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.requestCompanyAadhaarOtp(controller.aadhaarNumberController.text);
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.panNumberController,
                title: "PAN Number".tr,
                hintText: "Enter PAN Number".tr,
                readOnly: false,
                onChanged: (value) {
                  controller.isCompanyPanVerified = false;
                  controller.update();
                },
                maxLength: 10,
                suffixIcon: controller.isCompanyPanVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isCompanyPanVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.verifyCompanyPAN(controller.panNumberController.text);
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.gstNumberController,
                title: "GSTIN",
                hintText: "Enter GSTIN".tr,
                readOnly: false,
                onChanged: (value) {
                  controller.isCompanyGstVerified = false;
                  controller.update();
                },
                maxLength: 15,
                suffixIcon: controller.isCompanyGstVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isCompanyGstVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.verifyCompanyGST(controller.gstNumberController.text);
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
              ),
              Dimens.boxHeight20,

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Business Proof Type".tr, style: Styles.blackColor60014),
                  Dimens.boxHeight8,
                  DropdownButtonFormField<String>(
                    value: controller.selectedBusinessProofType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorsValue.borderColor, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorsValue.borderColor, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorsValue.appColor, width: 1.0),
                      ),
                    ),
                    items: ['Gumasta dhara', 'MSME Certificate']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.tr, style: Styles.blackColor60014),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedBusinessProofType = val;
                        controller.update();
                      }
                    },
                  ),
                ],
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.businessProofNumberController,
                title: "${controller.selectedBusinessProofType} Number".tr,
                hintText: "Enter ${controller.selectedBusinessProofType} Number".tr,
                readOnly: false,
              ),
              Dimens.boxHeight20,
              _documentField(
                title: "${controller.selectedBusinessProofType} Document".tr,
                controller: controller.businessLicenseController,
                onTap: () {
                  controller.pickDocument(
                    onPicked: (file) => controller.businessLicense = file,
                    controller: controller.businessLicenseController,
                  );
                },
              ),

              Dimens.boxHeight20,

              _documentField(
                title: "Aadhaar Card".tr,
                controller: controller.aadharCardController,
                onTap: () {
                  controller.pickDocument(
                    onPicked: (file) => controller.aadharCard = file,
                    controller: controller.aadharCardController,
                  );
                },
              ),

              Dimens.boxHeight20,

              _documentField(
                title: "PAN Card".tr,
                controller: controller.panCardController,
                onTap: () {
                  controller.pickDocument(
                    onPicked: (file) => controller.panCard = file,
                    controller: controller.panCardController,
                  );
                },
              ),

              Dimens.boxHeight20,

              _documentField(
                title: "GST Certificate".tr,
                controller: controller.gstCertificateController,
                onTap: () {
                  controller.pickDocument(
                    onPicked: (file) => controller.gstCertificate = file,
                    controller: controller.gstCertificateController,
                  );
                },
              ),

              Dimens.boxHeight20,

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Address Proof Type".tr, style: Styles.blackColor60014),
                  Dimens.boxHeight8,
                  DropdownButtonFormField<String>(
                    value: controller.selectedAddressProofType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorsValue.fildColos,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorsValue.borderColor, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorsValue.borderColor, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorsValue.appColor, width: 1.0),
                      ),
                    ),
                    items: ['Light bill', 'Rent agreement', 'Phone bill']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.tr, style: Styles.blackColor60014),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedAddressProofType = val;
                        controller.update();
                      }
                    },
                  ),
                ],
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.addressProofNumberController,
                title: "${controller.selectedAddressProofType} Number".tr,
                hintText: "Enter ${controller.selectedAddressProofType} Number".tr,
                readOnly: false,
              ),
              Dimens.boxHeight20,
              _documentField(
                title: "${controller.selectedAddressProofType} Document".tr,
                controller: controller.addressProofController,
                onTap: () {
                  controller.pickDocument(
                    onPicked: (file) => controller.addressProof = file,
                    controller: controller.addressProofController,
                  );
                },
              ),
              Dimens.boxHeight20,

              _documentField(
                title: "Office Photo Upload".tr,
                controller: controller.officePhotoController,
                onTap: () {
                  controller.pickDocument(
                    onPicked: (file) => controller.officePhoto = file,
                    controller: controller.officePhotoController,
                  );
                },
              ),

              Dimens.boxHeight20,

              _documentField(
                title: "Visiting Card".tr,
                controller: controller.visitingCardController,
                onTap: () {
                  controller.pickDocument(
                    onPicked: (file) => controller.visitingCard = file,
                    controller: controller.visitingCardController,
                  );
                },
              ),

              Dimens.boxHeight80,
            ],
          ),
        );
      },
    );
  }

  // -------------------- HEADER --------------------
  Widget _stepHeader() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.twelve),
        color: ColorsValue.appColor.withValues(alpha: .1),
      ),
      padding: Dimens.edgeInsets16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("fleet_office".tr, style: Styles.g1txtColor60016),
              Text("Step 3 of 3".tr, style: Styles.appColor70012),
            ],
          ),
          Dimens.boxHeight16,
          Row(
            children: List.generate(
              5,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: index == 0 || index == 2 || index == 4 ? 12 : 2,
                  decoration: BoxDecoration(
                    shape: index == 0 || index == 2 || index == 4
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    color: ColorsValue.appColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- DOCUMENT FIELD --------------------
  Widget _documentField({
    required String title,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return CustomTextFormField(
      filled: true,
      readOnly: true,
      fillColor: ColorsValue.fildColos,
      style: Styles.g7txtColor70014,
      isBorder: true,
      isTitle: true,
      isCompulsory: true,
      hintText: "Select File",
      title: title,
      textEditingController: controller,
      hintStyle: Styles.g7txtColor40012,
      titleStyle: Styles.blackColor60014,
      suffixIcon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text("choose_file".tr, style: Styles.g1txtColor60014),
            ),
          ),
        ],
      ),
    );
  }
}
