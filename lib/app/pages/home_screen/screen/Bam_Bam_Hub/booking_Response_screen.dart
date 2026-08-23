import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingResponseScreen extends StatelessWidget {
  const BookingResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          appBar: AppBarWidget(
            onTapBack: () {
              Get.back();
            },
            title: "Booking Response Details",
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              // Booking ID
              Text("Booking ID # 8626965", style: Styles.g1txtColor60016),
              Dimens.boxHeight12,
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.l4,
                  border: Border.all(color: ColorsValue.l1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _infoRow(
                      title: "Trip Details",
                      value:
                          "Surat → Bangalore,\nOutstation (One way drop)\nFor Wagon R or Equivalent",
                      highlight: true,
                    ),
                    _divider(),
                    _infoRow(
                      title: "Pickup Location",
                      value: "14/06/25\nAt DHS Hospital, Sunrise Park...",
                    ),
                    _divider(),
                    _infoRow(
                      title: "Drop Location",
                      value: "Golden City - Neelbad, Golden City ",
                    ),
                    //   _divider(),
                    // _infoRow(
                    //   title: "Driver Assignment Time",
                    //   value: "01:00 PM, 14/06/25",
                    //   boldValue: true,
                    // ),
                    // _divider(),
                    // _infoRow(
                    //   title: "Reporting Time",
                    //   value: "08:00 PM, 14/06/25",
                    //   boldValue: true,
                    // ),
                  ],
                ),
              ),
              Dimens.boxHeight16,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: controller.isInterested,
                    onChanged: (value) {
                      controller.isInterested = value ?? false;
                      controller.update();
                    },
                    checkColor: ColorsValue.whiteColor,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return ColorsValue.appColor;
                      }
                      return Colors.white;
                    }),
                    side: BorderSide(color: ColorsValue.appColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "is_intersetedDp".tr,
                      style: Styles.g6txtColor40012,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ColorsValue.l1),
                ),
                child: Column(
                  children: [
                    Container(
                      width: Get.width,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: ColorsValue.l1),
                      child: Padding(
                        padding: Dimens.edgeInsets8,
                        child: Text(
                          "Special Service",
                          style: Styles.g1txtColor60014,
                        ),
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Title
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Cab with Luggage Carrier",
                                style: Styles.g1txtColor40012.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          // Vertical Divider
                          Container(width: 1, color: ColorsValue.l1),

                          // Right Value
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "₹ 208",
                                style: Styles.g1txtColor40012.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(),
                    Padding(
                      padding: Dimens.edgeInsets00_10_00_10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: controller.isSpecial,
                            onChanged: (value) {
                              controller.isSpecial = value ?? false;
                              controller.update();
                            },
                            checkColor: ColorsValue.whiteColor,
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return ColorsValue.appColor;
                              }
                              return Colors.white;
                            }),
                            side: BorderSide(
                              color: ColorsValue.appColor,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "special_seriveDp".tr,
                              style: Styles.g6txtColor40012,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Dimens.boxHeight16,

              // Container(
              //   decoration: BoxDecoration(
              //     border: Border.all(color: ColorsValue.l1),
              //   ),
              //   child: Column(
              //     children: [
              //       Container(
              //         width: Get.width,
              //         alignment: Alignment.center,
              //         decoration: BoxDecoration(color: ColorsValue.l1),
              //         child: Padding(
              //           padding: Dimens.edgeInsets8,
              //           child: Text(
              //             "Advance Payment Link",
              //             style: Styles.g1txtColor60014,
              //           ),
              //         ),
              //       ),
              //       IntrinsicHeight(
              //         child: Row(
              //           crossAxisAlignment: CrossAxisAlignment.stretch,
              //           children: [
              //             // Left Title
              //             Expanded(
              //               flex: 3,
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(
              //                   horizontal: 12,
              //                   vertical: 12,
              //                 ),
              //                 child: Text(
              //                   "₹ 2361  Advance Amount Needs To Be Paid Via Payment Link",
              //                   style: Styles.g1txtColor40012.copyWith(
              //                     fontWeight: FontWeight.w600,
              //                   ),
              //                 ),
              //               ),
              //             ),

              //             // Vertical Divider
              //             Container(width: 1, color: ColorsValue.l1),

              //             // Right Value
              //             Expanded(
              //               flex: 1,
              //               child: Padding(
              //                 padding: const EdgeInsets.symmetric(
              //                   horizontal: 12,
              //                   vertical: 12,
              //                 ),
              //                 child: Text(
              //                   "₹ 2361 ",
              //                   style: Styles.g1txtColor40012.copyWith(
              //                     fontWeight: FontWeight.w600,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       _divider(),
              //       Padding(
              //         padding: Dimens.edgeInsets00_10_00_10,
              //         child: Row(
              //           crossAxisAlignment: CrossAxisAlignment.center,
              //           children: [
              //             Checkbox(
              //               value: controller.isAdvance,
              //               onChanged: (value) {
              //                 controller.isAdvance = value ?? false;
              //                 controller.update();
              //               },
              //               checkColor: ColorsValue.whiteColor,
              //               fillColor: WidgetStateProperty.resolveWith<Color>((
              //                 states,
              //               ) {
              //                 if (states.contains(WidgetState.selected)) {
              //                   return ColorsValue.appColor;
              //                 }
              //                 return Colors.white;
              //               }),
              //               side: BorderSide(
              //                 color: ColorsValue.appColor,
              //                 width: 2,
              //               ),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(4),
              //               ),
              //             ),
              //             Expanded(
              //               child: Text(
              //                 "is_Advance".tr,
              //                 style: Styles.g6txtColor40012,
              //                 overflow: TextOverflow.fade,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              //   Dimens.boxHeight16,
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: ColorsValue.l1),
                ),
                child: Column(
                  children: [
                    Container(
                      width: Get.width,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: ColorsValue.l1),
                      child: Padding(
                        padding: Dimens.edgeInsets8,
                        child: Text("Penalties", style: Styles.g1txtColor60014),
                      ),
                    ),
                    IntrinsicHeight(
                      child: Container(
                        decoration: BoxDecoration(color: ColorsValue.l3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Title
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Text(
                                  "Category",
                                  style: Styles.g1txtColor40012.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // Vertical Divider
                            Container(width: 2, color: ColorsValue.l1),

                            // Right Value
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Text(
                                  "Description",
                                  style: Styles.g1txtColor40012.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // Vertical Divider
                            Container(width: 2, color: ColorsValue.l1),

                            // Right Value
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Text(
                                  "Penalty",
                                  style: Styles.g1txtColor40012.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _divider(height: 2),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Title
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Unallocation",
                                style: Styles.g1txtColor40012.copyWith(),
                              ),
                            ),
                          ),

                          // Vertical Divider
                          Container(width: 2, color: ColorsValue.l1),

                          // Right Value
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Penalty If Booking Is Unallocated By You",
                                style: Styles.g1txtColor40012.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorsValue.g6txtColor,
                                ),
                              ),
                            ),
                          ),
                          // Vertical Divider
                          Container(width: 2, color: ColorsValue.l1),

                          // Right Value
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Up To ₹2000",
                                style: Styles.g1txtColor40012.copyWith(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(height: 2),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Title
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Assignment",
                                style: Styles.g1txtColor40012.copyWith(),
                              ),
                            ),
                          ),

                          // Vertical Divider
                          Container(width: 2, color: ColorsValue.l1),

                          // Right Value
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Penalty If Driver Is Not Assigned/Not Assigned On Time By You",
                                style: Styles.g1txtColor40012.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorsValue.g6txtColor,
                                ),
                              ),
                            ),
                          ),
                          // Vertical Divider
                          Container(width: 2, color: ColorsValue.l1),

                          // Right Value
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Up To ₹500",
                                style: Styles.g1txtColor40012.copyWith(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(height: 2),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Title
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "On Time/App Related",
                                style: Styles.g1txtColor40012.copyWith(),
                              ),
                            ),
                          ),

                          // Vertical Divider
                          Container(width: 2, color: ColorsValue.l1),

                          // Right Value
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Penalty For Driver Not Reaching On Time/If The App Is Not Used",
                                style: Styles.g1txtColor40012.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorsValue.g6txtColor,
                                ),
                              ),
                            ),
                          ),
                          // Vertical Divider
                          Container(width: 2, color: ColorsValue.l1),

                          // Right Value
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Text(
                                "Up To ₹500",
                                style: Styles.g1txtColor40012.copyWith(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _divider(height: 2),
                    Padding(
                      padding: Dimens.edgeInsets00_10_00_10,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: controller.isAcknowledge,
                            onChanged: (value) {
                              controller.isAcknowledge = value ?? false;
                              controller.update();
                            },
                            checkColor: ColorsValue.whiteColor,
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return ColorsValue.appColor;
                              }
                              return Colors.white;
                            }),
                            side: BorderSide(
                              color: ColorsValue.appColor,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "is_acknowlege".tr,
                              style: Styles.g6txtColor40012,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Dimens.boxHeight16,
              Center(
                child: InkWell(
                  onTap: () {
                    controller.showConfromBooking(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorsValue.appColor,
                      borderRadius: BorderRadius.circular(Dimens.twelve),
                    ),
                    child: Padding(
                      padding: Dimens.edgeInsets16_8_16_8,
                      child: Text("Confirm", style: Styles.whiteColorW60016),
                    ),
                  ),
                ),
              ),
              Dimens.boxHeight16,
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow({
    required String title,
    required String value,
    bool highlight = false,
    bool boldValue = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Title
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                title,
                style: Styles.g1txtColor40012.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Vertical Divider
          Container(width: 1, color: ColorsValue.l1),

          // Right Value
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Text(
                value,
                style: Styles.g6txtColor40012.copyWith(
                  color: highlight
                      ? ColorsValue.appColor
                      : ColorsValue.g6txtColor,
                  fontWeight: boldValue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider({double? height = 1}) {
    return Divider(height: 1, thickness: height, color: ColorsValue.l1);
  }
}
