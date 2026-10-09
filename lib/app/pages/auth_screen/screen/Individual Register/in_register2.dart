import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InRegister2 extends StatelessWidget {
  const InRegister2({super.key});

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

                    if (!controller.validateIndividualBankHolderName(context)) {
                      return;
                    }

                    RouteManagement.gotoInRegister3();
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
              _sectionHeader("License Details".tr),
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.dlNumberController,
                title: "DL Number".tr,
              ),
              Dimens.boxHeight20,
              Row(
                spacing: Dimens.twenty,
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      style: Styles.g7txtColor70014,
                      hintText: "Select Issue Date".tr,
                      filled: true,
                      readOnly: true,
                      fillColor: ColorsValue.fildColos,
                      isBorder: true,
                      isTitle: true,
                      isCompulsory: true,
                      textEditingController: controller.dlIssueDateController,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          controller.dlIssueDateController.text = pickedDate
                              .toLocal()
                              .toString()
                              .split(' ')[0];
                          controller.update();
                        }
                      },
                      title: "DL Issue Date".tr,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                    ),
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      style: Styles.g7txtColor70014,
                      hintText: "Select Expiry Date".tr,
                      filled: true,
                      readOnly: true,
                      fillColor: ColorsValue.fildColos,
                      isBorder: true,
                      isTitle: true,
                      isCompulsory: true,
                      textEditingController: controller.dlExpiryDateController,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                        );
                        if (pickedDate != null) {
                          controller.dlExpiryDateController.text = pickedDate
                              .toLocal()
                              .toString()
                              .split(' ')[0];
                          controller.update();
                        }
                      },
                      title: "DL Expiry Date".tr,
                      hintStyle: Styles.g7txtColor40012,
                      titleStyle: Styles.blackColor60014,
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight30,
              _sectionHeader("Bank Details".tr),
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
                filled: true,
                fillColor: ColorsValue.fildColos,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.branchNameController,
                title: "Branch Name".tr,
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.bankHolderNameController,
                title: "Account Holder Name".tr,
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.bankAccountNumberController,
                title: "Account Number".tr,
              ),
              Dimens.boxHeight20,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                isTitle: true,
                isCompulsory: true,
                textEditingController: controller.bankIFSCController,
                title: "IFSC Code".tr,
                onChanged: (value) {
                  controller.isBankVerified = false;
                  controller.update();
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
