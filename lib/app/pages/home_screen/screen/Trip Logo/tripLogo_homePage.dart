import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TriplogoHomepage extends StatelessWidget {
  const TriplogoHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final bool showBackButton = ModalRoute.of(context)?.canPop ?? false;

        return Scaffold(
          backgroundColor: ColorsValue.appBg,
          appBar: showBackButton
              ? AppBarWidget(
                  onTapBack: () => Get.back(),
                  title: "Trip History",
                )
              : null,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.getTripLogs();
              },
              child: ListView(
                padding: Dimens.edgeInsets20,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimens.sixteen),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: Dimens.edgeInsets8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(controller.tabs.length, (index) {
                        final isSelected =
                            controller.selectedIndexTripLogs == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              controller.selectedIndexTripLogs = index;
                              controller.tripLogCurrentPage = 1;
                              controller.getTripLogs();
                              controller.update();
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                vertical: Dimens.eight,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orangeAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  controller.tabs[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Dimens.boxHeight16,
                  if (controller.tripLogList.isEmpty) ...[
                    Dimens.boxHeight40,
                    Image.asset(
                      AssetConstants.booking_recode_NotFind,
                      height: Dimens.threeHundred,
                    ),
                  ] else ...[
                    ...controller.tripLogList.map((trip) {
                      final booking = trip['booking_details'] ?? {};
                      final travel = booking['travelDetailsId'] ?? {};

                      final fb = trip['fare_breakdown'] ?? trip['vendorRequestDetails']?['fare_breakdown'] ?? booking['fare_breakdown'] ?? travel['fare_breakdown'];
                      final num displayFareNum = double.tryParse((fb?['final_payable_amount'] ?? trip['collect_cash_amount'] ?? booking['total_payment'] ?? travel['fare_summary']?['total_fare'] ?? travel['final_price'] ?? 0).toString()) ?? 0;
                      final String displayFareStr = (displayFareNum % 1 == 0) ? displayFareNum.toInt().toString() : displayFareNum.toStringAsFixed(2);

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              final vendorRequestId = trip['vendor_request_id'];
                              if (vendorRequestId != null) {
                                controller.getTripLogDetails(vendorRequestId);
                              }
                            },
                            child: Container(
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: ColorsValue.whiteColor,
                                borderRadius: BorderRadius.circular(
                                  Dimens.twelve,
                                ),
                              ),
                              child: Padding(
                                padding: Dimens.edgeInsets16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: Dimens.five,
                                      children: [
                                        Text(
                                          "Booking ID:",
                                          style: Styles.g6txtColor40012,
                                        ),
                                        Text(
                                          "${booking['booking_id'] ?? ''}",
                                          style: Styles.g1txtColor60018,
                                        ),
                                      ],
                                    ),
                                    Dimens.boxHeight8,
                                    Text(
                                      "${travel['trip_type'] ?? ''}",
                                      style: Styles.g7txtColor40014,
                                    ),
                                    Text(
                                      "${Utility.getDisplayFrom(travel)} → ${Utility.getDisplayTo(travel)}",
                                      style: Styles.g1txtColor60014,
                                    ),
                                    Dimens.boxHeight4,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      spacing: Dimens.nine,
                                      children: [
                                        Row(
                                          spacing: Dimens.five,
                                          children: [
                                            SvgPicture.asset(
                                              AssetConstants.calendar,
                                            ),
                                            Text(
                                              Utility.getFormatedTime(
                                                travel['pickup_date'] ??
                                                    DateTime.now().toString(),
                                                'dd/MM/yy',
                                              ),
                                              style: Styles.g6txtColor40014,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: Dimens.five,
                                          children: [
                                            SvgPicture.asset(
                                              AssetConstants.clock,
                                            ),
                                            Text(
                                              " ${travel['pickup_time'] ?? ''} ",
                                              style: Styles.g6txtColor40014,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Dimens.boxHeight5,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Vendor Fare",
                                          style: Styles.g6txtColor40012,
                                        ),
                                        Text(
                                          "₹$displayFareStr",
                                          style: Styles.g1txtColor50016
                                              .copyWith(
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

                    Dimens.boxHeight20,

                    // Pagination
                    if (controller.tripLogList.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: controller.tripLogCurrentPage > 1
                                ? () => controller.changeTripLogPage(1)
                                : null,
                            icon: Icon(Icons.first_page),
                            color: ColorsValue.appColor,
                          ),
                          IconButton(
                            onPressed: controller.tripLogCurrentPage > 1
                                ? () => controller.changeTripLogPage(
                                    controller.tripLogCurrentPage - 1,
                                  )
                                : null,
                            icon: Icon(Icons.chevron_left),
                            color: ColorsValue.appColor,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsValue.appColor,
                              borderRadius: BorderRadius.circular(Dimens.eight),
                            ),
                            child: Text(
                              "${controller.tripLogCurrentPage}",
                              style: Styles.whiteColorW60016,
                            ),
                          ),
                          IconButton(
                            onPressed:
                                controller.tripLogCurrentPage <
                                    controller.tripLogTotalPages
                                ? () => controller.changeTripLogPage(
                                    controller.tripLogCurrentPage + 1,
                                  )
                                : null,
                            icon: Icon(Icons.chevron_right),
                            color: ColorsValue.appColor,
                          ),
                          IconButton(
                            onPressed:
                                controller.tripLogCurrentPage <
                                    controller.tripLogTotalPages
                                ? () => controller.changeTripLogPage(
                                    controller.tripLogTotalPages,
                                  )
                                : null,
                            icon: Icon(Icons.last_page),
                            color: ColorsValue.appColor,
                          ),
                        ],
                      ),
                    Dimens.boxHeight20,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
