import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/data.dart';
import 'package:bam_bam_vendor/app/pages/home_screen/screen/Bam_Bam_Hub/bambam_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RideDetilesScreen extends StatefulWidget {
  const RideDetilesScreen({super.key});

  @override
  State<RideDetilesScreen> createState() => _RideDetilesScreenState();
}

class _RideDetilesScreenState extends State<RideDetilesScreen> {
  @override
  void initState() {
    super.initState();
    // 🚕 Fetch details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null) {
        final String vendorRequestId = Get.arguments.toString();
        if (vendorRequestId.isNotEmpty) {
          Get.find<HomeController>().getRideDetails(vendorRequestId);
        }
      }
    });
  }

  // 🔐 Safe text helper
  String safeText(dynamic value) {
    if (value == null) return "-";
    if (value is String && value.isEmpty) return "-";
    return value.toString();
  }

  // 🔍 Recursive key finder to safely scan payload for nested attributes
  dynamic findKeyRecursively(dynamic data, String targetKey) {
    if (data is Map) {
      if (data.containsKey(targetKey)) {
        final val = data[targetKey];
        if (val != null && val.toString().toLowerCase() != 'null' && val.toString().trim().isNotEmpty) {
          return val;
        }
      }
      for (final value in data.values) {
        final res = findKeyRecursively(value, targetKey);
        if (res != null) return res;
      }
    } else if (data is List) {
      for (final item in data) {
        final res = findKeyRecursively(item, targetKey);
        if (res != null) return res;
      }
    }
    return null;
  }

  String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "-";
    try {
      final dateTime = DateTime.parse(isoDate).toLocal();
      return "${dateTime.day.toString().padLeft(2, '0')}-"
          "${dateTime.month.toString().padLeft(2, '0')}-"
          "${dateTime.year}";
    } catch (e) {
      print("Error parsing date: $isoDate - $e");
      return isoDate; // Return as-is if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final data = controller.selectedRideDetails;
        final vendorRequest = data?['vendorRequest'] ?? {};
        final booking = data?['bookingDetails'] ?? {};
        final travel = booking['travelDetailsId'] ?? {};
        final tripType = safeText(travel['trip_type']).toLowerCase();
        final isRoundTrip = tripType.contains("round");

        // 🚕 Robust recursive search for return date & time keys
        final rawReturnDate = findKeyRecursively(data, 'return_date') ??
            findKeyRecursively(data, 'returnDate') ??
            findKeyRecursively(data, 'retun_date') ??
            findKeyRecursively(data, 'retunDate');

        final rawReturnTime = findKeyRecursively(data, 'return_time') ??
            findKeyRecursively(data, 'returnTime') ??
            findKeyRecursively(data, 'retun_time') ??
            findKeyRecursively(data, 'retunTime');

        final vendorRequestId = vendorRequest['_id']?.toString() ?? "";
        final vendorStatus = booking['vendor_status']?.toString() ?? "";
        final rideStatus = (vendorRequest['ride_status']?.toString() ?? "").toLowerCase();
        final bookingStatus = (booking['booking_status']?.toString() ?? "");
        // Hide buttons when the ride is in a terminal state (completed/cancelled/rejected)
        final isTerminalRide = rideStatus == 'completed' || rideStatus == 'cancelled' || rideStatus == 'rejected';
        final isPending = vendorStatus.toLowerCase() == 'pending' && !isTerminalRide;



        final double waitingChargeVal = double.tryParse((vendorRequest['waiting_charge'] ?? booking['waiting_charge'] ?? 0).toString()) ?? 0;
        final int totalWaitingMins = int.tryParse((vendorRequest['total_waiting_minutes'] ?? booking['total_waiting_minutes'] ?? 0).toString()) ?? 0;

        // Driver & Vehicle details (only show when allocated)
        final driverData = vendorRequest['driver_id'] ?? booking['driver_id'];
        final bool isDriverObject = driverData is Map;
        final vehicleData = booking['vehicle_id'];
        final bool isVehicleObject = vehicleData is Map;
        final bool isDVAllocated = bookingStatus.toLowerCase().contains('allocated') ||
            bookingStatus.toLowerCase().contains('arrived') ||
            bookingStatus.toLowerCase() == 'ongoing' ||
            bookingStatus.toLowerCase() == 'completed' ||
            rideStatus.contains('allocated') ||
            rideStatus.contains('arrived') ||
            rideStatus == 'ongoing' ||
            rideStatus == 'completed' ||
            isDriverObject ||
            isVehicleObject;

        if (controller.isRideDetailsLoading) {
          return Scaffold(
            backgroundColor: ColorsValue.l3,
            appBar: AppBarWidget(
              onTapBack: () => Get.back(),
              title: "Ride Details",
            ),
            body: Utility.loaderWidget(),
          );
        }

        if (data == null) {
          return Scaffold(
            backgroundColor: ColorsValue.l3,
            appBar: AppBarWidget(
              onTapBack: () => Get.back(),
              title: "Ride Details",
            ),
            body: const Center(child: Text("No Ride Details Found")),
          );
        }

        return Scaffold(
          backgroundColor: ColorsValue.l3,
          appBar: AppBarWidget(
            onTapBack: () => Get.back(),
            title: "Ride Details",
          ),

          /// 🔘 Bottom Buttons (Only if Pending) or Status Badge
          bottomNavigationBar: isPending
              ? Padding(
                  padding: Dimens.edgeInsets20_30_20_30,
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: vendorRequestId.isEmpty
                              ? null
                              : () {
                                  controller.showRideRejectDialog(
                                    vendorRequestId,
                                  );
                                },
                          text: "Reject",
                          backgroundColor: Colors.transparent,
                          isBorder: true,
                          bordercolors: ColorsValue.redColor,
                          radius: Dimens.fifty,
                          textStyle: Styles.redColor50014,
                        ),
                      ),
                      Dimens.boxWidth12,
                      Expanded(
                        child: CustomButton(
                          onPressed: () {
                            controller.handleConfirmTap(
                              context,
                            );
                          },
                          backgroundColor: ColorsValue.greenColor,
                          text: "Confirm",
                          radius: Dimens.fifty,
                          textStyle: Styles.whiteColorW60016,
                        ),
                      ),
                    ],
                  ),
                )
              : Builder(builder: (_) {
                  final style = BambamHubScreen.getStatusStyle(vendorRequest, booking);
                  return Padding(
                    padding: Dimens.edgeInsets20_30_20_30,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: style['bg'] as Color,
                        borderRadius: BorderRadius.circular(Dimens.fifty),
                      ),
                      child: Text(
                        style['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: style['text'] as Color,
                        ),
                      ),
                    ),
                  );
                }),

          /// 📜 BODY
          body: ListView(
            padding: Dimens.edgeInsets20,
            physics: const BouncingScrollPhysics(),
            children: [
              /// ================= BOOKING INFO =================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowInfo("Booking ID", safeText(booking['booking_id'])),
                    _rowInfo("Booking Date", formatDate(booking['createdAt'])),
                    _rowInfo("Trip Type", safeText(travel['trip_type'])),
                    _rowInfo(
                      "Pickup Date & Time",
                      "${formatDate(travel['date'])} ${safeText(travel['pickup_time'])}",
                    ),
                    if (isRoundTrip)
                      _rowInfo(
                        "Return Date",
                        rawReturnDate != null && rawReturnDate.toString().isNotEmpty && rawReturnDate.toString() != "null"
                            ? formatDate(rawReturnDate.toString())
                            : "-",
                      ),
                    _rowInfo(
                      "Ride Status",
                      safeText(vendorRequest['ride_status']),
                    ),
                  ],
                ),
              ),

              /// ================= ROUTE =================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Route", style: Styles.g7txtColor40014),
                    Dimens.boxHeight6,
                    Builder(builder: (context) {
                      final from = Utility.getDisplayFrom(travel);
                      final to = Utility.getDisplayTo(travel);
                      final isLocal = travel['trip_type']?.toString().toLowerCase().contains('local') == true;
                      if (isLocal || to == '-' || to.isEmpty) {
                        return Text(from, style: Styles.g1txtColor60014);
                      } else {
                        return Text("$from → $to", style: Styles.g1txtColor60014);
                      }
                    }),
                  ],
                ),
              ),

              /// ================= CUSTOMER =================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Traveller", style: Styles.appColor60016),
                    Dimens.boxHeight12,
                    _textinfo("Name", safeText(travel['traveler_name'])),
                    _textinfo("Mobile", safeText(travel['traveler_mobile'])),
                    _textinfo(
                      "Pickup Address",
                      safeText(travel['pickup_address']),
                    ),
                    if (!(travel['trip_type']?.toString().toLowerCase().contains('local') ?? false))
                      _textinfo(
                        "Drop Address",
                        safeText(
                          (travel['drop_address'] is List &&
                                  (travel['drop_address'] as List).isNotEmpty)
                              ? travel['drop_address'][0]
                              : travel['drop_address'],
                        ),
                      ),
                  ],
                ),
              ),

              /// ================= DRIVER & VEHICLE DETAILS (only when allocated) =================
              if (isDVAllocated) ...[            
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Driver & Vehicle Details", style: Styles.appColor60016),
                      Dimens.boxHeight12,
                      // Driver Section
                      if (isDriverObject) ...[
                        Row(
                          children: [
                            if (driverData['driver_photo'] != null || driverData['photo'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: Image.network(
                                  (driverData['driver_photo'] ?? driverData['photo']).toString().startsWith('http')
                                      ? (driverData['driver_photo'] ?? driverData['photo']).toString()
                                      : '${ApiWrapper.imageUrl}${driverData['driver_photo'] ?? driverData['photo']}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.person, color: Colors.grey),
                                      ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    safeText(driverData['driver_name'] ?? driverData['name']),
                                    style: Styles.g1txtColor60016,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '+91 ${safeText(driverData['driver_mobile'] ?? driverData['mobile'] ?? driverData['phone'])}',
                                    style: Styles.g7txtColor40014,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                      ] else
                        _textinfo("Driver", "Not assigned yet"),

                      // Vehicle Section
                      if (isVehicleObject) ...[
                        _textinfo("Vehicle", safeText(vehicleData['vehicle_name'] ?? vehicleData['brand_name'])),
                        _textinfo("Vehicle No.", safeText(vehicleData['vehicle_number'])),
                      ] else
                        _textinfo("Vehicle", "Not assigned yet"),
                    ],
                  ),
                ),
              ],

              /// ================= TRIP FARE SUMMARY =================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trip Fare Summary",
                      style: Styles.appColor60016.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                    Dimens.boxHeight12,
                    Builder(builder: (_) {
                      final fb = vendorRequest['fare_breakdown'] ?? booking['fare_breakdown'] ?? travel['fare_breakdown'];
                      final bool isCompleted = rideStatus == 'completed' || rideStatus == 'payment pending' || bookingStatus.toLowerCase().contains('complete') || bookingStatus.toLowerCase() == 'payment pending';

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
                        final actualDist = vendorRequest['actual_distance_km'] ?? booking['actual_distance_km'] ?? 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((double.tryParse(baseFare.toString()) ?? 0) > 0)
                              _price("Base Fare", "₹${formatP(baseFare)}"),
                            if ((double.tryParse(waitingCharge.toString()) ?? 0) > 0)
                              _price("Waiting Charges", "₹${formatP(waitingCharge)}"),
                            if ((double.tryParse(actualDist.toString()) ?? 0) > 0)
                              _price("Total Distance", "${formatP(actualDist)} km"),
                            if ((double.tryParse(extraKm.toString()) ?? 0) > 0)
                              _price("Extra KM", "${formatP(extraKm)} km"),
                            if ((double.tryParse(perKmRate.toString()) ?? 0) > 0 && (double.tryParse(extraKm.toString()) ?? 0) > 0)
                              _price("Per KM Rate", "₹${formatP(perKmRate)}/km"),
                            if ((double.tryParse(extraKmCharge.toString()) ?? 0) > 0)
                              _price("Extra KM Charges", "₹${formatP(extraKmCharge)}"),
                            if ((double.tryParse(discount.toString()) ?? 0) > 0)
                              _price("Coupon Discount", "-₹${formatP(discount)}", valueColor: ColorsValue.greenColor),
                            if ((double.tryParse(gstAmt.toString()) ?? 0) > 0)
                              _price("GST ($gstPct%)", "₹${formatP(gstAmt)}"),
                            _price("Payment Mode", safeText(vendorRequest['payment_mode'] ?? booking['payment_mode'] ?? "Cash")),
                            const Divider(),
                            _price(
                              "Total Fare",
                              "₹${formatP(finalPayable)}",
                              bold: true,
                              valueColor: ColorsValue.greenColor,
                            ),
                          ],
                        );
                      }

                      final rawBase = double.tryParse(travel['fare_summary']?['base_fare']?.toString() ?? '0') ?? 0;
                      final gstVal = double.tryParse((travel['fare_summary']?['gst_amount'] ?? travel['fare_summary']?['gst_included'] ?? 0).toString()) ?? 0;
                      final gstPct = (travel['fare_summary']?['gst_percent'] ?? '').toString();
                      return Column(
                        children: [
                          _price("Base Fare", "₹${rawBase.round()}"),
                          if (gstVal > 0)
                            _price("Tax (GST${gstPct.isNotEmpty && gstPct != '0' ? ' $gstPct%' : ''})", "₹${gstVal.round()}"),
                          if (travel['fare_summary']?['special_services'] != null && travel['fare_summary']['special_services'].toString() != '0')
                            _price(
                              "Special Services",
                              "₹${safeText(travel['fare_summary']?['special_services'])}",
                            ),
                          if (travel['fare_summary']?['coupon_discount'] != null && travel['fare_summary']['coupon_discount'].toString() != '0')
                            _price(
                              "Coupon",
                              "-₹${safeText(travel['fare_summary']?['coupon_discount'])}",
                              valueColor: ColorsValue.greenColor,
                            ),
                          if (waitingChargeVal > 0 || rideStatus == 'driver arrived' || bookingStatus == 'Driver Arrived')
                            _price(
                              "Waiting Charges" + (totalWaitingMins > 0 ? " ($totalWaitingMins mins)" : ""),
                              "₹${waitingChargeVal.round()}",
                            ),
                          const Divider(),
                          _price(
                            "Total Fare",
                            "₹${safeText(travel['fare_summary']?['total_fare'])}",
                            bold: true,
                            valueColor: ColorsValue.greenColor,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              /// ================= PAYMENT SUMMARY =================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Payment Summary",
                      style: Styles.appColor60016.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                    Dimens.boxHeight12,
                    Builder(builder: (_) {
                      final fb = vendorRequest['fare_breakdown'] ?? booking['fare_breakdown'] ?? travel['fare_breakdown'];
                      final bool isCompleted = rideStatus == 'completed' || rideStatus == 'payment pending' || bookingStatus.toLowerCase().contains('complete') || bookingStatus.toLowerCase() == 'payment pending';
                      String formatP(dynamic val) {
                        if (val == null) return "0";
                        final numVal = double.tryParse(val.toString()) ?? 0.0;
                        if (numVal % 1 == 0) return numVal.toInt().toString();
                        return numVal.toStringAsFixed(2);
                      }
                      final totalFareDisplay = isCompleted && fb != null && fb['final_payable_amount'] != null
                          ? formatP(fb['final_payable_amount'])
                          : safeText(booking['payment_summary']?['total_fare']);
                      final totalFareNum = double.tryParse(totalFareDisplay) ?? 0.0;

                      final String pMode = safeText(
                        vendorRequest['payment_mode'] ??
                            booking['payment_mode'] ??
                            booking['payment_summary']?['payment_mode'] ??
                            "Cash",
                      );
                      final bool isCash = pMode.toLowerCase() == 'cash' || booking['payment_type'] == 0;

                      final num rawAdvPercent = double.tryParse((booking['payment_summary']?['advance_percent'] ?? 0).toString()) ?? 0;
                      final num rawAdvPaid = double.tryParse((booking['payment_summary']?['advance_paid'] ?? 0).toString()) ?? 0;

                      final num advPercent = isCash ? 0 : rawAdvPercent;
                      final num advPaid = isCash ? 0 : (rawAdvPaid > 0 ? rawAdvPaid : (advPercent > 0 ? ((totalFareNum * advPercent) / 100).round() : 0));

                      num collect = 0;
                      if (isCash) {
                        collect = isCompleted && fb != null && fb['final_payable_amount'] != null
                            ? double.tryParse(fb['final_payable_amount'].toString()) ?? 0
                            : double.tryParse((booking['payment_summary']?['amount_collect_from_customer'] ?? booking['pending_payment'] ?? vendorRequest['collect_cash_amount'] ?? totalFareNum).toString()) ?? totalFareNum;
                      } else {
                        if (advPercent >= 100) {
                          collect = totalFareNum > advPaid ? (totalFareNum - advPaid) : 0;
                        } else if (advPaid > 0) {
                          collect = totalFareNum > advPaid ? (totalFareNum - advPaid) : 0;
                        } else {
                          collect = isCompleted && fb != null && fb['final_payable_amount'] != null
                              ? double.tryParse(fb['final_payable_amount'].toString()) ?? 0
                              : double.tryParse((booking['payment_summary']?['amount_collect_from_customer'] ?? totalFareNum).toString()) ?? totalFareNum;
                        }
                      }

                      final num commAmount = double.tryParse((booking['payment_summary']?['commission_amount'] ?? 0).toString()) ?? 0;
                      num finalAmount = double.tryParse((booking['payment_summary']?['final_trip_fare'] ?? 0).toString()) ?? 0;
                      if (commAmount > 0 && (finalAmount >= totalFareNum || finalAmount <= 0)) {
                        finalAmount = totalFareNum > commAmount ? (totalFareNum - commAmount) : 0;
                      }

                      return Column(
                        children: [
                          _price(
                            "Total Fare",
                            "₹$totalFareDisplay",
                          ),
                          _price(
                            advPercent > 0 ? "Advance Paid ($advPercent%)" : "Advance Paid (0%)",
                            "₹${formatP(advPaid)}",
                          ),
                          _price(
                            "Payment Mode",
                            isCash ? "Cash" : pMode,
                          ),
                          if (collect > 0)
                            _price(
                              "Amount Collect From Customer",
                              "₹${formatP(collect)}",
                              valueColor: ColorsValue.redColor,
                              bold: true,
                            ),
                          if (commAmount > 0)
                            _price(
                              "Bam Bam Commission",
                              "-₹${formatP(commAmount)}",
                              valueColor: ColorsValue.greenColor,
                              bold: true,
                            ),
                          const Divider(),
                          _price(
                            "Final Trip Fare",
                            "₹${formatP(finalAmount)}",
                            bold: true,
                            valueColor: ColorsValue.greenColor,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              Builder(
                builder: (_) {
                  final bool isCompleted = rideStatus == 'completed' ||
                      rideStatus == 'payment pending' ||
                      bookingStatus.toLowerCase().contains('complete') ||
                      bookingStatus.toLowerCase() == 'payment pending';
                  if (!isCompleted) return const SizedBox.shrink();

                  return Column(
                    children: [
                      Dimens.boxHeight16,
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
                              vendorRequest['_id']?.toString() ??
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

  /// ================= UI HELPERS =================

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: Dimens.edgeInsets16,
      decoration: BoxDecoration(
        color: ColorsValue.whiteColor,
        borderRadius: BorderRadius.circular(Dimens.twelve),
      ),
      child: child,
    );
  }

  Widget _rowInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Styles.g7txtColor40014,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Styles.g1txtColor60016,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _textinfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.g1txtColor60016),
          Dimens.boxHeight2,
          Text(value, style: Styles.g7txtColor40014),
        ],
      ),
    );
  }

  Widget _price(
    String title,
    String value, {
    bool bold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: Styles.g7txtColor40014,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Styles.g1txtColor60014.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
