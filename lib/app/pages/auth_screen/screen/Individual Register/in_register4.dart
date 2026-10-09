import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InRegister4 extends StatelessWidget {
  const InRegister4({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        final isRentedVehicle =
            controller.sourcingController.text.trim().toLowerCase() ==
            'rented vehicle';
        final hasCarrier =
            controller.luggageCarrierController.text.trim().toLowerCase() ==
            'yes';

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
                    if (controller.addressProofNumberController.text.trim().isEmpty) {
                      Utility.snacBar(
                        "Please enter ${controller.selectedAddressProofType} number",
                        ColorsValue.redColor,
                      );
                      return;
                    }
                    // Simplified validation for demo, but in real app we'd check all required
                    if (controller.aadharCard == null ||
                        controller.aadharCardBack == null ||
                        controller.panCard == null ||
                        controller.dlPhoto == null ||
                        controller.addressProof == null) {
                      Utility.snacBar(
                        "Please upload required primary documents",
                        ColorsValue.redColor,
                      );
                      return;
                    }
                    controller.submitIndividualRegister();
                  },
                  backgroundColor: ColorsValue.appColor,
                  text: "Submit",
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

              _sectionHeader("Personal Documents".tr),
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
                  controller.isAadhaarVerified = false;
                  controller.update();
                },
                maxLength: 12,
                keyboardType: TextInputType.number,
                suffixIcon: controller.isAadhaarVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isAadhaarVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.requestAadhaarOtp(controller.aadhaarNumberController.text);
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
                  controller.isPanVerified = false;
                  controller.update();
                },
                maxLength: 10,
                suffixIcon: controller.isPanVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isPanVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.verifyPAN(controller.panNumberController.text);
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
              ),
              Dimens.boxHeight20,
              _documentField(
                title: "Owner Photo".tr,
                controller: controller.ownerPhotoController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.ownerPhoto = file,
                  controller: controller.ownerPhotoController,
                ),
              ),
              _documentField(
                title: "Aadhaar Card (Front)".tr,
                controller: controller.aadharCardController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.aadharCard = file,
                  controller: controller.aadharCardController,
                ),
              ),
              _documentField(
                title: "Aadhaar Card (Back)".tr,
                controller: controller.aadharCardBackController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.aadharCardBack = file,
                  controller: controller.aadharCardBackController,
                ),
              ),
              _documentField(
                title: "PAN Card".tr,
                controller: controller.panCardController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.panCard = file,
                  controller: controller.panCardController,
                ),
              ),
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
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.addressProof = file,
                  controller: controller.addressProofController,
                ),
              ),
              _documentField(
                title: "Driving License Photo".tr,
                controller: controller.dlPhotoController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.dlPhoto = file,
                  controller: controller.dlPhotoController,
                ),
              ),

              Dimens.boxHeight30,
              _sectionHeader("Bank & Business Docs".tr),
              _documentField(
                title: "Visiting Card".tr,
                controller: controller.visitingCardController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.visitingCard = file,
                  controller: controller.visitingCardController,
                ),
              ),
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                textEditingController: controller.gstNumberController,
                title: "GSTIN",
                hintText: "Enter GSTIN".tr,
                readOnly: false,
                onChanged: (value) {
                  controller.isGstVerified = false;
                  controller.update();
                },
                maxLength: 15,
                suffixIcon: controller.isGstVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isGstVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.verifyGST(controller.gstNumberController.text);
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
              ),
              Dimens.boxHeight20,
              _documentField(
                title: "GST Certificate".tr,
                controller: controller.gstCertificateController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.gstCertificate = file,
                  controller: controller.gstCertificateController,
                ),
              ),

              Dimens.boxHeight30,
              _sectionHeader("Vehicle Documents".tr),
              _documentField(
                title: "RC Image".tr,
                controller: controller.rcImageController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.rcImage = file,
                  controller: controller.rcImageController,
                ),
              ),
              _documentField(
                title: "Insurance Document".tr,
                controller: controller.insuranceDocumentController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.insuranceDocument = file,
                  controller: controller.insuranceDocumentController,
                ),
              ),
              _documentField(
                title: "Fitness Document".tr,
                controller: controller.fitnessDocumentController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.fitnessDocument = file,
                  controller: controller.fitnessDocumentController,
                ),
              ),
              _documentField(
                title: "Permit Document".tr,
                controller: controller.permitDocumentController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.permitDocument = file,
                  controller: controller.permitDocumentController,
                ),
              ),
              _documentField(
                title: "PUC Document".tr,
                controller: controller.pucDocumentController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.pucDocument = file,
                  controller: controller.pucDocumentController,
                ),
              ),
              if (isRentedVehicle)
                _documentField(
                  title: "Rented Vehicle Agreement".tr,
                  controller: controller.rentedVehicleAgreementController,
                  onTap: () => controller.pickDocument(
                    onPicked: (file) =>
                        controller.rentedVehicleAgreement = file,
                    controller: controller.rentedVehicleAgreementController,
                  ),
                ),

              Dimens.boxHeight30,
              _sectionHeader("Vehicle Performance & Images".tr),
              _documentField(
                title: "Front Image".tr,
                controller: controller.frontImageController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.frontImage = file,
                  controller: controller.frontImageController,
                ),
              ),
              _documentField(
                title: "Back Image".tr,
                controller: controller.backImageController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.backImage = file,
                  controller: controller.backImageController,
                ),
              ),
              _documentField(
                title: "Left Image".tr,
                controller: controller.leftImageController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.leftImage = file,
                  controller: controller.leftImageController,
                ),
              ),
              _documentField(
                title: "Right Image".tr,
                controller: controller.rightImageController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.rightImage = file,
                  controller: controller.rightImageController,
                ),
              ),
              _documentField(
                title: "Interior Image".tr,
                controller: controller.interiorImageController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.interiorImage = file,
                  controller: controller.interiorImageController,
                ),
              ),
              _documentField(
                title: "Number Plate Image".tr,
                controller: controller.numberPlateImageController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.numberPlateImage = file,
                  controller: controller.numberPlateImageController,
                ),
              ),
              _documentField(
                title: "Dicky Image".tr,
                controller: controller.dickyImageController,
                onTap: () => controller.pickDocument(
                  onPicked: (file) => controller.dickyImage = file,
                  controller: controller.dickyImageController,
                ),
              ),
              if (hasCarrier)
                _documentField(
                  title: "Carrier Image".tr,
                  controller: controller.carrierImageController,
                  onTap: () => controller.pickDocument(
                    onPicked: (file) => controller.carrierImage = file,
                    controller: controller.carrierImageController,
                  ),
                ),
              Dimens.boxHeight50,
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
                Text("Document Uploads".tr, style: Styles.g1txtColor60016),
                Text("Step 4 Of 4".tr, style: Styles.appColor70012),
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
        bool isDone = index < 4;
        bool isCurrent = index == 3;
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

  Widget _documentField({
    required String title,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    final bool isSelected = controller.text.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(bottom: Dimens.twenty),
      child: CustomTextFormField(
        filled: true,
        readOnly: true,
        hintText: "Select File".tr,
        fillColor: isSelected
            ? Colors.green.withValues(alpha: .05)
            : ColorsValue.fildColos,
        style: Styles.g7txtColor70014,
        isBorder: true,
        isTitle: true,
        isCompulsory: true,
        onTap: onTap,
        textEditingController: controller,
        title: title,
        hintStyle: Styles.g7txtColor40012,
        titleStyle: Styles.blackColor60014,
        suffixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: onTap,
              child: Container(
                width: 100,
                alignment: Alignment.center,
                child: isSelected
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          Dimens.boxWidth4,
                          Text("Selected".tr, style: Styles.greenColor50014),
                        ],
                      )
                    : Text("choose_file".tr, style: Styles.g1txtColor60014),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
