import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TripcancelScreen extends StatelessWidget {
  const TripcancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        Get.find<HomeController>().fetchCancellationReasons();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.appBg,
          appBar: AppBarWidget(
            onTapBack: Get.back,
            title: "Share Your Cancellation Reason",
          ),
          body: Padding(
            padding: Dimens.edgeInsets20,
            child: Column(
              children: [
                Text(
                  "We're sorry to see you go. Please tell us why you're cancelling the trip so we can improve our service.",
                  style: Styles.g6txtColor40014,
                ),
                Dimens.boxHeight16,
                // Reasons List
                if (controller.cancellationReasonsList.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimens.twenty),
                      border: Border.all(color: ColorsValue.l3),
                    ),
                    child: Column(
                      children: List.generate(
                        controller.cancellationReasonsList.length,
                        (index) {
                          final reason =
                              controller.cancellationReasonsList[index];
                          return RadioListTile<int>(
                            value: index,
                            groupValue: controller.selectedReason,
                            onChanged: (value) {
                              controller.selectedReason = value!;
                              controller.selectedCancellationReasonId =
                                  reason['_id'];
                              controller.update();
                            },
                            title: Text(
                              reason['cancellation_reason'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                              ),
                            ),
                            activeColor: Colors.orangeAccent,
                            visualDensity: VisualDensity.compact,
                            dense: true,
                          );
                        },
                      ),
                    ),
                  ),

                Dimens.boxHeight16,
                CustomTextFormField(
                  filled: true,
                  fillColor: ColorsValue.fildColos,
                  style: Styles.g7txtColor70014,
                  hintText: "Enter Here".tr,
                  isBorder: true,
                  maxLines: 4,
                  isTitle: true,
                  keyboardType: TextInputType.text,
                  textEditingController:
                      controller.descriptionPolicyContrioller,
                  onChanged: (vaule) {
                    controller.update();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Here".tr;
                    }
                    return null;
                  },
                  title: "Description".tr,
                  hintStyle: Styles.g7txtColor40012,
                  titleStyle: Styles.g6txtColor40014,
                ),
                Spacer(),
                CustomButton(
                  onPressed: () {
                    // Assuming 'vendor_request_id' is passed or available in 'selectedTripDetails'
                    // In getTripLogDetails, we use 'vendor_request_id' to fetch.
                    // The response of view details contains '_id' which is likely the vendorRequestId
                    // Based on USER_REQUEST: {vendorRequestId: "6981c8671e94420a9d161e18", ...}
                    // And in details response: "Data": { "_id": "6981c8671e94420a9d161e18" ... }
                    // So we use _id from selectedTripDetails

                    if (controller.selectedTripDetails != null &&
                        controller.selectedTripDetails!['_id'] != null) {
                      controller.submitTripCancellation(
                        controller.selectedTripDetails!['_id'],
                      );
                    } else {
                      Utility.snacBar(
                        "Error: Vendor Request ID not found.",
                        Colors.red,
                      );
                    }
                  },
                  text: "Confirm Cancellation",
                  textStyle: Styles.appColor60016.copyWith(
                    color: ColorsValue.whiteColor,
                  ),
                  backgroundColor: ColorsValue.appColor,
                ),
                Dimens.boxHeight16,
                InkWell(
                  onTap: () {
                    RouteManagement.gotoTripcancellationPolicyScreen();
                  },
                  child: Text(
                    "View Cancellation Policy",
                    style: Styles.appColor60016.copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: ColorsValue.appColor,
                      decorationThickness: 2,
                    ),
                  ),
                ),
                Dimens.boxHeight16,
              ],
            ),
          ),
        );
      },
    );
  }
}
