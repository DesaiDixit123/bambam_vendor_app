import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DriverVehicalDetiles extends StatelessWidget {
  const DriverVehicalDetiles({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () {
              Get.back();
            },
            title: "Driver & Vehicle Details",
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Dimens.twelve,
                              ),
                              color: ColorsValue.redCB,
                            ),
                            child: Padding(
                              padding: Dimens.edgeInsets16_8_16_8,
                              child: Text(
                                "Driver & Vehicle Pending",
                                style: Styles.redColor50014,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Dimens.boxHeight16,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Booking ID",
                                  style: Styles.g7txtColor40014,
                                ),
                                Text(
                                  "#BBM00123456",
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Booking Date",
                                  style: Styles.g7txtColor40014,
                                ),
                                Text(
                                  "04/06/2025",
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Dimens.boxHeight16,
                      Text("Booking Type", style: Styles.g7txtColor40014),
                      Dimens.boxHeight4,
                      Text("Oneway", style: Styles.g1txtColor60016),
                      Dimens.boxHeight16,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pickup Date & Time",
                                  style: Styles.g7txtColor40014,
                                ),
                                Text(
                                  "#25-04-2025 04:00PM",
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Return Date & Time",
                                  style: Styles.g7txtColor40014,
                                ),
                                Text("-", style: Styles.g1txtColor60016),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("One way", style: Styles.g7txtColor40014),
                      Dimens.boxHeight2,
                      Text(
                        "Surat, Gujarat → Bangalore, Karnataka",
                        style: Styles.g1txtColor60014,
                      ),
                      Dimens.boxHeight8,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: Dimens.nine,
                        children: [
                          Row(
                            spacing: Dimens.five,
                            children: [
                              SvgPicture.asset(AssetConstants.calendar),
                              Text("14/06/25 ", style: Styles.g6txtColor40014),
                            ],
                          ),
                          Row(
                            spacing: Dimens.five,
                            children: [
                              SvgPicture.asset(AssetConstants.clock),
                              Text(" 01:00 PM ", style: Styles.g6txtColor40014),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("SUV", style: Styles.g7txtColor40014),
                              Text("New MG ZS", style: Styles.g1txtColor60016),
                            ],
                          ),
                          Image.asset(
                            AssetConstants.carpng,
                            height: Dimens.fourtyEight,
                          ),
                        ],
                      ),
                      Dimens.boxHeight16,
                      Row(
                        children: [
                          SvgPicture.asset(
                            AssetConstants.ic_gasStation,
                            color: ColorsValue.appColor,
                          ),
                          Dimens.boxWidth4,
                          Text("Diesel", style: Styles.g5txtColor40012),
                          Dimens.boxWidth6,
                          SvgPicture.asset(
                            AssetConstants.ic_manual,
                            color: ColorsValue.appColor,
                          ),
                          Dimens.boxWidth4,
                          Text("Manual", style: Styles.g5txtColor40012),
                          Dimens.boxWidth6,
                          SvgPicture.asset(
                            AssetConstants.ic_sets,
                            color: ColorsValue.appColor,
                          ),
                          Dimens.boxWidth4,
                          Text("5 seats", style: Styles.g5txtColor40012),
                          Dimens.boxWidth6,
                          SvgPicture.asset(
                            AssetConstants.ic_aircondiner,
                            color: ColorsValue.appColor,
                          ),
                          Dimens.boxWidth4,
                          Text(
                            "Air Conditioning",
                            style: Styles.g5txtColor40012,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: Dimens.edgeInsets0,
                        leading: Image.asset(AssetConstants.person),
                        title: Text("John Doe", style: Styles.g1txtColor60016),
                        subtitle: Text(
                          "johndoe123@gmail.com",
                          style: Styles.g7txtColor40014,
                        ),
                      ),
                      Dimens.boxHeight5,
                      _textinfo("Mobile No.", "+91 9817654321"),
                      _textinfo(
                        "Pickup Address",
                        "The Junomoneto tower, Adajan Rto 398765",
                      ),
                      _textinfo(
                        "Drop Address",
                        "The Junomoneto tower, Adajan Rto 398765",
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              Container(
                decoration: BoxDecoration(
                  color: ColorsValue.whiteColor,
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                ),
                child: Padding(
                  padding: Dimens.edgeInsets16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Fare Summary", style: Styles.appColor60016),
                      Dimens.boxHeight16,
                      _priceinfor("Base Fare", "₹4500"),
                      _priceinfor("Taxes & Fees", "₹125"),
                      _priceinfor("Other Charges", "₹100"),
                      _priceinfor(
                        "Coupon (FIRST RIDE)",
                        "-₹200",
                        iscolor: true,
                      ),
                      _priceinfor(
                        "Bam Bam Commission",
                        "-₹1822",
                        iscolor: true,
                      ),
                      Divider(color: ColorsValue.l2),
                      _priceinfor(
                        "Total Fare",
                        "₹6333",
                        iscolor: true,
                        istitlecolor: true,
                      ),
                    ],
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

  // Widget _infoRow({
  //   required String title,
  //   required String value,
  //   bool highlight = false,
  //   bool boldValue = false,
  // }) {
  //   return IntrinsicHeight(
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         // Left Title
  //         Expanded(
  //           flex: 2,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  //             child: Text(
  //               title,
  //               style: Styles.g1txtColor40012.copyWith(
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ),

  //         // Vertical Divider
  //         Container(width: 1, color: ColorsValue.l1),

  //         // Right Value
  //         Expanded(
  //           flex: 3,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  //             child: Text(
  //               value,
  //               style: Styles.g6txtColor40012.copyWith(
  //                 color: highlight
  //                     ? ColorsValue.appColor
  //                     : ColorsValue.g6txtColor,
  //                 fontWeight: boldValue ? FontWeight.w600 : FontWeight.normal,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _divider({double? height = 1}) {
  //   return Divider(height: 1, thickness: height, color: ColorsValue.l1);
  // }

  Widget _textinfo(String text1, String text2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text1, style: Styles.g1txtColor60016),
        Dimens.boxHeight2,
        Text(text2, style: Styles.g7txtColor40014),
        Dimens.boxHeight16,
      ],
    );
  }

  Widget _priceinfor(
    String name,
    String price, {
    bool? iscolor = false,
    bool? istitlecolor = false,
    bool? isredColor = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: Styles.g7txtColor40014.copyWith(
                color: istitlecolor == true
                    ? ColorsValue.g1txtColor
                    : ColorsValue.g7txtColor,
                fontWeight: istitlecolor == true
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
            Text(
              price,
              style: Styles.g1txtColor60014.copyWith(
                color: isredColor == true
                    ? ColorsValue.redColor
                    : iscolor == true
                    ? ColorsValue.greenColor
                    : ColorsValue.g1txtColor,
              ),
            ),
          ],
        ),
        Dimens.boxHeight8,
      ],
    );
  }

}
