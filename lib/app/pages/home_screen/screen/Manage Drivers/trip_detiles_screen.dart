import 'package:bam_bam_vendor/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TripDetilesScreen extends StatelessWidget {
  const TripDetilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final data = controller.selectedTripDetails ?? {};
        final booking = data['booking_id'] is Map ? data['booking_id'] : {};
        final travel = booking['travelDetailsId'] ?? {};
        final user = booking['userId'] ?? {};
        final driver = data['driver_id'] is Map ? data['driver_id'] : (booking['driver_id'] is Map ? booking['driver_id'] : {});
        final vehicle = data['vehicle_id'] is Map ? data['vehicle_id'] : (booking['vehicle_id'] is Map ? booking['vehicle_id'] : {});
        final payment = booking['payment_summary'] ?? {};

        String formatDate(String? isoDate, String format) {
          if (isoDate == null || isoDate.isEmpty) return "-";
          return Utility.getFormatedTime(isoDate, format);
        }

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () {
              Get.back();
            },
            title: "Trip Details",
          ),
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const BouncingScrollPhysics(),
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
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimens.twelve),
                              color: (data['ride_status'] == 'Completed' ||
                                      data['ride_status'] == 'Accepted')
                                  ? Colors.green.withOpacity(0.1)
                                  : ColorsValue.redCB,
                            ),
                            child: Padding(
                              padding: Dimens.edgeInsets16_8_16_8,
                              child: Text(
                                data['ride_status'] ?? "Pending",
                                style: (data['ride_status'] == 'Completed' ||
                                        data['ride_status'] == 'Accepted')
                                    ? Styles.greenColor50014
                                    : Styles.redColor50014,
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
                                Text("Booking ID", style: Styles.g7txtColor40014),
                                Text(
                                  "${booking['booking_id'] ?? 'N/A'}",
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Booking Date", style: Styles.g7txtColor40014),
                                Text(
                                  formatDate(booking['createdAt'], "dd/MM/yyyy"),
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
                        "${travel['trip_type'] ?? 'N/A'}".replaceAll('_', ' '),
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
                                Text("Pickup Date & Time", style: Styles.g7txtColor40014),
                                Text(
                                  "${formatDate(travel['date'], 'dd-MM-yyyy')} ${travel['pickup_time'] ?? ''}",
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
                                  Text("Return Date & Time", style: Styles.g7txtColor40014),
                                  Text(
                                    travel['return_date'] != null && travel['return_date'].toString().isNotEmpty && travel['return_date'].toString() != 'null'
                                        ? "${formatDate(travel['return_date'], 'dd-MM-yyyy')} ${travel['return_time'] ?? ''}"
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
                      Text("${travel['trip_type'] ?? ''}", style: Styles.g7txtColor40014),
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
                                formatDate(travel['date'], "dd/MM/yy"),
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
              if (vehicle.isNotEmpty)
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
                                  "${vehicle['brand_name'] ?? 'Vehicle'}",
                                  style: Styles.g7txtColor40014,
                                ),
                                Text(
                                  "${vehicle['vehicle_number'] ?? 'N/A'}",
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                            Image.asset(AssetConstants.carpng, height: Dimens.fourtyEight),
                          ],
                        ),
                        Dimens.boxHeight16,
                        Row(
                          children: [
                            SvgPicture.asset(AssetConstants.ic_gasStation, color: ColorsValue.appColor),
                            Dimens.boxWidth4,
                            Text(
                              "${vehicle['fuel_type'] is List ? (vehicle['fuel_type'] as List).map((e) => e['name']).join('/') : vehicle['fuel_type'] ?? 'N/A'}",
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
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(AssetConstants.person),
                        ),
                        title: Text("${user['full_name'] ?? 'User'}", style: Styles.g1txtColor60016),
                        subtitle: Text("${user['email'] ?? ''}", style: Styles.g7txtColor40014),
                      ),
                      Dimens.boxHeight5,
                      _textinfo("Mobile No.", "${user['phone_no'] ?? user['mobile_number'] ?? 'N/A'}"),
                      _textinfo("Pickup Address", "${travel['pickup_address'] ?? 'N/A'}"),
                      _textinfo(
                        "Drop Address",
                        "${(travel['drop_address'] is List && (travel['drop_address'] as List).isNotEmpty) ? travel['drop_address'][0] : travel['drop_address'] ?? 'N/A'}",
                      ),
                    ],
                  ),
                ),
              ),
              Dimens.boxHeight16,
              if (driver.isNotEmpty)
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
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(AssetConstants.person),
                          ),
                          title: Text("Driver Name", style: Styles.g1txtColor60016),
                          subtitle: Text(
                            "${driver['driver_name'] ?? driver['fullName'] ?? 'N/A'}",
                            style: Styles.g7txtColor40014,
                          ),
                        ),
                        Dimens.boxHeight5,
                        _textinfo("Mobile No.", "${driver['driver_mobile'] ?? driver['mobileNumber'] ?? 'N/A'}"),
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
                            _priceinfor("Base Fare", "₹${travel['fare_summary']?['base_fare'] ?? 0}"),
                            if ((travel['fare_summary']?['gst_amount'] ?? payment['gst_applied']?['gst_amount'] ?? 0) != 0)
                              _priceinfor("Tax (GST)", "₹${travel['fare_summary']?['gst_amount'] ?? payment['gst_applied']?['gst_amount'] ?? 0}"),
                            if (travel['fare_summary']?['special_services'] != null && travel['fare_summary']['special_services'].toString() != '0')
                              _priceinfor("Special Services", "₹${travel['fare_summary']?['special_services']}"),
                            if (travel['fare_summary']?['coupon_discount'] != null && travel['fare_summary']['coupon_discount'].toString() != '0')
                              _priceinfor("Coupon", "-₹${travel['fare_summary']?['coupon_discount']}", iscolor: true),
                            Divider(color: ColorsValue.l2),
                            _priceinfor(
                              "Total Fare",
                              "₹${travel['fare_summary']?['total_fare'] ?? payment['total_fare'] ?? 0}",
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
                      _priceinfor("Total Fare", "₹${payment['total_fare'] ?? travel['fare_summary']?['total_fare'] ?? 0}"),
                      // _priceinfor("Tax (GST)", "₹${travel['fare_summary']?['gst_amount'] ?? payment['gst_applied']?['gst_amount'] ?? data['gst_amount'] ?? booking['gst_amount'] ?? 0}"),
                      if (payment['advance_paid'] != null && payment['advance_paid'].toString() != '0')
                        _priceinfor("Advance Paid", "(${payment['advance_percent'] ?? 0}%)₹${payment['advance_paid']}"),
                      _priceinfor("Payment Mode", "${payment['payment_mode'] ?? booking['payment_mode'] ?? 'Cash'}"),
                      if (payment['amount_collect_from_customer'] != null && payment['amount_collect_from_customer'].toString() != '0')
                        _priceinfor(
                          "Amount Collect From Customer",
                          "₹${payment['amount_collect_from_customer'] ?? 0}",
                          isredColor: true,
                        ),
                      if (payment['commission_amount'] != null && payment['commission_amount'].toString() != '0')
                        _priceinfor("Bam Bam Commission", "-₹${payment['commission_amount']}", iscolor: true),
                      Divider(color: ColorsValue.l2),
                      _priceinfor(
                        "Final Trip Fare",
                        "₹${payment['final_trip_fare'] ?? 0}",
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
