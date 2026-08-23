import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(onTapBack: () => Get.back(), title: "Withdraw"),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                final text = controller.withdrawAmountController.text.trim();
                final amount = int.tryParse(text) ?? 0;
                controller.withdrawEarningsController(amount);
              },
              text: "Procced to Withdraw",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const BouncingScrollPhysics(),
            children: [
              Row(
                spacing: Dimens.eight,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.withdrawAmountController.text = "500";
                        controller.update();
                      },
                      borderRadius: BorderRadius.circular(Dimens.fifteen),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.withdrawAmountController.text == "500" ? ColorsValue.appColor.withOpacity(0.1) : ColorsValue.whiteColor,
                          borderRadius: BorderRadius.circular(Dimens.fifteen),
                          border: Border.all(color: controller.withdrawAmountController.text == "500" ? ColorsValue.appColor : ColorsValue.l2),
                        ),
                        child: Padding(
                          padding: Dimens.edgeInsets8,
                          child: Text("₹500", style: controller.withdrawAmountController.text == "500" ? Styles.g1txtColor60016.copyWith(color: ColorsValue.appColor) : Styles.g1txtColor60016),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.withdrawAmountController.text = "1000";
                        controller.update();
                      },
                      borderRadius: BorderRadius.circular(Dimens.fifteen),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.withdrawAmountController.text == "1000" ? ColorsValue.appColor.withOpacity(0.1) : ColorsValue.whiteColor,
                          borderRadius: BorderRadius.circular(Dimens.fifteen),
                          border: Border.all(color: controller.withdrawAmountController.text == "1000" ? ColorsValue.appColor : ColorsValue.l2),
                        ),
                        child: Padding(
                          padding: Dimens.edgeInsets8,
                          child: Text("₹1,000", style: controller.withdrawAmountController.text == "1000" ? Styles.g1txtColor60016.copyWith(color: ColorsValue.appColor) : Styles.g1txtColor60016),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight8,
              Row(
                spacing: Dimens.eight,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.withdrawAmountController.text = "2000";
                        controller.update();
                      },
                      borderRadius: BorderRadius.circular(Dimens.fifteen),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.withdrawAmountController.text == "2000" ? ColorsValue.appColor.withOpacity(0.1) : ColorsValue.whiteColor,
                          borderRadius: BorderRadius.circular(Dimens.fifteen),
                          border: Border.all(color: controller.withdrawAmountController.text == "2000" ? ColorsValue.appColor : ColorsValue.l2),
                        ),
                        child: Padding(
                          padding: Dimens.edgeInsets8,
                          child: Text("₹2,000", style: controller.withdrawAmountController.text == "2000" ? Styles.g1txtColor60016.copyWith(color: ColorsValue.appColor) : Styles.g1txtColor60016),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        controller.withdrawAmountController.text = "5000";
                        controller.update();
                      },
                      borderRadius: BorderRadius.circular(Dimens.fifteen),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: controller.withdrawAmountController.text == "5000" ? ColorsValue.appColor.withOpacity(0.1) : ColorsValue.whiteColor,
                          borderRadius: BorderRadius.circular(Dimens.fifteen),
                          border: Border.all(color: controller.withdrawAmountController.text == "5000" ? ColorsValue.appColor : ColorsValue.l2),
                        ),
                        child: Padding(
                          padding: Dimens.edgeInsets8,
                          child: Text("₹5,000", style: controller.withdrawAmountController.text == "5000" ? Styles.g1txtColor60016.copyWith(color: ColorsValue.appColor) : Styles.g1txtColor60016),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              CustomTextFormField(
                filled: true,
                fillColor: ColorsValue.fildColos,
                style: Styles.g7txtColor70014,
                isBorder: true,
                isCompulsory: true,
                isTitle: true,
                keyboardType: TextInputType.number,
                textEditingController: controller.withdrawAmountController,
                onChanged: (value) {
                  controller.update();
                },
                title: "Enter Amount to Withdraw".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
                preIocns: true,
                prefixIcon: Text(
                  "₹",
                  style: Styles.g1txtColor60020,
                  selectionColor: ColorsValue.blackColor,
                ),
              ),
              Dimens.boxHeight8,
              Text(
                "Available Balance: ₹${controller.earningsData?['wallet_balance'] ?? 0}",
                style: Styles.g5txtColor40012,
              ),
            ],
          ),
        );
      },
    );
  }
}

