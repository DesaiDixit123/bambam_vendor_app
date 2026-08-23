import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TripHistorysScreen extends StatelessWidget {
  const TripHistorysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () {
              if (Navigator.of(context).canPop()) {
                Get.back();
              } else {
                RouteManagement.gotoHomeScreen();
              }
            },
            title: "Trip History",
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                width: Get.width,
                padding: Dimens.edgeInsets16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.twelve),
                  color: ColorsValue.whiteColor,
                ),
                child: Column(
                  spacing: Dimens.sixteen,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Trips",
                      style: Styles.g7txtColor40016.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "3000",
                      style: Styles.g1txtColor60014.copyWith(
                        fontSize: Dimens.twentyFour,
                      ),
                    ),
                  ],
                ),
              ),
              Dimens.boxHeight16,
              Row(
                spacing: Dimens.sixteen,
                children: [
                  Expanded(
                    child: Container(
                      width: Get.width,
                      padding: Dimens.edgeInsets16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimens.twelve),
                        color: ColorsValue.whiteColor,
                      ),
                      child: Column(
                        spacing: Dimens.sixteen,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Completed Trips",
                            style: Styles.g7txtColor40016.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "₹28000",
                            style: Styles.g1txtColor60014.copyWith(
                              fontSize: Dimens.twentyFour,
                              color: ColorsValue.greenColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: Get.width,
                      padding: Dimens.edgeInsets16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimens.twelve),
                        color: ColorsValue.whiteColor,
                      ),
                      child: Column(
                        spacing: Dimens.sixteen,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cancelled Trips",
                            style: Styles.g7txtColor40016.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "₹48000",
                            style: Styles.g1txtColor60014.copyWith(
                              fontSize: Dimens.twentyFour,
                              color: ColorsValue.redColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Dimens.boxHeight16,
              ...List.generate(4, (index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        RouteManagement.gotoTripDetilesScreen();
                      },
                      child: Container(
                        width: Get.width,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: Dimens.five,
                                children: [
                                  Text(
                                    "Booking ID:",
                                    style: Styles.g6txtColor40012,
                                  ),
                                  Text(
                                    "#BBM00123456",
                                    style: Styles.g1txtColor60018,
                                  ),
                                ],
                              ),
                              Dimens.boxHeight8,
                              Text("One way", style: Styles.g7txtColor40014),
                              Text(
                                "Surat, Gujarat → Bangalore, Karnataka",
                                style: Styles.g1txtColor60014,
                              ),
                              Dimens.boxHeight4,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: Dimens.nine,
                                children: [
                                  Row(
                                    spacing: Dimens.five,
                                    children: [
                                      SvgPicture.asset(AssetConstants.calendar),
                                      Text(
                                        "14/06/25 ",
                                        style: Styles.g6txtColor40014,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: Dimens.five,
                                    children: [
                                      SvgPicture.asset(AssetConstants.clock),
                                      Text(
                                        " 01:00 PM ",
                                        style: Styles.g6txtColor40014,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Dimens.boxHeight5,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Vendor Fare",
                                    style: Styles.g6txtColor40012,
                                  ),
                                  Text(
                                    "₹6322",
                                    style: Styles.g1txtColor50016.copyWith(
                                      color: ColorsValue.greenColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Dimens.boxHeight12,
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
