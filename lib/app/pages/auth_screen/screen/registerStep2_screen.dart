import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bam_bam_vendor/app/app.dart';

class Registerstep2Screen extends StatelessWidget {
  const Registerstep2Screen({super.key});

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
                    if (controller.bankNameController.text.isEmpty ||
                        controller.bankHolderNameController.text.isEmpty ||
                        controller.bankAccountNumberController.text.isEmpty ||
                        controller.bankIFSCController.text.isEmpty ||
                        !controller.isBankVerified ||
                        controller.cancelCheque == null) {
                      Get.snackbar(
                        "Error",
                        "Please fill bank details, verify IFSC, and upload Cancel Cheque".tr,
                      );
                      return;
                    }

                    if (!controller.validateCompanyBankHolderName(context)) {
                      return;
                    }

                    RouteManagement.gotoRegisterstep3Screen();
                  },
                  backgroundColor: ColorsValue.appColor,
                  text: "Next",
                ),
              ),
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const BouncingScrollPhysics(),
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
                            "Bank Details".tr,
                            style: Styles.g1txtColor60016,
                          ),
                          Text("Setp 2 to 3".tr, style: Styles.appColor70012),
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
                                color: ColorsValue.appColor,
                                borderRadius: BorderRadius.circular(
                                  Dimens.five,
                                ),
                              ),
                            ),
                          ),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight30,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bank Name".tr, style: Styles.blackColor60014),
                      Text(' *', style: Styles.redColor50014),
                    ],
                  ),
                  Dimens.boxHeight8,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: ColorsValue.fildColos,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ColorsValue.g7txtColor.withValues(alpha: .2),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.bankNameController.text.isEmpty ? null : controller.bankNameController.text,
                        items: controller.availableBankNames.map((String bank) {
                          return DropdownMenuItem<String>(
                            value: bank,
                            child: Text(bank, style: Styles.g7txtColor70014),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.bankNameController.text = value;
                            controller.update();
                          }
                        },
                        isExpanded: true,
                        hint: Text("Select Bank".tr, style: Styles.g7txtColor40012),
                        icon: const Icon(Icons.keyboard_arrow_down, color: ColorsValue.g7txtColor),
                      ),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Branch Name".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.branchNameController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Branch Name".tr;
                  }
                  return null;
                },
                title: "Branch Name".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Account Holder Name".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.bankHolderNameController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Account Holder Name".tr;
                  }
                  return null;
                },
                title: "Account Holder Name".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter Account Number".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.bankAccountNumberController,
                onChanged: (vaule) {
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Account Number".tr;
                  }
                  return null;
                },
                title: "Account Number".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                style: Styles.g7txtColor70014,
                hintText: "Enter IFSC Code".tr,
                filled: true,
                fillColor: ColorsValue.fildColos,
                isBorder: true,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.bankIFSCController,
                onChanged: (value) {
                  controller.isBankVerified = false;
                  controller.update();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter IFSC Code".tr;
                  }
                  return null;
                },
                suffixIcon: controller.isBankVerifying
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColorsValue.appColor),
                        ),
                      )
                    : controller.isBankVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(
                            onPressed: () {
                              controller.verifyBank(
                                controller.bankAccountNumberController.text,
                                controller.bankIFSCController.text,
                              );
                            },
                            child: Text("Verify".tr, style: Styles.appColor60014),
                          ),
                title: "IFSC Code".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
              ),
              Dimens.boxHeight20,
              _documentField(
                title: "Cancel Cheque".tr,
                controller: controller.cancelChequeController,
                onTap: () {
                  controller.pickDocument(
                    onPicked: (file) => controller.cancelCheque = file,
                    controller: controller.cancelChequeController,
                  );
                },
              ),
              Dimens.boxHeight100,
            ],
          ),
        );
      },
    );
  }

  Widget _documentField({
    required String title,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    final bool isSelected = controller.text.isNotEmpty;
    return CustomTextFormField(
      filled: true,
      readOnly: true,
      fillColor: isSelected
          ? Colors.green.withValues(alpha: .05)
          : ColorsValue.fildColos,
      style: Styles.g7txtColor70014,
      isBorder: true,
      isTitle: true,
      isCompulsory: true,
      hintText: "Select File".tr,
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
              child: isSelected
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 4),
                        Text("Selected".tr, style: Styles.greenColor50014),
                      ],
                    )
                  : Text("choose_file".tr, style: Styles.g1txtColor60014),
            ),
          ),
        ],
      ),
    );
  }
}
