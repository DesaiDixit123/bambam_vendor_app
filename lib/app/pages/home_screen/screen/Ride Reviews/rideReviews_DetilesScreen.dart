import 'package:bam_bam_vendor/app/app.dart';
import 'package:bam_bam_vendor/data/helpers/api_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class RidereviewsDetilesscreen extends StatelessWidget {
  const RidereviewsDetilesscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final review = controller.selectedReviewDetails;
        if (review == null) {
          return Scaffold(
            appBar: AppBarWidget(
              onTapBack: Get.back,
              title: "Ride Review Details",
            ),
            backgroundColor: ColorsValue.appBg,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final String reviewId = review['_id']?.toString() ?? "";
        final user = review['userId'] ?? {};
        final travel = review['travelDetailsId'] ?? {};
        final vehicle = review['vehicleId'] ?? {};
        final vehicleInfo = vehicle['vehicleInformation'] ?? {};
        final driver = review['driverId'] ?? {};
        final driverInfo = driver['driverInformation'] ?? {};
        final payment = review['payment_summary'] ?? {};

        final overallRating = double.tryParse(review['overall_rating'].toString()) ?? 0.0;
        final catItem = review['reviewer_category_item'] ?? {};
        final ratingLabel = catItem['name'] ?? "";
        final comments = review['comments'] ?? "No comment provided.";
        
        final date = review['createdAt'] != null
            ? Utility.getFormatedTime(review['createdAt'], "dd/MM/yyyy")
            : "N/A";

        return Scaffold(
          appBar: AppBarWidget(
            onTapBack: Get.back,
            title: "Ride Review Details",
            actions: [
              IconButton(
                icon: Icon(Icons.delete_forever, color: ColorsValue.redColor, size: 28),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Review"),
                      content: const Text("Are you sure you want to delete this customer review?"),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back(); // close dialog
                            controller.deleteRideReviewController(reviewId);
                          },
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          backgroundColor: ColorsValue.appBg,
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
                                  review['booking_id']?.toString() ?? "N/A",
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorsValue.greenCB,
                                    borderRadius: BorderRadius.circular(
                                      Dimens.six,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      travel['status']?.toString() ?? "Completed",
                                      style: Styles.g1txtColor40012.copyWith(
                                        color: ColorsValue.greenColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                                  "Booking Type",
                                  style: Styles.g7txtColor40014,
                                ),
                                Text(
                                  (travel['trip_type'] ?? 'One Way').toString().replaceAll('_', ' '),
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
                                  date,
                                  style: Styles.g1txtColor60016,
                                ),
                              ],
                            ),
                          ),
                        ],
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
                                  "${travel['date'] != null ? Utility.getFormatedTime(travel['date'], 'dd-MM-yyyy') : ''} ${travel['pickup_time'] ?? ''}",
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
                                Text(
                                  travel['return_date'] != null
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
                        (travel['trip_type'] ?? 'One Way').toString().replaceAll('_', ' '),
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
                                travel['date'] != null
                                    ? "${Utility.getFormatedTime(travel['date'], 'dd/MM/yy')} "
                                    : "N/A",
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
                                vehicleInfo['vehicle_type']?['name']?.toString() ?? "SUV",
                                style: Styles.g7txtColor40014,
                              ),
                              Text(
                                "${vehicleInfo['brand_name'] ?? 'N/A'} ${vehicleInfo['model_name'] ?? ''}",
                                style: Styles.g1txtColor60016,
                              ),
                            ],
                          ),
                          if (vehicleInfo['front_image'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _resolveImageUrl(vehicleInfo['front_image']),
                                height: Dimens.fourtyEight,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  AssetConstants.carpng,
                                  height: Dimens.fourtyEight,
                                ),
                              ),
                            )
                          else
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
                            (vehicleInfo['fuel_type'] as List?)?.map((e) => e['name']).join('/') ?? "Petrol",
                            style: Styles.g5txtColor40012,
                          ),
                          Dimens.boxWidth6,
                          SvgPicture.asset(
                            AssetConstants.ic_manual,
                            color: ColorsValue.appColor,
                          ),
                          Dimens.boxWidth4,
                          Text(
                            vehicleInfo['transmission']?.toString() ?? "Manual",
                            style: Styles.g5txtColor40012,
                          ),
                          Dimens.boxWidth6,
                          SvgPicture.asset(
                            AssetConstants.ic_sets,
                            color: ColorsValue.appColor,
                          ),
                          Dimens.boxWidth4,
                          Text(
                            "${vehicleInfo['seating_capacity'] ?? '5'} seats",
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
                          backgroundImage: AssetImage(AssetConstants.usera),
                          radius: 20,
                        ),
                        title: Text(
                          date,
                          style: Styles.g1txtColor60016,
                        ),
                        subtitle: Text(
                          review['reviewer_name'] ?? user['full_name'] ?? "Customer",
                          style: Styles.g7txtColor40014,
                        ),
                      ),
                      Dimens.boxHeight5,
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < overallRating.round() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                      Dimens.boxHeight10,
                      Text(
                        comments,
                        style: Styles.g7txtColor40014,
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
                          radius: 20,
                        ),
                        title: Text(
                          "Driver Details",
                          style: Styles.g1txtColor60016,
                        ),
                        subtitle: Text(
                          driverInfo['driver_name'] ?? driver['driver_name'] ?? "Assigned Driver",
                          style: Styles.g7txtColor40014,
                        ),
                      ),
                      Dimens.boxHeight5,
                      _textinfo("Mobile No.", driverInfo['driver_mobile'] ?? driver['driver_mobile'] ?? "N/A"),
                      _textinfo(
                        "Driver Address",
                        "${driverInfo['address'] ?? driver['address'] ?? 'N/A'}",
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
                      Builder(builder: (_) {
                        final fb = review['vendorRequestDetails']?['fare_breakdown'] ?? review['fare_breakdown'] ?? travel['fare_breakdown'];
                        String formatP(dynamic val) {
                          if (val == null) return "0";
                          final numVal = double.tryParse(val.toString()) ?? 0.0;
                          if (numVal % 1 == 0) return numVal.toInt().toString();
                          return numVal.toStringAsFixed(2);
                        }

                        if (fb != null && (fb['base_fare'] != null || fb['final_payable_amount'] != null)) {
                          final baseFare = fb['base_fare'] ?? 0;
                          final waitingCharge = fb['waiting_charge'] ?? 0;
                          final extraKm = fb['extra_km'] ?? 0;
                          final perKmRate = fb['per_km_price'] ?? 0;
                          final extraKmCharge = fb['extra_km_charge'] ?? 0;
                          final discount = fb['discount_amount'] ?? 0;
                          final gstAmt = fb['gst_amount'] ?? 0;
                          final gstPct = fb['gst_percent'] ?? 5;
                          final finalPayable = fb['final_payable_amount'] ?? payment['final_trip_fare'] ?? 0;
                          final actualDist = review['actual_distance_km'] ?? review['vendorRequestDetails']?['actual_distance_km'] ?? 0;

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
                                _priceinfor("Coupon Discount", "-₹${formatP(discount)}", iscolor: true),
                              if ((double.tryParse(gstAmt.toString()) ?? 0) > 0)
                                _priceinfor("GST ($gstPct%)", "₹${formatP(gstAmt)}"),
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
                            _priceinfor("Base Fare", "₹${payment['base_fare'] ?? 0}"),
                            _priceinfor("Taxes & Fees", "₹${payment['taxes_and_fees'] ?? 0}"),
                            _priceinfor("Other Charges", "₹${payment['other_charges'] ?? 0}"),
                            if (payment['coupon_discount'] != null && payment['coupon_discount'] > 0)
                              _priceinfor(
                                "Coupon Discount",
                                "-₹${payment['coupon_discount']}",
                                iscolor: true,
                              ),
                            _priceinfor(
                              "Bam Bam Commission",
                              "-₹${payment['commission_fee'] ?? 0}",
                              iscolor: true,
                            ),
                            Divider(color: ColorsValue.l2),
                            _priceinfor(
                              "Total Fare",
                              "₹${payment['final_trip_fare'] ?? 0}",
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
                color: istitlecolor == true ? ColorsValue.g1txtColor : ColorsValue.g7txtColor,
                fontWeight: istitlecolor == true ? FontWeight.w700 : FontWeight.w400,
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

  String _resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    final trimmed = path.trim();
    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }
    
    String cleanPath = trimmed;
    if (cleanPath.startsWith("uploads/")) {
      cleanPath = cleanPath.substring("uploads/".length);
    } else if (cleanPath.startsWith("/uploads/")) {
      cleanPath = cleanPath.substring("/uploads/".length);
    }
    
    return "${ApiWrapper.imageUrl}$cleanPath";
  }
}
