import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/screen/Trip%20Logo/trip_invoice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TripdetilesScreen extends StatelessWidget {
  const TripdetilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final data = controller.selectedTripDetails ?? {};
        final booking = data['booking_id'] is Map ? data['booking_id'] : {};
        final travel = booking['travelDetailsId'] ?? {};

        final driver = booking['driver_id'] is Map
            ? booking['driver_id']
            : (data['driver_id'] is Map ? data['driver_id'] : {});

        final bookingVehicle = booking['vehicle_id'];
        final travelVehicle = travel['vehicleId'];
        final topVehicle = data['vehicle_id'];

        final vehicleDetails =
            (bookingVehicle is Map ? bookingVehicle : null) ??
            (travelVehicle is Map ? travelVehicle : null) ??
            (topVehicle is Map ? topVehicle : null) ??
            {};

        final payment = booking['payment_summary'] ?? {};
        final user = booking['userId'] ?? {};

        final double waitingChargeVal = double.tryParse((data['waiting_charge'] ?? booking['waiting_charge'] ?? 0).toString()) ?? 0;
        final int totalWaitingMins = int.tryParse((data['total_waiting_minutes'] ?? booking['total_waiting_minutes'] ?? 0).toString()) ?? 0;

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
              Row(
                children: [
                  if (data['ride_status'] == 'Completed')
                    InkWell(
                      onTap: () {
                        Get.to(() => TripInvoiceScreen(), arguments: data);
                      },
                      child: Text(
                        "View Invoice",
                        style: Styles.appColor60016.copyWith(
                          color: ColorsValue.greenColor,
                          decoration: TextDecoration.underline,
                          decorationColor: ColorsValue.greenColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  Spacer(),
                  if (data['ride_status'] != 'Cancelled' && data['ride_status'] != 'Completed')
                    InkWell(
                      onTap: () {
                        RouteManagement.gotoTripcancelScreen();
                      },
                      child: Text(
                        "Cancel Trip",
                        style: Styles.appColor60016.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: ColorsValue.appColor,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                ],
              ),
              Dimens.boxHeight10,
              _buildDynamicStatusBadge(data['ride_status']),
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
                                  "${booking['booking_id'] ?? ''}",
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
                                  Utility.getFormatedTime(
                                    booking['createdAt'] ??
                                        DateTime.now().toString(),
                                    'dd/MM/yyyy',
                                  ),
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
                      Text(
                        "${travel['trip_type'] ?? ''}",
                        style: Styles.g1txtColor60016,
                      ),
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
                                  "${Utility.getFormatedTime(travel['date'] ?? DateTime.now().toString(), 'dd-MM-yyyy')} ${travel['pickup_time'] ?? ''}",
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                          ),
                          if (travel['trip_type']?.toString().toLowerCase().contains('round') == true)
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Return Date & Time",
                                    style: Styles.g7txtColor40014,
                                  ),
                                  Text(
                                    travel['return_date'] != null && travel['return_date'].toString().isNotEmpty && travel['return_date'].toString() != 'null'
                                        ? "${Utility.getFormatedTime(travel['return_date'], 'dd-MM-yyyy')} ${travel['return_time'] ?? ''}"
                                        : "-",
                                    style: Styles.g1txtColor60016,
                                  ),
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
                      Text(
                        "${travel['trip_type'] ?? ''}",
                        style: Styles.g7txtColor40014,
                      ),
                      Dimens.boxHeight2,
                      Text(
                        "${Utility.getDisplayFrom(travel)} → ${Utility.getDisplayTo(travel)}",
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
                              Text(
                                Utility.getFormatedTime(
                                  travel['date'] ?? DateTime.now().toString(),
                                  'dd/MM/yy ',
                                ),
                                style: Styles.g6txtColor40014,
                              ),
                            ],
                          ),
                          Row(
                            spacing: Dimens.five,
                            children: [
                              SvgPicture.asset(AssetConstants.clock),
                              Text(
                                " ${travel['pickup_time'] ?? ''} ",
                                style: Styles.g6txtColor40014,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              if (vehicleDetails['_id'] != null)
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
                                Text(
                                  vehicleDetails['brand_name'] ?? "",
                                  style: Styles.g7txtColor40014,
                                ),
                                Text(
                                  vehicleDetails['vehicle_number'] ?? "",
                                  style: Styles.g1txtColor60016,
                                ),
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
                            Text(
                              (vehicleDetails['fuel_type'] is List
                                  ? (vehicleDetails['fuel_type'] as List)
                                        .map((e) => e is Map ? e['name'] : '')
                                        .join(',')
                                  : "Fuel"),
                              style: Styles.g5txtColor40012,
                            ),
                            Dimens.boxWidth6,
                            // Add more vehicle details if available in response
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (vehicleDetails['_id'] != null) Dimens.boxHeight16,
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
                        title: Text(
                          user['full_name'] ?? "User",
                          style: Styles.g1txtColor60016,
                        ),
                        subtitle: Text(
                          user['email'] ?? "",
                          style: Styles.g7txtColor40014,
                        ),
                      ),
                      Dimens.boxHeight5,
                      _textinfo("Mobile No.", "${user['phone_no'] ?? ''}"),
                      _textinfo(
                        "Pickup Address",
                        travel['pickup_address'] ?? "",
                      ),
                      _textinfo(
                        "Drop Address",
                        (travel['drop_address'] as List?)?.join(', ') ?? "",
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              if (driver['_id'] != null)
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
                          title: Text(
                            "Driver Name",
                            style: Styles.g1txtColor60016,
                          ),
                          subtitle: Text(
                            driver['driver_name'] ?? "",
                            style: Styles.g7txtColor40014,
                          ),
                        ),
                        Dimens.boxHeight5,
                        _textinfo(
                          "Mobile No.",
                          "${driver['driver_mobile'] ?? ''}",
                        ),
                        // Driver address not always available
                      ],
                    ),
                  ),
                ),

              if (driver['_id'] != null) Dimens.boxHeight16,
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
                      Text("Trip Fare Summary", style: Styles.appColor60016),
                      Dimens.boxHeight16,
                      Builder(builder: (_) {
                        final fb = data['vendorRequestDetails']?['fare_breakdown'] ?? data['fare_breakdown'] ?? booking['fare_breakdown'] ?? travel['fare_breakdown'];
                        final rideSt = (data['ride_status'] ?? booking['booking_status'] ?? '').toString().toLowerCase();
                        final bool isCompleted = rideSt.contains('complete') || rideSt == 'payment pending';

                        String formatP(dynamic val) {
                          if (val == null) return "0";
                          final numVal = double.tryParse(val.toString()) ?? 0.0;
                          if (numVal % 1 == 0) return numVal.toInt().toString();
                          return numVal.toStringAsFixed(2);
                        }

                        if (isCompleted && fb != null && (fb['base_fare'] != null || fb['final_payable_amount'] != null)) {
                          final baseFare = fb['base_fare'] ?? 0;
                          final waitingCharge = fb['waiting_charge'] ?? 0;
                          final extraKm = fb['extra_km'] ?? 0;
                          final perKmRate = fb['per_km_price'] ?? 0;
                          final extraKmCharge = fb['extra_km_charge'] ?? 0;
                          final discount = fb['discount_amount'] ?? 0;
                          final gstAmt = fb['gst_amount'] ?? 0;
                          final gstPct = fb['gst_percent'] ?? 5;
                          final finalPayable = fb['final_payable_amount'] ?? travel['fare_summary']?['total_fare'] ?? 0;
                          final actualDist = data['actual_distance_km'] ?? booking['actual_distance_km'] ?? 0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((double.tryParse(baseFare.toString()) ?? 0) > 0)
                                _priceinfor("Base Fare", "₹${formatP(baseFare)}"),
                              if ((double.tryParse(waitingCharge.toString()) ?? 0) > 0)
                                _priceinfor("Waiting Charges", "₹${formatP(waitingCharge)}"),
                              if ((double.tryParse(actualDist.toString()) ?? 0) > 0)
                                _priceinfor("Total Distance", "${formatP(actualDist)} km"),
                              if ((double.tryParse(extraKm.toString()) ?? 0) > 0)
                                _priceinfor("Extra KM", "${formatP(extraKm)} km"),
                              if ((double.tryParse(perKmRate.toString()) ?? 0) > 0 && (double.tryParse(extraKm.toString()) ?? 0) > 0)
                                _priceinfor("Per KM Rate", "₹${formatP(perKmRate)}/km"),
                              if ((double.tryParse(extraKmCharge.toString()) ?? 0) > 0)
                                _priceinfor("Extra KM Charges", "₹${formatP(extraKmCharge)}"),
                              if ((double.tryParse(discount.toString()) ?? 0) > 0)
                                _priceinfor("Coupon", "-₹${formatP(discount)}", iscolor: true),
                              if ((double.tryParse(gstAmt.toString()) ?? 0) > 0)
                                _priceinfor("GST ($gstPct%)", "₹${formatP(gstAmt)}"),
                              _priceinfor("Payment Mode", "${payment['payment_mode'] ?? booking['payment_mode'] ?? 'Cash'}"),
                              Divider(color: ColorsValue.l2),
                              _priceinfor(
                                "Total Fare",
                                "₹${formatP(finalPayable)}",
                                iscolor: true,
                                istitlecolor: true,
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            _priceinfor(
                              "Base Fare",
                              "₹${travel['fare_summary']?['base_fare'] ?? travel['final_price'] ?? 0}",
                            ),
                            if ((travel['fare_summary']?['gst_amount'] ?? payment['gst_applied']?['gst_amount'] ?? booking['gst_amount'] ?? 0) != 0)
                              _priceinfor(
                                "Tax (GST)",
                                "₹${travel['fare_summary']?['gst_amount'] ?? payment['gst_applied']?['gst_amount'] ?? booking['gst_amount'] ?? 0}",
                              ),
                            if (travel['fare_summary']?['special_services'] != null && travel['fare_summary']['special_services'].toString() != '0')
                              _priceinfor("Special Services", "₹${travel['fare_summary']?['special_services']}"),
                            if (travel['fare_summary']?['coupon_discount'] != null && travel['fare_summary']['coupon_discount'].toString() != '0')
                              _priceinfor("Coupon", "-₹${travel['fare_summary']?['coupon_discount']}", iscolor: true),
                            if (waitingChargeVal > 0 || data['ride_status'] == 'Driver Arrived' || booking['booking_status'] == 'Driver Arrived')
                              _priceinfor(
                                "Waiting Charges" + (totalWaitingMins > 0 ? " ($totalWaitingMins mins)" : ""),
                                "₹${waitingChargeVal.round()}",
                              ),
                            Divider(color: ColorsValue.l2),
                            _priceinfor(
                              "Total Fare",
                              "₹${travel['fare_summary']?['total_fare'] ?? payment['total_booking_price'] ?? payment['total_fare'] ?? payment['total_payment'] ?? 0}",
                              iscolor: true,
                              istitlecolor: true,
                            ),
                          ],
                        );
                      }),
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
                      Text("Payment Summary", style: Styles.appColor60016),
                      Dimens.boxHeight16,
                      Builder(
                        builder: (_) {
                          final String pMode = (payment['payment_mode'] ?? booking['payment_mode'] ?? 'Cash').toString();
                          final bool isCash = pMode.toLowerCase() == 'cash' || booking['payment_type'] == 0;
                          final num totalFareNum = double.tryParse((payment['total_booking_price'] ?? payment['total_fare'] ?? payment['total_payment'] ?? 0).toString()) ?? 0;
                          final num rawAdvPercent = double.tryParse((payment['advance_percent'] ?? 0).toString()) ?? 0;
                          final num rawAdvPaid = double.tryParse((payment['advance_paid'] ?? 0).toString()) ?? 0;

                          final num advPercent = isCash ? 0 : rawAdvPercent;
                          final num advPaid = isCash ? 0 : (rawAdvPaid > 0 ? rawAdvPaid : (advPercent > 0 ? ((totalFareNum * advPercent) / 100).round() : 0));

                          num collectAmount = 0;
                          if (isCash) {
                            collectAmount = double.tryParse((payment['amount_collect_from_customer'] ?? totalFareNum).toString()) ?? totalFareNum;
                          } else {
                            if (advPercent >= 100) {
                              collectAmount = totalFareNum > advPaid ? (totalFareNum - advPaid) : 0;
                            } else if (advPaid > 0) {
                              collectAmount = totalFareNum > advPaid ? (totalFareNum - advPaid) : 0;
                            } else {
                              collectAmount = double.tryParse((payment['amount_collect_from_customer'] ?? totalFareNum).toString()) ?? totalFareNum;
                            }
                          }

                          final num commAmount = double.tryParse((payment['commission_amount'] ?? 0).toString()) ?? 0;
                          num finalAmount = double.tryParse((payment['final_trip_fare'] ?? 0).toString()) ?? 0;
                          if (commAmount > 0 && (finalAmount >= totalFareNum || finalAmount <= 0)) {
                            finalAmount = totalFareNum > commAmount ? (totalFareNum - commAmount) : 0;
                          }
                          String formatVal(num val) {
                            if (val % 1 == 0) return val.toInt().toString();
                            return val.toStringAsFixed(2);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _priceinfor(
                                "Total Fare",
                                "₹${formatVal(totalFareNum)}",
                              ),
                              _priceinfor(
                                advPercent > 0 ? "Advance Paid ($advPercent%)" : "Advance Paid (0%)",
                                "₹${formatVal(advPaid)}",
                              ),
                              _priceinfor(
                                "Payment Mode",
                                isCash ? "Cash" : pMode,
                              ),
                              if (collectAmount > 0)
                                _priceinfor(
                                  "Amount Collect From Customer",
                                  "₹${formatVal(collectAmount)}",
                                  isredColor: true,
                                ),
                              if (commAmount > 0)
                                _priceinfor(
                                  "Bam Bam Commission",
                                  "-₹${formatVal(commAmount)}",
                                  iscolor: true,
                                ),
                              Divider(color: ColorsValue.l2),
                              _priceinfor(
                                "Final Trip Fare",
                                "₹${formatVal(finalAmount)}",
                                iscolor: true,
                                istitlecolor: true,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              Builder(
                builder: (_) {
                  final String rStatus = (data['ride_status'] ?? booking['booking_status'] ?? '').toString().toLowerCase();
                  final bool isCompleted = rStatus == 'completed' || rStatus == 'payment pending';
                  if (!isCompleted) return const SizedBox.shrink();

                  return Column(
                    children: [
                      CustomButton(
                        text: "Download Invoice",
                        leading: const Icon(
                          Icons.download_rounded,
                          color: ColorsValue.whiteColor,
                          size: 20,
                        ),
                        backgroundColor: ColorsValue.appColor,
                        radius: Dimens.twelve,
                        onPressed: () {
                          final idToUse = booking['_id']?.toString() ??
                              data['_id']?.toString() ??
                              booking['booking_id']?.toString() ??
                              '';
                          if (idToUse.isNotEmpty) {
                            final pdfUrl =
                                "https://apis.bambamcabs.com/vendor/request/booking/invoice/$idToUse?role=vendor";
                            Utility.snacBar("Opening invoice download...", ColorsValue.appColor);
                            Utility.launchLinkURL(pdfUrl);
                          } else {
                            Utility.snacBar("Booking ID not found", ColorsValue.redColor);
                          }
                        },
                      ),
                      Dimens.boxHeight16,
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
  Widget _buildDynamicStatusBadge(String? status) {
    String cleanStatus = status ?? 'Unknown';
    Color bg = const Color(0xFFD7F8FF);
    Color text = const Color(0xFF00C0E8);

    if (cleanStatus.toLowerCase().contains('cancel')) {
      bg = const Color(0xFFFFE4E3);
      text = const Color(0xFFFF3B30);
    } else if (cleanStatus.toLowerCase().contains('completed')) {
      bg = const Color(0xFFD9FFEF);
      text = const Color(0xFF12724A);
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: Dimens.edgeInsets12,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      child: Text(
        cleanStatus,
        style: Styles.g1txtColor60014.copyWith(color: text, fontSize: 13),
      ),
    );
  }
}
