import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopUpwalletscreen extends StatelessWidget {
  const TopUpwalletscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Top Up wallet",
          ),
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsets20_30_20_30,
            child: CustomButton(
              onPressed: () {
                if (controller.topUpAmountController.text.isEmpty) {
                  Utility.snacBar("Please enter an amount", Colors.red);
                  return;
                }
                final amount = int.tryParse(
                  controller.topUpAmountController.text,
                );
                if (amount == null || amount <= 0) {
                  Utility.snacBar("Please enter a valid amount", Colors.red);
                  return;
                }
                controller.initiateWalletTopUp(amount);
              },
              text: "Proceed to Pay",
              backgroundColor: ColorsValue.appColor,
            ),
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              Row(
                spacing: Dimens.eight,
                children: [
                  _amountPreset(controller, "500"),
                  _amountPreset(controller, "1000"),
                ],
              ),
              Dimens.boxHeight8,
              Row(
                spacing: Dimens.eight,
                children: [
                  _amountPreset(controller, "2000"),
                  _amountPreset(controller, "5000"),
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
                textEditingController: controller.topUpAmountController,
                onChanged: (value) {
                  controller.update();
                },
                title: "Enter Amount to Add".tr,
                hintStyle: Styles.g7txtColor40012,
                titleStyle: Styles.blackColor60014,
                preIocns: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("₹", style: Styles.g1txtColor60020),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _amountPreset(HomeController controller, String amount) {
    return Expanded(
      child: InkWell(
        onTap: () {
          controller.topUpAmountController.text = amount;
          controller.update();
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorsValue.whiteColor,
            borderRadius: BorderRadius.circular(Dimens.fifteen),
            border: Border.all(color: ColorsValue.l2),
          ),
          child: Padding(
            padding: Dimens.edgeInsets8,
            child: Text("₹$amount", style: Styles.g1txtColor60016),
          ),
        ),
      ),
    );
  }
}
