import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class EarningsVaultscreen extends StatelessWidget {
  const EarningsVaultscreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.find<HomeController>().fetchEarningsVaultData();
        });
      },
      builder: (controller) {
        final data = controller.earningsData ?? {};
        final missRides = data['miss_rides_loss'] ?? {};
        final bookingSummary = data['execute_booking_summary'] ?? {};
        final summaryStats = bookingSummary['summary'] ?? {};
        final bookings = bookingSummary['bookings']?['data'] as List? ?? [];

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: Navigator.of(context).canPop()
              ? AppBarWidget(
                  onTapBack: () {
                    if (Navigator.of(context).canPop()) {
                      Get.back();
                    } else {
                      RouteManagement.gotoHomeScreen();
                    }
                  },
                  title: "Earnings Vault",
                )
              : null,
          body: controller.isEarningsLoading
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchEarningsVaultData();
                  },
                  child: ListView(
                    padding: Dimens.edgeInsets20,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      /// Earnings Summary Label
                      Padding(
                        padding: Dimens.edgeInsets0_0_0_10,
                        child: Row(
                          children: [
                            Text(
                              "Earnings Summary",
                              style: Styles.g1txtColor60016,
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                      Dimens.boxHeight16,

                      /// Wallet Balance Card
                      Container(
                        decoration: BoxDecoration(
                          color: ColorsValue.whiteColor,
                          borderRadius: BorderRadius.circular(Dimens.twelve),
                        ),
                        padding: Dimens.edgeInsets16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Wallet Balance",
                                  style: Styles.g7txtColor40014,
                                ),
                                Spacer(),
                                InkWell(
                                  onTap: () {
                                    RouteManagement
                                        .gotoTransactionHistoryscreen();
                                  },
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          AssetConstants.ic_history),
                                      Dimens.boxWidth5,
                                      Text(
                                        "History",
                                        style: Styles.g7txtColor40014.copyWith(
                                          color: ColorsValue.appColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Dimens.boxHeight10,
                            Text(
                              "₹${data['wallet_balance'] ?? 0}",
                              style: Styles.g1txtColor60020.copyWith(
                                color: Colors.green,
                                fontSize: Dimens.twentyFour,
                              ),
                            ),
                            Dimens.boxHeight20,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              spacing: Dimens.sixteen,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      RouteManagement.gotoWithdrawScreen();
                                    },
                                    child: _actionButton(
                                      "Withdraw",
                                      AssetConstants.ic_wallet,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      RouteManagement.gotoTopUpwalletscreen();
                                    },
                                    child: _actionButton(
                                      "Top-Up",
                                      AssetConstants.ic_topup,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Dimens.boxHeight16,

                      /// Missed Ride + Earnings Cards
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: Dimens.edgeInsets16,
                              decoration: BoxDecoration(
                                color: ColorsValue.whiteColor,
                                borderRadius: BorderRadius.circular(
                                  Dimens.twelve,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Miss Rides Loss",
                                    style: Styles.g7txtColor40014,
                                  ),
                                  Dimens.boxHeight12,
                                  Row(
                                    children: [
                                      Text(
                                        "${missRides['count'] ?? 0}",
                                        style: Styles.g1txtColor60020.copyWith(
                                          color: ColorsValue.redColor,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        "₹${missRides['amount'] ?? 0}",
                                        style: Styles.g1txtColor60020.copyWith(
                                          fontSize: Dimens.twentyFour,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Dimens.boxHeight16,
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              "Driver’s Collection Pending",
                              "₹${data['drivers_collection_pending'] ?? 0}",
                              "",
                              Colors.red,
                            ),
                          ),
                          Dimens.boxWidth16,
                          Expanded(
                            child: _summaryCard(
                              "Total Earnings      \n",
                              "₹${data['net_total_earnings'] ?? 0}",
                              "",
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Dimens.boxHeight16,
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              "Paid By Bam Bam\n",
                              "₹${data['paid_by_bambam'] ?? 0}",
                              "",
                              Colors.black,
                            ),
                          ),
                          Dimens.boxWidth16,
                          Expanded(
                            child: _summaryCard(
                              "Bam Bam Outstanding",
                              "₹${data['bambam_outstanding'] ?? 0}",
                              "",
                              Colors.red,
                            ),
                          ),
                        ],
                      ),

                      Dimens.boxHeight20,

                      /// Execute Booking Summary TABLE
                      Container(
                        decoration: BoxDecoration(
                          color: ColorsValue.whiteColor,
                          borderRadius: BorderRadius.circular(Dimens.twelve),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: Get.width,
                              decoration: BoxDecoration(color: ColorsValue.l2),
                              child: Padding(
                                padding: Dimens.edgeInsets8,
                                child: Text(
                                  "Execute Booking Summary",
                                  style: Styles.g1txtColor60016,
                                ),
                              ),
                            ),
                            Dimens.boxHeight16,
                            _bookingSummaryTable(summaryStats),
                          ],
                        ),
                      ),

                      Dimens.boxHeight20,

                      /// Expandable booking cards
                      if (bookings.isEmpty)
                        Center(child: Text("No bookings found"))
                      else
                        ...List.generate(bookings.length, (index) {
                          final booking = bookings[index];
                          final isOpen = controller.selectedIndexEarn == index;
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  controller.selectedIndexEarn =
                                      isOpen ? -1 : index;
                                  controller.update();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorsValue.whiteColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(Dimens.twelve),
                                      topRight: Radius.circular(Dimens.twelve),
                                    ),
                                  ),
                                  padding: Dimens.edgeInsets16,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Booking ID: ",
                                        style: Styles.g7txtColor40014,
                                      ),
                                      Text(
                                        booking['booking_id'] ?? "",
                                        style: Styles.g1txtColor60016,
                                      ),
                                      Spacer(),
                                      Icon(
                                        isOpen
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /// Expanded section
                              if (isOpen)
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorsValue.whiteColor,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft:
                                          Radius.circular(Dimens.twelve),
                                      bottomRight:
                                          Radius.circular(Dimens.twelve),
                                    ),
                                  ),
                                  padding: Dimens.edgeInsets16,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: AssetImage(
                                              AssetConstants.person,
                                            ),
                                            radius: 22,
                                          ),
                                          Dimens.boxWidth12,
                                          Text(
                                            booking['user_name'] ?? "Unknown",
                                            style: Styles.g1txtColor60016,
                                          ),
                                        ],
                                      ),
                                      Dimens.boxHeight16,
                                      _detailRow(
                                        "Trip Fare",
                                        "₹${booking['trip_fare'] ?? 0}",
                                      ),
                                      _detailRow(
                                        "Paid Amount",
                                        "₹${booking['paid_amount'] ?? 0}",
                                      ),
                                      _detailRow(
                                        "Pending Amount",
                                        "₹${booking['pending_amount'] ?? 0}",
                                      ),
                                      _detailRow(
                                        "Commission Amount",
                                        "₹${booking['commission_amount'] ?? 0}",
                                      ),
                                      _detailRow(
                                        "Payment Mode",
                                        booking['payment_mode'] ?? "N/A",
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Payment Status",
                                            style: Styles.g7txtColor40014,
                                          ),
                                          _statusTag(
                                            booking['payment_status'] ??
                                                "Pending",
                                            booking['payment_status'] == 'Paid'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ],
                                      ),
                                      Dimens.boxHeight10,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Trip Status",
                                            style: Styles.g7txtColor40014,
                                          ),
                                          _statusTag(
                                            booking['trip_status'] ?? "N/A",
                                            Colors.orange,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                              Dimens.boxHeight12,
                            ],
                          );
                        }),
                    ],
                  ),
                ),
        );
      },
    );
  }

  /// Action buttons
  Widget _actionButton(String text, String icon) {
    return Container(
      height: Dimens.fourtyFive,
      decoration: BoxDecoration(
        color: ColorsValue.appColor,
        borderRadius: BorderRadius.circular(Dimens.twenty),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon),
          Dimens.boxWidth8,
          Text(
            text,
            style: Styles.g1txtColor60014.copyWith(
              color: ColorsValue.whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Small summary cards
  Widget _summaryCard(String title, String value, String sub, Color color) {
    return Container(
      padding: Dimens.edgeInsets16,
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.g7txtColor40014),
          Dimens.boxHeight12,
          Text(value, style: Styles.g1txtColor60020.copyWith(color: color)),
          if (sub.isNotEmpty) ...[
            Dimens.boxHeight8,
            Text(sub, style: Styles.g7txtColor40014.copyWith(color: color)),
          ],
        ],
      ),
    );
  }

  /// Booking summary table (4 columns)
  Widget _bookingSummaryTable(Map<String, dynamic> summary) {
    final totalBooking = summary['total_booking'] ?? {};
    final partnerBilled = summary['partner_billed'] ?? {};
    final partnerUnbilled = summary['partner_unbilled'] ?? {};

    final headers = ["All", "One Way", "Round Trip", "Local Rental Trip"];
    final rows = [
      [
        "Total Booking",
        "${totalBooking['all'] ?? 0}",
        "${totalBooking['oneway'] ?? 0}",
        "${totalBooking['roundtrip'] ?? 0}",
        "${totalBooking['local'] ?? 0}",
      ],
      [
        "Vendor Billed",
        "${partnerBilled['all'] ?? 0}",
        "${partnerBilled['oneway'] ?? 0}",
        "${partnerBilled['roundtrip'] ?? 0}",
        "${partnerBilled['local'] ?? 0}",
      ],
      [
        "Vendor Unbilled",
        "${partnerUnbilled['all'] ?? 0}",
        "${partnerUnbilled['oneway'] ?? 0}",
        "${partnerUnbilled['roundtrip'] ?? 0}",
        "${partnerUnbilled['local'] ?? 0}",
      ],
    ];

    return Table(
      columnWidths: {0: FlexColumnWidth(1.5)},
      children: [
        TableRow(
          children: [
            Container(),
            ...headers.map(
              (e) => Center(child: Text(e, style: Styles.g1txtColor60014)),
            ),
          ],
        ),
        ...rows.map((row) {
          return TableRow(
            children: [
              Padding(
                padding: Dimens.edgeInsets10,
                child: Text(row[0], style: Styles.g7txtColor40014),
              ),
              for (int i = 1; i < row.length; i++)
                Padding(
                  padding: Dimens.edgeInsets10,
                  child: Center(
                    child: Text(row[i], style: Styles.g1txtColor60014),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  /// Key–value row
  Widget _detailRow(String key, String value) {
    return Padding(
      padding: Dimens.edgeInsets0_0_0_10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: Styles.g7txtColor40014),
          Text(value, style: Styles.g1txtColor60016),
        ],
      ),
    );
  }

  /// Status chip
  Widget _statusTag(String text, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(Dimens.eight),
      ),
      child: Padding(
        padding: Dimens.edgeInsets16_8_16_8,
        child: Text(text, style: Styles.g1txtColor60014.copyWith(color: color)),
      ),
    );
  }
}
